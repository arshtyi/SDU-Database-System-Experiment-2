#include "sql/stmt/drop_table_stmt.h"

#include "common/lang/string.h"
#include "common/log/log.h"
#include "storage/db/db.h"

using namespace common;

RC DropTableStmt::create(Db *db, const DropTableSqlNode &drop_table, Stmt *&stmt)
{
  stmt = nullptr;

  const char *table_name = drop_table.relation_name.c_str();
  if (db == nullptr || is_blank(table_name)) {
    LOG_WARN("invalid argument while creating drop table stmt. db=%p, table_name=%p", db, table_name);
    return RC::INVALID_ARGUMENT;
  }

  if (db->find_table(table_name) == nullptr) {
    LOG_WARN("no such table while creating drop table stmt. db=%s, table=%s", db->name(), table_name);
    return RC::SCHEMA_TABLE_NOT_EXIST;
  }

  stmt = new DropTableStmt(drop_table.relation_name);
  return RC::SUCCESS;
}
