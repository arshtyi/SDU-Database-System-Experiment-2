#import "dependency.typ": *
#import "template.typ": *

#show: report.with(
    institute: "计算机科学与技术",
    course: "数据库系统",
    student-id: "202400130242",
    student-name: "彭靖轩",
    date: datetime.today(),
    lab-title: "数据库系统内核实验",
    class: "24智能",
    email: link("mailto:arshtyi@foxmail.com"),
)
#let zebraw = zebraw.with(numbering-separator: true)

// #exp-block[
//     = 实验环境
//     - PowerShell: 7.6.0.
// ]

#exp-block[
    = 实验题目
    #link("https://open.oceanbase.com/train/detail/5?questionId=600004", "MiniOB 2023").
]

#exp-block[
    = 实验贡献
    均为个人完成.
]

#exp-block[
    = 实验1
    == Set Up
    拉取#link("https://github.com/oceanbase/miniob", "miniob")并推送至#link("https://github.com/arshtyi/SDU-Database-System-Experiment-2", "repo") (#link("https://gitee.com/arshtyi/SDU-Database-System-Experiment-2", "mirror"). 配置见手册与#link("https://help.gitee.com/repository/settings/sync-between-gitee-github", "sync help")).
    #zebraw(
        ```powershell
        git clone https://github.com/oceanbase/miniob.git
        rm -rf miniob/.git
        cp -r miniob/* ./
        rm -rf miniob
        ```,
    )
    配置好进行提测(题目1):
    #figure(image("asset/fig/1/judge_result/1.png"), caption: [实验1提测结果])<fig:exp1_judge_result_1>
    == 更新依赖
    如果要在本地进行后续实验,先更新需要的submodule:
    #zebraw(
        ```powershell
        git submodule update --init --recursive
        ```,
    )
    == #link("https://www.docker.com", "Docker")
    挂载项目目录并查看容器:
    #zebraw(
        ```powershell
        docker run -d --name miniob --privileged -v "${PWD}:/root/miniob" oceanbase/miniob
        docker ps
        docker exec -it miniob bash
        ```,
    )
    #figure(image("asset/fig/1/run_result/1.png"), caption: [实验1容器环境])<fig:exp1_run_result_1>
    // 还可以创建某一特定版本的容器方便开发.
    == #link("https://code.visualstudio.com", "VSCode") Configuration
    === Tasks <exp1:tasks>
    在VSCode中配置如下的Tasks(以源代码目录为工作目录):
    #zebraw(
        ```json
        {
            "version": "2.0.0",
            "tasks": [
                {
                    "label": "CMake: Configure",
                    "type": "shell",
                    "command": "cmake",
                    "args": [
                        "-S",
                        "${workspaceFolder}",
                        "-B",
                        "${workspaceFolder}/build",
                        "-DDEBUG=ON"
                    ],
                    "group": "build",
                    "presentation": {
                        "reveal": "always",
                        "panel": "shared",
                        "clear": true
                    }
                },
                {
                    "label": "CMake: Build",
                    "type": "shell",
                    "command": "cmake",
                    "args": [
                        "--build",
                        "${workspaceFolder}/build"
                    ],
                    "group": {
                        "kind": "build",
                        "isDefault": true
                    },
                    "dependsOn": [
                        "CMake: Configure"
                    ],
                    "dependsOrder": "sequence",
                    "presentation": {
                        "reveal": "always",
                        "panel": "shared",
                        "clear": false
                    }
                },
                {
                    "label": "Observer: PID",
                    "type": "shell",
                    "command": "pgrep",
                    "args": [
                        "-af",
                        "observer"
                    ],
                    "presentation": {
                        "reveal": "always",
                        "panel": "shared"
                    }
                },
                {
                    "label": "Observer: Run",
                    "type": "shell",
                    "command": "${workspaceFolder}/build/bin/observer",
                    "args": [
                        "-s",
                        "/root/miniob-test.sock",
                        "-f",
                        "${workspaceFolder}/etc/observer.ini"
                    ],
                    "options": {
                        "cwd": "${workspaceFolder}"
                    },
                    "presentation": {
                        "reveal": "always",
                        "panel": "dedicated"
                    }
                },
                {
                    "label": "Obclient: Run",
                    "type": "shell",
                    "command": "${workspaceFolder}/build/bin/obclient",
                    "args": [
                        "-s",
                        "/root/miniob-test.sock"
                    ],
                    "options": {
                        "cwd": "${workspaceFolder}"
                    },
                    "presentation": {
                        "reveal": "always",
                        "panel": "dedicated"
                    }
                }
            ]
        }
        ```,
    )
    上述Tasks配置了以下几个任务:
    - CMake
        + Configure: 配置CMake构建系统
        + Build: 构建项目,依赖于Configure
    - Observer
        + PID: 查看Observer进程
        + Run: 启动Observer服务端
    - Obclient
        + Run: 启动Obclient客户端
    === Debug <exp1:debug>
    在VSCode中配置Debug功能(以源代码目录为工作目录):
    #zebraw(
        ```json
        {
          "version": "0.2.0",
          "configurations": [
            {
              "name": "(gdb) Attach to observer",
              "type": "cppdbg",
              "request": "attach",
              "program": "${workspaceFolder}/build/bin/observer",
              "processId": "${command:pickProcess}",
              "MIMode": "gdb",
              "setupCommands": [
                {
                  "description": "Enable GDB pretty printing",
                  "text": "-enable-pretty-printing",
                  "ignoreFailures": true
                },
                {
                  "description": "Use Intel syntax for disassembly",
                  "text": "-gdb-set disassembly-flavor intel",
                  "ignoreFailures": true
                }
              ]
            }
          ]
        }
        ```,
    )
    上述Debug配置了一个调试配置"(gdb) Attach to observer",可以通过输入Observer进程的PID来附加到Observer进程进行调试.
    == Build
    运行CMake: Build构建项目(可以手动先运行CMake: Configure):
    #figure(image("asset/fig/1/build_result/1.png"), caption: [实验1构建结果])<fig:exp1_build_result_1>
    == Run
    运行Observer: Run启动服务端:
    #figure(image("asset/fig/1/run_result/2.png"), caption: [实验1服务端运行结果])<fig:exp1_run_result_2>
    接着运行Obclient: Run启动客户端:
    #figure(image("asset/fig/1/run_result/3.png"), caption: [实验1客户端运行结果])<fig:exp1_run_result_3>
    如此,完成了从拉取源代码到构建运行数据库系统.
    == Test
    使用下述命令测试数据库系统的基本功能:
    #zebraw(
        ```sql
        show tables;
        desc t;
        create table t (id int, name char(255));
        create index t_id on t (id);
        insert into t values (1, 'aaa');
        update t set name = 'bbb' where id = 1;
        delete from t where id = 1;
        select * from t;
        select id, name from t;
        ```,
    )
    #figure(image("asset/fig/1/run_result/4.png"), caption: [实验1测试结果])<fig:exp1_run_result_4>
    == Debug
    首先运行Observer: PID获得Observer进程的PID:
    #figure(image("asset/fig/1/run_result/5.png"), caption: [实验1调试结果])<fig:exp1_run_result_5>
    选择"(gdb) Attach to observer"并输入PID即可进入调试状态(出于方便,在`src/observer/net/plain_communicator.cpp`的```cpp PlainCommunicator::read_event(SessionEvent *&event)```打一断点)并运行```sql show tables;```测试:
    #figure(image("asset/fig/1/debug_result/1.png"), caption: [实验1调试结果])<fig:exp1_debug_result_1>
    == 总结
    实验1主要完成了从拉取源代码到构建运行数据库系统的全过程,并且在此过程中熟悉了Docker和VSCode的使用,为后续的开发和调试打下了基础.
]

#exp-block[
    = 实验2
    基于实验1的环境.
    == Drop Table
    === 实现
    声明删除表的接口:
    #zebraw(
        header: [src/observer/storage/db/db.h],
        numbering-offset: 71,
        ```cpp
        RC drop_table(const char *table_name);
        ```,
    )
    实现删除功能,包括删除元数据文件、数据文件、LOB文件及索引等:
    #zebraw(
        header: [src/observer/storage/db/db.cpp],
        numbering-offset: 178,
        ```cpp
        RC Db::drop_table(const char *table_name)
        {
          if (common::is_blank(table_name)) {
            LOG_WARN("invalid argument while dropping table. table_name=%p", table_name);
            return RC::INVALID_ARGUMENT;
          }
          auto iter = opened_tables_.find(table_name);
          if (iter == opened_tables_.end()) {
            LOG_WARN("no such table while dropping table. db=%s, table=%s", name_.c_str(), table_name);
            return RC::SCHEMA_TABLE_NOT_EXIST;
          }
          Table *table = iter->second;
          const TableMeta &table_meta = table->table_meta();
          vector<string> index_files;
          index_files.reserve(table_meta.index_num());
          for (int i = 0; i < table_meta.index_num(); i++) {
            const IndexMeta *index_meta = table_meta.index(i);
            if (index_meta != nullptr) {
              index_files.emplace_back(table_index_file(path_.c_str(), table_name, index_meta->name()));
            }
          }
          const string table_meta_path = table_meta_file(path_.c_str(), table_name);
          const string table_data_path = table_data_file(path_.c_str(), table_name);
          const string table_lob_path  = table_lob_file(path_.c_str(), table_name);
          opened_tables_.erase(iter);
          delete table;
          table = nullptr;
          RC rc = RC::SUCCESS;
          auto remove_file_if_exists = [table_name, &rc](const string &file_path) {
            if (rc != RC::SUCCESS) {
              return;
            }
            error_code ec;
            filesystem::remove(file_path, ec);
            if (ec) {
              LOG_ERROR("failed to remove file while dropping table. table=%s, file=%s, error=%s",
                  table_name, file_path.c_str(), ec.message().c_str());
              rc = RC::FILE_REMOVE;
            }
          };
          remove_file_if_exists(table_meta_path);
          remove_file_if_exists(table_data_path);
          remove_file_if_exists(table_lob_path);
          for (const string &index_file : index_files) {
            remove_file_if_exists(index_file);
          }
          if (OB_FAIL(rc)) {
            LOG_ERROR("failed to drop table due to file remove failed. db=%s, table=%s, rc=%s",
                name_.c_str(), table_name, strrc(rc));
            return rc;
          }
          LOG_INFO("drop table success. db=%s, table=%s", name_.c_str(), table_name);
          return RC::SUCCESS;
        }
        ```,
    )
    然后增加删除表的stmt:
    #zebraw(
        header: [src/observer/sql/stmt/drop_table_stmt.h],
        ```cpp
        #pragma once
        #include "common/lang/string.h"
        #include "sql/stmt/stmt.h"
        struct DropTableSqlNode;
        class DropTableStmt : public Stmt
        {
        public:
          explicit DropTableStmt(const string &table_name) : table_name_(table_name) {}
          virtual ~DropTableStmt() = default;
          StmtType type() const override { return StmtType::DROP_TABLE; }
          const string &table_name() const { return table_name_; }
          static RC create(Db *db, const DropTableSqlNode &drop_table, Stmt *&stmt);
        private:
          string table_name_;
        };
        ```,
    )
    #zebraw(
        header: [src/observer/sql/stmt/drop_table_stmt.cpp],
        ```cpp
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
        ```,
    )
    #zebraw(
        header: [src/observer/sql/parser/stmt.cpp],
        numbering: (
            ((23,) + range(76, 79)),
        ),
        ```cpp
        #include "sql/stmt/drop_table_stmt.h"
        case SCF_DROP_TABLE: {
          return DropTableStmt::create(db, sql_node.drop_table, stmt);
        }
        ```,
    )
    最后增加删除表的executor:
    #zebraw(
        header: [src/observer/sql/executor/drop_table_executor.h],
        ```cpp
        #pragma once
        #include "common/sys/rc.h"
        class SQLStageEvent;
        class DropTableExecutor
        {
        public:
          DropTableExecutor()          = default;
          virtual ~DropTableExecutor() = default;
          RC execute(SQLStageEvent *sql_event);
        };
        ```,
    )
    #zebraw(
        header: [src/observer/sql/executor/drop_table_executor.cpp],
        ```cpp
        #include "sql/executor/drop_table_executor.h"
        #include "common/log/log.h"
        #include "event/session_event.h"
        #include "event/sql_event.h"
        #include "session/session.h"
        #include "sql/stmt/drop_table_stmt.h"
        #include "storage/db/db.h"
        RC DropTableExecutor::execute(SQLStageEvent *sql_event)
        {
          Stmt *stmt = sql_event->stmt();
          ASSERT(stmt->type() == StmtType::DROP_TABLE,
              "drop table executor can not run this command: %d",
              static_cast<int>(stmt->type()));
          DropTableStmt *drop_table_stmt = static_cast<DropTableStmt *>(stmt);
          Session       *session         = sql_event->session_event()->session();
          return session->get_current_db()->drop_table(drop_table_stmt->table_name().c_str());
        }
        ```,
    )
    #zebraw(
        numbering-offset: 37,
        header: [src/observer/sql/executor/help_executor.cpp],
        ```cpp
        "drop table `table name`;",
        ```,
    )
    #zebraw(
        numbering-offset: 37,
        header: [src/observer/sql/executor/command_executor.cpp],
        numbering: (
            ((22,) + range(47, 51)),
        ),
        ```cpp
        #include "sql/executor/drop_table_executor.h"
        case StmtType::DROP_TABLE: {
          DropTableExecutor executor;
          rc = executor.execute(sql_event);
        } break;
        ```,
    )
    === Build
    编译配置同实验1, 直接运行CMake: Build即可:
    #figure(image("asset/fig/2/build_result/1.png"), caption: [实验2-1构建结果])<fig:exp2_build_result_1>
    随后运行Observer: Run和Obclient: Run启动服务端和客户端.
    === Test
    使用下述命令测试删除表功能:
    #zebraw(
        ```sql
        create table t(id int, age int);
        create table t(id int, name char);
        drop table t;
        create table t(id int, name char);
        ```,
    )
    #figure(image("asset/fig/2/run_result/1.png"), caption: [实验2-1测试结果])<fig:exp2_run_result_1>
    @fig:exp2_run_result_1 证明了删除表功能的正确性:成功删除了表t并重新创建了表t.
    === 提测
    推送至仓库并提测(题目3):
    #figure(image("asset/fig/2/judge_result/1.png"), caption: [实验2-1提测结果])<fig:exp2_judge_result_1>
    == Date
    === 实现
    增加类型枚举与注册:
    #zebraw(
        header: [src/observer/common/type/attr_type.h],
        numbering-offset: 22,
        ```cpp
        DATES,     ///< 日期类型(4字节, YYYYMMDD)
        ```,
    )
    #zebraw(
        header: [src/observer/common/type/attr_type.cpp],
        numbering-offset: 14,
        ```cpp
        const char *ATTR_TYPE_NAME[] = {"undefined", "chars", "ints", "floats", "dates", "vectors", "booleans"};
        ```,
    )
    #zebraw(
        header: [src/observer/common/type/data_type.cpp],
        numbering: ((12, 26),),
        ```cpp
        #include "common/type/date_type.h"
        make_unique<DateType>(),
        ```,
    )
    实现类型(4字节 *YYYYMMDD* 存储、比较、字符串化、解析校验、闰年):
    #zebraw(
        header: [src/observer/common/type/date_type.h],
        ```cpp
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
          RC cast_to(const Value &val, AttrType type, Value &result) const override;
          int cast_cost(AttrType type) override;
          RC set_value_from_str(Value &val, const string &data) const override;
          RC to_string(const Value &val, string &result) const override;
          static RC parse_date(const string &data, int32_t &packed_date);
          static bool is_valid_packed_date(int32_t packed_date);
        private:
          static bool is_leap_year(int64_t year);
          static int  days_in_month(int64_t year, int64_t month);
        };
        ```,
    )
    #zebraw(
        header: [src/observer/common/type/date_type.cpp],
        ```cpp
        #include "common/type/date_type.h"
        #include <cstdint>
        #include "common/lang/comparator.h"
        #include "common/lang/iomanip.h"
        #include "common/lang/sstream.h"
        #include "common/log/log.h"
        #include "common/value.h"
        #include "storage/common/column.h"
        bool DateType::is_leap_year(int64_t year)
        {
          return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        }
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
          ss << setw(4) << setfill('0') << year << "-" << setw(2) << setfill('0') << month << "-" << setw(2) << setfill('0') << day;
          result = ss.str();
          return RC::SUCCESS;
        }
        ```,
    )
    提供Value支持:
    #zebraw(
        header: [src/observer/common/value.h],
        numbering: ((38, 112, 120),),
        ```cpp
        friend class DateType;
        int      get_date() const;
        void set_date(int val);
        ```,
    )
    #zebraw(
        header: [src/observer/common/value.cpp],
        numbering: (
            (
                range(123, 127)
                    + range(149, 156)
                    + range(212, 215)
                    + range(279, 282)
                    + range(296, 303)
                    + range(318, 321)
                    + range(367, 370)
            ),
        ),
        ```cpp
        case AttrType::DATES: {
          value_.int_value_ = *(int *)data;
          length_           = length;
        } break;
        void Value::set_date(int val)
        {
          reset();
          attr_type_        = AttrType::DATES;
          value_.int_value_ = val;
          length_           = sizeof(val);
        }
        case AttrType::DATES: {
          set_date(value.get_date());
        } break;
        case AttrType::DATES: {
          return value_.int_value_;
        }
        int Value::get_date() const
        {
        if (attr_type_ == AttrType::DATES) {
            return value_.int_value_;
        }
        return get_int();
        }
        case AttrType::DATES: {
          return float(value_.int_value_);
        } break;
        case AttrType::DATES: {
          return value_.int_value_ != 0;
        } break;
        ```,
    )
    增加隐式类型转换支持:
    #zebraw(
        header: [src/observer/common/type/char_type.cpp],
        numbering: ((14,) + range(33, 42) + range(52, 55),),
        ```cpp
        #include "common/type/date_type.h"
        case AttrType::DATES: {
          int packed_date = 0;
          RC  rc          = DateType::parse_date(val.get_string(), packed_date);
          if (OB_FAIL(rc)) {
            return rc;
          }
          result.set_date(packed_date);
          return RC::SUCCESS;
        }
        if (type == AttrType::DATES) {
          return 1;
        }
        ```,
    )
    接着修改词法分析器和语法分析器支持日期类型:
    #zebraw(
        header: [src/observer/sql/parser/lex_sql.l],
        numbering-offset: 113,
        ```lex
        DATE                                    RETURN_TOKEN(DATE_T);
        ```,
    )
    #zebraw(
        header: [src/observer/sql/parser/yacc_sql.y],
        numbering: ((91, 384),),
        ```yacc
        DATE_T
        | DATE_T   { $$ = static_cast<int>(AttrType::DATES); }
        ```,
    )
    最后增加日期类型的比较和编码支持:
    #zebraw(
        header: [src/observer/sql/expr/expression.cpp],
        numbering-offset: 241,
        ```cpp
          rc = compare_column<int>(left_column, right_column, select);
        } else if (left_column.attr_type() == AttrType::DATES) {
        ```,
    )
    #zebraw(
        header: [src/observer/storage/common/codec.h],
        numbering-offset: 425,
        ```cpp
        case AttrType::DATES:
          if (OB_FAIL(OrderedCode::append(dst, (int64_t)val.get_date()))) {
            LOG_WARN("append failed");
          }
          break;
        ```,
    )
    === Build
    编译配置同实验1, 直接运行CMake: Build即可:
    #figure(image("asset/fig/2/build_result/2.png"), caption: [实验2-2构建结果])<fig:exp2_build_result_2>
    === Test
    使用下述命令测试日期类型:
    ```sql
    create table t(id int, d date);
    insert into t values(1, '1970-01-01');
    insert into t values(2, '2400-02-29');
    insert into t values(3, '2023-02-29');
    select * from t where d >= '2000-01-01';
    create index idx_d on t(d);
    select * from t where d = '2400-02-29';
    select * from t where d = '2024-13-01';
    drop table t;
    ```
    #figure(image("asset/fig/2/run_result/2.png"), caption: [实验2-2测试结果])<fig:exp2_run_result_2>
    @fig:exp2_run_result_2 证明了日期类型的正确性:成功创建了表t并插入了日期数据,查询和索引也正常工作,同时不合法的日期被正确拒绝.
    === 提测
    推送至仓库并提测(题目4):
    #figure(image("asset/fig/2/judge_result/2.png"), caption: [实验2-2提测结果])<fig:exp2_judge_result_2>
]
