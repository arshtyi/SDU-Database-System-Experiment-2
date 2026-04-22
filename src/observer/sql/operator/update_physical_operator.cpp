#include "sql/operator/update_physical_operator.h"
#include <cstring>
#include "common/log/log.h"
#include "sql/expr/tuple.h"
#include "storage/field/field_meta.h"
#include "storage/table/table.h"
#include "storage/trx/trx.h"

RC UpdatePhysicalOperator::open(Trx *trx)
{
  if (children_.empty()) {
    return RC::SUCCESS;
  }

  unique_ptr<PhysicalOperator> &child = children_[0];

  RC rc = child->open(trx);
  if (OB_FAIL(rc)) {
    LOG_WARN("failed to open child operator. rc=%s", strrc(rc));
    return rc;
  }

  trx_ = trx;

  while (OB_SUCC(rc = child->next())) {
    Tuple *tuple = child->current_tuple();
    if (nullptr == tuple) {
      LOG_WARN("failed to get current tuple");
      child->close();
      return RC::INTERNAL;
    }

    RowTuple *row_tuple = static_cast<RowTuple *>(tuple);
    Record   &record    = row_tuple->record();

    Record copied_record;
    rc = copied_record.copy_data(record.data(), record.len());
    if (OB_FAIL(rc)) {
      LOG_WARN("failed to copy record. rc=%s", strrc(rc));
      child->close();
      return rc;
    }
    copied_record.set_rid(record.rid());
    records_.emplace_back(std::move(copied_record));
  }

  if (rc != RC::RECORD_EOF) {
    LOG_WARN("failed to fetch record from child operator. rc=%s", strrc(rc));
    child->close();
    return rc;
  }

  child->close();

  for (Record &old_record : records_) {
    Record new_record;
    rc = new_record.copy_data(old_record.data(), old_record.len());
    if (OB_FAIL(rc)) {
      LOG_WARN("failed to copy old record. rc=%s", strrc(rc));
      return rc;
    }
    new_record.set_rid(old_record.rid());

    rc = apply_value(new_record);
    if (OB_FAIL(rc)) {
      LOG_WARN("failed to apply value to record. rc=%s", strrc(rc));
      return rc;
    }

    rc = trx_->update_record(table_, old_record, new_record);
    if (OB_FAIL(rc)) {
      if (field_->type() == AttrType::TEXTS) {
        table_->delete_text(new_record.data() + field_->offset());
      }
      LOG_WARN("failed to update record by transaction. rid=%s, rc=%s", old_record.rid().to_string().c_str(), strrc(rc));
      return rc;
    }
  }

  return RC::SUCCESS;
}

RC UpdatePhysicalOperator::next() { return RC::RECORD_EOF; }

RC UpdatePhysicalOperator::close() { return RC::SUCCESS; }

RC UpdatePhysicalOperator::apply_value(Record &record)
{
  if (nullptr == field_) {
    LOG_WARN("invalid field meta");
    return RC::INTERNAL;
  }

  const int field_offset = field_->offset();
  const int field_len    = field_->len();
  if (field_offset < 0 || field_offset + field_len > record.len()) {
    LOG_WARN("invalid field offset/length. offset=%d, len=%d, record_len=%d", field_offset, field_len, record.len());
    return RC::INVALID_ARGUMENT;
  }

  if (field_->type() == AttrType::CHARS) {
    memset(record.data() + field_offset, 0, field_len);
    int copy_len = field_len;
    if (copy_len > value_.length()) {
      copy_len = value_.length() + 1;
    }
    memcpy(record.data() + field_offset, value_.data(), copy_len);
  } else if (field_->type() == AttrType::TEXTS) {
    memset(record.data() + field_offset, 0xFF, field_len);
    if (value_.length() > TEXT_MAX_BYTES) {
      LOG_WARN("text value too long for update. table=%s, field=%s, len=%d",
          table_->name(), field_->name(), value_.length());
      return RC::IOERR_TOO_LONG;
    }
    RC rc = table_->write_text(value_.data(), value_.length(), record.data() + field_offset);
    if (OB_FAIL(rc)) {
      LOG_WARN("failed to write text pages while updating record. table=%s, field=%s, rc=%s",
          table_->name(), field_->name(), strrc(rc));
      return rc;
    }
  } else {
    memcpy(record.data() + field_offset, value_.data(), field_len);
  }

  return RC::SUCCESS;
}
