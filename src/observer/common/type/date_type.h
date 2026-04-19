#pragma once

#include <cstdint>

#include "common/type/data_type.h"

/**
 * @brief 日期类型
 * @ingroup DataType
 * @details 内部使用 int32 编码为 YYYYMMDD
 */
class DateType : public DataType
{
public:
  DateType() : DataType(AttrType::DATES) {}
  virtual ~DateType() = default;

  int compare(const Value &left, const Value &right) const override;
  int compare(const Column &left, const Column &right, int left_idx, int right_idx) const override;

  RC  cast_to(const Value &val, AttrType type, Value &result) const override;
  int cast_cost(AttrType type) override;

  RC set_value_from_str(Value &val, const string &data) const override;
  RC to_string(const Value &val, string &result) const override;

  static RC   parse_date(const string &data, int32_t &packed_date);
  static bool is_valid_packed_date(int32_t packed_date);

private:
  static bool is_leap_year(int64_t year);
  static int  days_in_month(int64_t year, int64_t month);
};
