#pragma once

#include "common/value.h"
#include "sql/operator/physical_operator.h"

class Table;
class FieldMeta;
class Trx;

/**
 * @brief 物理算子，更新
 * @ingroup PhysicalOperator
 */
class UpdatePhysicalOperator : public PhysicalOperator
{
public:
  UpdatePhysicalOperator(Table *table, const FieldMeta *field, const Value &value)
      : table_(table), field_(field), value_(value)
  {}
  virtual ~UpdatePhysicalOperator() = default;

  PhysicalOperatorType type() const override { return PhysicalOperatorType::UPDATE; }
  OpType               get_op_type() const override { return OpType::UPDATE; }

  RC open(Trx *trx) override;
  RC next() override;
  RC close() override;

  Tuple *current_tuple() override { return nullptr; }

private:
  RC apply_value(Record &record);

private:
  Table           *table_ = nullptr;
  const FieldMeta *field_ = nullptr;
  Value            value_;
  Trx             *trx_ = nullptr;
  vector<Record>   records_;
};
