#pragma once

#include "common/value.h"
#include "sql/operator/logical_operator.h"

class Table;
class FieldMeta;

/**
 * @brief 逻辑算子，用于执行update语句
 * @ingroup LogicalOperator
 */
class UpdateLogicalOperator : public LogicalOperator
{
public:
  UpdateLogicalOperator(Table *table, const FieldMeta *field, const Value &value);
  virtual ~UpdateLogicalOperator() = default;

  LogicalOperatorType type() const override { return LogicalOperatorType::UPDATE; }
  OpType              get_op_type() const override { return OpType::LOGICALUPDATE; }

  Table           *table() const { return table_; }
  const FieldMeta *field() const { return field_; }
  const Value     &value() const { return value_; }

private:
  Table           *table_ = nullptr;
  const FieldMeta *field_ = nullptr;
  Value            value_;
};
