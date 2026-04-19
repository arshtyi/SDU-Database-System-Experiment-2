#include "common/type/date_type.h"

#include <cstdint>

#include "common/lang/comparator.h"
#include "common/lang/iomanip.h"
#include "common/lang/sstream.h"
#include "common/log/log.h"
#include "common/value.h"
#include "storage/common/column.h"

bool DateType::is_leap_year(int64_t year) { return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0); }

int DateType::days_in_month(int64_t year, int64_t month)
{
  static const int kDaysInMonth[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
  if (month < 1 || month > 12) {
    return 0;
  }

  if (month == 2 && is_leap_year(year)) {
    return 29;
  }
  return kDaysInMonth[month];
}

RC DateType::parse_date(const string &data, int32_t &packed_date)
{
  size_t sep1 = data.find('-');
  if (sep1 == string::npos) {
    return RC::SCHEMA_FIELD_TYPE_MISMATCH;
  }

  size_t sep2 = data.find('-', sep1 + 1);
  if (sep2 == string::npos || data.find('-', sep2 + 1) != string::npos) {
    return RC::SCHEMA_FIELD_TYPE_MISMATCH;
  }

  string year_str  = data.substr(0, sep1);
  string month_str = data.substr(sep1 + 1, sep2 - sep1 - 1);
  string day_str   = data.substr(sep2 + 1);

  if (year_str.empty() || month_str.empty() || day_str.empty()) {
    return RC::SCHEMA_FIELD_TYPE_MISMATCH;
  }

  auto parse_positive_int = [](const string &part, int64_t &num) -> RC {
    num = 0;
    for (char ch : part) {
      if (ch < '0' || ch > '9') {
        return RC::SCHEMA_FIELD_TYPE_MISMATCH;
      }
      num = num * 10 + (ch - '0');
      if (num > INT32_MAX) {
        return RC::SCHEMA_FIELD_TYPE_MISMATCH;
      }
    }
    return RC::SUCCESS;
  };

  int64_t year  = 0;
  int64_t month = 0;
  int64_t day   = 0;
  RC      rc    = RC::SUCCESS;
  if (OB_FAIL(parse_positive_int(year_str, year))) {
    return rc;
  }
  if (OB_FAIL(parse_positive_int(month_str, month))) {
    return rc;
  }
  if (OB_FAIL(parse_positive_int(day_str, day))) {
    return rc;
  }

  if (year <= 0 || month < 1 || month > 12) {
    return RC::SCHEMA_FIELD_TYPE_MISMATCH;
  }

  const int max_day = days_in_month(year, month);
  if (day < 1 || day > max_day) {
    return RC::SCHEMA_FIELD_TYPE_MISMATCH;
  }

  int64_t encoded = year * 10000 + month * 100 + day;
  if (encoded > INT32_MAX) {
    return RC::SCHEMA_FIELD_TYPE_MISMATCH;
  }

  packed_date = static_cast<int32_t>(encoded);
  return RC::SUCCESS;
}

bool DateType::is_valid_packed_date(int32_t packed_date)
{
  if (packed_date <= 0) {
    return false;
  }

  int64_t year  = packed_date / 10000;
  int64_t month = (packed_date / 100) % 100;
  int64_t day   = packed_date % 100;
  if (year <= 0 || month < 1 || month > 12) {
    return false;
  }
  return day >= 1 && day <= days_in_month(year, month);
}

int DateType::compare(const Value &left, const Value &right) const
{
  ASSERT(left.attr_type() == AttrType::DATES, "left type is not date");
  ASSERT(right.attr_type() == AttrType::DATES, "right type is not date");
  int left_date  = left.get_date();
  int right_date = right.get_date();
  return common::compare_int(&left_date, &right_date);
}

int DateType::compare(const Column &left, const Column &right, int left_idx, int right_idx) const
{
  ASSERT(left.attr_type() == AttrType::DATES, "left type is not date");
  ASSERT(right.attr_type() == AttrType::DATES, "right type is not date");
  return common::compare_int((void *)&((int *)left.data())[left_idx], (void *)&((int *)right.data())[right_idx]);
}

RC DateType::cast_to(const Value &val, AttrType type, Value &result) const
{
  switch (type) {
    case AttrType::DATES: {
      result.set_date(val.get_date());
      return RC::SUCCESS;
    }
    case AttrType::CHARS: {
      string str;
      RC     rc = to_string(val, str);
      if (OB_FAIL(rc)) {
        return rc;
      }
      result.set_string(str.c_str());
      return RC::SUCCESS;
    }
    default: {
      return RC::SCHEMA_FIELD_TYPE_MISMATCH;
    }
  }
}

int DateType::cast_cost(AttrType type)
{
  if (type == AttrType::DATES) {
    return 0;
  }
  return INT32_MAX;
}

RC DateType::set_value_from_str(Value &val, const string &data) const
{
  int32_t packed_date = 0;
  RC      rc          = parse_date(data, packed_date);
  if (OB_FAIL(rc)) {
    return rc;
  }
  val.set_date(packed_date);
  return RC::SUCCESS;
}

RC DateType::to_string(const Value &val, string &result) const
{
  int32_t packed_date = val.get_date();
  if (!is_valid_packed_date(packed_date)) {
    return RC::SCHEMA_FIELD_TYPE_MISMATCH;
  }

  int32_t year  = packed_date / 10000;
  int32_t month = (packed_date / 100) % 100;
  int32_t day   = packed_date % 100;

  stringstream ss;
  ss << setw(4) << setfill('0') << year << "-" << setw(2) << setfill('0') << month << "-" << setw(2) << setfill('0')
     << day;
  result = ss.str();
  return RC::SUCCESS;
}
