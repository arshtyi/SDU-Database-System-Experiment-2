/**
 * typst: 0.14.2
 */

#import "dependency.typ": *

// Define some variables for the report
#let institute = "计算机科学与技术"
#let course = "数据库系统"
#let student-id = "202400130242"
#let student-name = "彭靖轩"
#let date = datetime.today()
#let lab-title = "数据库系统内核实验"
#let class = "24智能"
#let email = link("mailto:arshtyi@foxmail.com")
#let font = (
    main: "IBM Plex Serif",
    mono: "Fira Code",
    cjk: "Noto Serif CJK SC",
    math: "New Computer Modern Math",
)
#let _highlight-colors = (
    rgb("#dafbe1"),
    rgb("#ddf4ff"),
    rgb("#fbefff"),
    rgb("#fff8c5"),
)

// Set up styles
#set document(title: lab-title, author: student-name)
#set text(
    font: (font.main, font.cjk),
    size: 11pt,
    lang: "en",
    region: "us",
)
#set smartquote(quotes: "\"\"")
#set page(
    paper: "a4",
    margin: (x: 35pt, y: 35pt),
    footer: context {
        set align(center)
        set text(9pt)
        counter(page).display("1 / 1", both: true)
    },
)
#set heading(
    numbering: numbly(
        "{1:1}",
        "{2:1}.",
        "({3:1})",
    ),
)
#show heading.where(level: 1): it => block(above: .6em, it.body)
#show heading: it => if (it.level == 1) {
    set align(center)
    show h.where(amount: .3em): none
    text(size: 15pt, it)
} else { text(size: 13pt, it) }
#show heading.where(level: 1): set heading(supplement: [实验])
#set figure(numbering: dependent-numbering("1 - 1"))
#show heading: reset-counter(counter(figure.where(kind: image)))
#show heading: reset-counter(counter(figure.where(kind: table)))
#set par(justify: true, first-line-indent: (amount: 2em, all: true))
#set raw(syntaxes: "highlight/PowerShell.sublime-syntax")
#show raw: set text(font: ((name: font.mono, covers: "latin-in-cjk"), font.cjk))
#show link: it => text(fill: blue.darken(30%), style: "italic", underline(evade: false, it))
#set list(indent: 6pt, marker: sym.bullet.tri)
#set enum(indent: 6pt, numbering: numbly(n => emph(strong(numbering("1.", n)))))
#{
    show heading: it => align(center)[#text(size: 18pt, tracking: 0.1em, weight: "bold", it)]
    heading(
        numbering: none,
        depth: 1,
        bookmarked: false,
        outlined: false,
    )[ #institute 学院 #underline(offset: 4pt, extent: 6pt, [#course]) 课程实验报告]
    set text(size: 12pt)
    set table.cell(align: left + horizon, inset: 6pt)
    table(
        columns: (1fr, 1fr, 1fr),
        table.cell(colspan: 2)[题目: #lab-title], [学号: #student-id],
        [日期: #date.display("[year].[month].[day]")], [班级: #class], [姓名: #student-name],
        [Email: #email],
        [题目: #link("https://open.oceanbase.com/train/detail/5?questionId=600004", "miniob 2023")],
        [贡献: 个人完成],
        [MiniOB Hash: #link("https://github.com/oceanbase/miniob/tree/9f856a542decb6dc678650406af7d6e351940dab", "9f856a5")],
        [Source: #link("https://github.com/arshtyi/SDU-Database-System-Experiment-2", "gitHub")],
        [Mirror: #link("https://gitee.com/arshtyi/SDU-Database-System-Experiment-2", "gitee")],
    )
}

// Let line numbers be more visible and add highlight for changed lines
#let zebraw = zebraw.with(
    numbering-separator: true,
    radius: 10pt,
    lang: false,
    highlight-color: _highlight-colors,
)
#let _jump-highlight-lines(numbering: none, column: 0) = {
    if numbering == none or numbering == auto or numbering == false {
        return ()
    }
    let cols = if type(numbering) == array and numbering.len() > 0 and type(numbering.at(0)) == array {
        numbering
    } else if type(numbering) == array {
        (numbering,)
    } else {
        panic(
            "zebraw-jump: numbering must be none / false / array / array of arrays. "
                + "If you only want to set the starting line number, please pass numbering-offset.",
        )
    }
    if column >= cols.len() {
        panic("zebraw-jump: column out of range of numbering columns")
    }
    let nums = cols.at(column)
    if nums.len() == 0 {
        return ()
    }
    let res = (1,)
    let jump-count = 1
    for i in range(1, nums.len()) {
        let prev = nums.at(i - 1)
        let curr = nums.at(i)
        if type(prev) != int or type(curr) != int or curr != prev + 1 {
            jump-count += 1
            res.push(i + 1)
        }
    }
    if jump-count < 2 {
        return ()
    }
    res
}
#let zebraw-jump(..args) = {
    let pos = args.pos()
    if pos.len() != 1 {
        panic("zebraw-jump requires exactly one code block argument")
    }
    let named = args.named()
    let has-numbering = "numbering" in named
    let has-numbering-offset = "numbering-offset" in named
    let column = if "column" in named { named.at("column") } else { 0 }
    if "column" in named {
        named.remove("column")
    }
    if not has-numbering and not has-numbering-offset {
        return zebraw(
            ..named,
            pos.at(0),
        )
    }
    let numbering = if has-numbering { named.at("numbering") } else { none }
    let hl = _jump-highlight-lines(numbering: numbering, column: column)
    if hl.len() == 0 {
        zebraw(
            ..named,
            pos.at(0),
        )
    } else {
        zebraw(
            ..named,
            highlight-lines: hl,
            pos.at(0),
        )
    }
}

= Experiment 1 <exp1>
实验内容:
+ 完成从拉取源代码到构建运行数据库系统的全过程.
+ 熟悉#link("https://www.docker.com", "Docker")和#link("https://code.visualstudio.com", "VSCode")的使用,为后续的开发和调试打下基础.
+ 提测#link("https://open.oceanbase.com/train/TopicDetails?questionId=600004&subQesitonId=800004&subQuestionName=basic", "题目1").
== Setup
拉取#link("https://github.com/oceanbase/miniob", "miniob")并推送至#link("https://github.com/arshtyi/SDU-Database-System-Experiment-2", "repo") (#link("https://gitee.com/arshtyi/SDU-Database-System-Experiment-2", "mirror"). 配置见手册与#link("https://help.gitee.com/repository/settings/sync-between-gitee-github", "sync help")).
#zebraw-jump(
    ```powershell
    git clone https://github.com/oceanbase/miniob.git
    rm -rf miniob/.git
    cp -r miniob/* ./
    rm -rf miniob
    ```,
)
配置好即可进行提测:
#figure(image("asset/fig/1/judge_result/1.png"), caption: [实验1提测结果])<fig:exp1_judge_result_1>
== 更新依赖
如果要在本地进行后续实验,先更新需要的submodule:
#zebraw-jump(
    ```powershell
    git submodule update --init --recursive
    ```,
)
== Docker
挂载项目目录并查看容器:
#zebraw-jump(
    ```powershell
    docker run -d --name miniob --privileged -v "${PWD}:/root/miniob" oceanbase/miniob
    docker ps
    docker exec -it miniob bash
    ```,
)
#figure(image("asset/fig/1/run_result/1.png"), caption: [实验1容器环境])<fig:exp1_run_result_1>
== VSCode Configuration
=== Tasks
在VSCode中配置如下的Tasks:
#zebraw-jump(
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
=== Debug
在VSCode中配置Debug功能:
#zebraw-jump(
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
#zebraw-jump(
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
@exp1 主要完成了从拉取源代码到构建运行数据库系统的全过程,并且在此过程中熟悉了Docker和VSCode的使用,为后续的开发和调试打下了基础.

= Experiment 2 <exp2>
基于@exp1.

实验内容:
+ 实现删除表功能,包括删除元数据文件、数据文件、LOB文件及索引等.
+ 增加日期类型,支持日期的存储、比较、字符串化、解析校验、隐式类型转换等功能.
+ 提测#link("https://open.oceanbase.com/train/TopicDetails?questionId=600004&subQesitonId=800006&subQuestionName=drop-table", "题目3")和#link("https://open.oceanbase.com/train/TopicDetails?questionId=600004&subQesitonId=800005&subQuestionName=date", "题目2").
== Drop Table
=== 实现
实现删除功能,包括删除元数据文件、数据文件、LOB文件及索引等:
#zebraw-jump(
    header: [src/observer/storage/db/db.h],
    numbering-offset: 71,
    ```cpp
    RC drop_table(const char *table_name);
    ```,
)
#zebraw-jump(
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
#zebraw-jump(
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
#zebraw-jump(
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
#zebraw-jump(
    header: [src/observer/sql/parser/stmt.cpp],
    numbering: (((23,) + range(76, 79)),),
    ```cpp
    #include "sql/stmt/drop_table_stmt.h"
    case SCF_DROP_TABLE: {
      return DropTableStmt::create(db, sql_node.drop_table, stmt);
    }
    ```,
)
最后增加删除表的executor:
#zebraw-jump(
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
#zebraw-jump(
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
#zebraw-jump(
    header: [src/observer/sql/executor/help_executor.cpp],
    numbering-offset: 37,
    ```cpp
    "drop table `table name`;",
    ```,
)
#zebraw-jump(
    header: [src/observer/sql/executor/command_executor.cpp],
    numbering: (((22,) + range(47, 51)),),
    ```cpp
    #include "sql/executor/drop_table_executor.h"
    case StmtType::DROP_TABLE: {
      DropTableExecutor executor;
      rc = executor.execute(sql_event);
    } break;
    ```,
)
=== Build
编译配置同@exp1, 直接运行CMake: Build即可:
#figure(image("asset/fig/2/build_result/1.png"), caption: [实验2 - 1构建结果])<fig:exp2_build_result_1>
随后运行Observer: Run和Obclient: Run启动服务端和客户端.
=== Test
使用下述命令测试删除表功能:
#zebraw-jump(
    ```sql
    create table t(id int, age int);
    create table t(id int, name char);
    drop table t;
    create table t(id int, name char);
    ```,
)
#figure(image("asset/fig/2/run_result/1.png"), caption: [实验2 - 1测试结果])<fig:exp2_run_result_1>
@fig:exp2_run_result_1 证明了删除表功能的正确性:成功删除了表t并重新创建了表t.
=== 提测
推送至仓库并提测:
#figure(image("asset/fig/2/judge_result/1.png"), caption: [实验2 - 1提测结果])<fig:exp2_judge_result_1>
== Date
=== 实现
增加类型枚举与注册:
#zebraw-jump(
    header: [src/observer/common/type/attr_type.h],
    numbering-offset: 22,
    ```cpp
    DATES,     ///< 日期类型(4字节, YYYYMMDD)
    ```,
)
#zebraw-jump(
    header: [src/observer/common/type/attr_type.cpp],
    numbering-offset: 14,
    ```cpp
    const char *ATTR_TYPE_NAME[] = {"undefined", "chars", "ints", "floats", "dates", "vectors", "booleans"};
    ```,
)
#zebraw-jump(
    header: [src/observer/common/type/data_type.cpp],
    numbering: ((12, 26),),
    ```cpp
    #include "common/type/date_type.h"
    make_unique<DateType>(),
    ```,
)
实现类型(4字节 *YYYYMMDD* 存储、比较、字符串化、解析校验、闰年):
#zebraw-jump(
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
#zebraw-jump(
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
#zebraw-jump(
    header: [src/observer/common/value.h],
    numbering: ((38, 112, 120),),
    ```cpp
    friend class DateType;
    int      get_date() const;
    void set_date(int val);
    ```,
)
#zebraw-jump(
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
#zebraw-jump(
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
#zebraw-jump(
    header: [src/observer/sql/parser/lex_sql.l],
    numbering-offset: 113,
    ```lex
    DATE                                    RETURN_TOKEN(DATE_T);
    ```,
)
#zebraw-jump(
    header: [src/observer/sql/parser/yacc_sql.y],
    numbering: ((91, 384),),
    ```yacc
    DATE_T
    | DATE_T   { $$ = static_cast<int>(AttrType::DATES); }
    ```,
)
最后增加日期类型的比较和编码支持:
#zebraw-jump(
    header: [src/observer/sql/expr/expression.cpp],
    numbering-offset: 241,
    ```cpp
      rc = compare_column<int>(left_column, right_column, select);
    } else if (left_column.attr_type() == AttrType::DATES) {
    ```,
)
#zebraw-jump(
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
编译配置同@exp1, 直接运行CMake: Build即可:
#figure(image("asset/fig/2/build_result/2.png"), caption: [实验2-2构建结果])<fig:exp2_build_result_2>
接下来运行Observer: Run和Obclient: Run启动服务端和客户端.
=== Test
使用下述命令测试日期类型:
#zebraw-jump(
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
    ```,
)
#figure(image("asset/fig/2/run_result/2.png"), caption: [实验2-2测试结果])<fig:exp2_run_result_2>
@fig:exp2_run_result_2 证明了日期类型的正确性:成功创建了表t并插入了日期数据,查询和索引也正常工作,同时不合法的日期被正确拒绝.
=== 提测
推送至仓库并提测:
#figure(image("asset/fig/2/judge_result/2.png"), caption: [实验2-2提测结果])<fig:exp2_judge_result_2>
== 总结
@exp2 主要实现了删除表功能和日期类型,并且在此过程中熟悉了数据库系统中DDL操作和数据类型实现的相关知识,同时通过测试验证了功能的正确性.
