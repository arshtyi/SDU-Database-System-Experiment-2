#include "sql/operator/update_logical_operator.h"

UpdateLogicalOperator::UpdateLogicalOperator(Table *table, const FieldMeta *field, const Value &value)
    : table_(table), field_(field), value_(value)
{}
