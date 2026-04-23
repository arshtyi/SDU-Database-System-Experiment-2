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
// #let date = datetime(year: 2026, month: 4, day: 18)
#let lab-title = "数据库系统内核实验"
#let class = "24智能"
#let email = link("mailto:arshtyi@foxmail.com")
#let font = (
    main: "IBM Plex Serif",
    mono: "Fira Code",
    cjk: "Noto Serif CJK SC",
    math: "New Computer Modern Math",
)

// Color palette
#let palette = (
    link: rgb("#1D4F91"),
    ref: rgb("#6A3FB5"),
    highlight: (
        rgb("#DCEEFF"), // blue
        rgb("#DFF3F0"), // teal
        rgb("#ECE7FF"), // violet
        rgb("#EAF4D8"), // olive
    ),
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
    margin: (x: 25pt, y: 25pt),
    footer: context {
        set align(center)
        set text(9pt)
        counter(page).display("1 / 1", both: true)
    },
    header: counter(footnote).update(0),
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
} else {
    text(size: 13pt, it)
}
#show heading.where(level: 1): set heading(supplement: [实验])
#set figure(numbering: dependent-numbering("1 - 1"))
#show heading: reset-counter(counter(figure.where(kind: image)))
#show heading: reset-counter(counter(figure.where(kind: table)))
#set par(justify: true, first-line-indent: (amount: 2em, all: true))
#set raw(syntaxes: "highlight/PowerShell.sublime-syntax")
#show raw: set text(font: ((name: font.mono, covers: "latin-in-cjk"), font.cjk))
#show link: it => text(fill: palette.link, style: "italic", underline(evade: false, it))
#show ref: set text(fill: palette.ref)
#let cite = cite.with(style: "ieee")
#set footnote(numbering: "[1]")
#set list(indent: 6pt, marker: sym.bullet.tri)
#set enum(indent: 6pt, numbering: numbly(n => emph(strong(numbering("1.", n)))))

#{
    show heading: it => align(center)[#text(size: 18pt, tracking: 0.1em, weight: "bold", it)]
    heading(
        numbering: none,
        level: 1,
        bookmarked: false,
        outlined: false,
    )[#institute 学院 #underline(offset: 4pt, extent: 6pt, [#course]) 课程实验报告]
    set text(size: 12pt)
    set table.cell(align: left + horizon, inset: 6pt)
    table(
        columns: (1fr,) * 3,
        table.cell(colspan: 2)[题目: #lab-title], [学号: #student-id],
        [日期: #date.display("[year].[month].[day]")], [班级: #class], [姓名: #student-name],
        [Email: #email],
        [题目: #link("https://open.oceanbase.com/train/detail/17?questionId=600060", "miniob 2025")],
        [贡献: 个人完成],
        [miniob: #link("https://github.com/oceanbase/miniob/tree/9f856a542decb6dc678650406af7d6e351940dab", "9f856a5")],
        [Source: #link("https://github.com/arshtyi/SDU-Database-System-Experiment-2", "github")],
        [Mirror: #link("https://gitee.com/arshtyi/SDU-Database-System-Experiment-2", "gitee(private)")],
    )
    let _commit-hash-table-rows(path: "commit/hash.txt") = {
        let rows = ()
        for line in read(path).split("\n") {
            let trimmed = line.trim()
            if trimmed == "" {
                continue
            }
            let columns = trimmed.split(",")
            if columns.len() != 3 {
                panic("invalid commit hash row: " + trimmed)
            }
            let exp = columns.at(0)
            let exp-no = exp.replace("exp", "")
            let branch = columns.at(1)
            let branch-name = branch.replace("remotes/origin/", "").replace("origin/", "")
            let hash = columns.at(2)
            let hash-head = if hash.len() >= 7 { hash.slice(0, 7) } else { hash }
            rows.push([#exp-no])
            rows.push([#branch-name])
            rows.push([
                #link("https://github.com/arshtyi/SDU-Database-System-Experiment-2/tree/" + hash, "github:" + hash-head)
                #h(0.8em)
                #link("https://gitee.com/arshtyi/SDU-Database-System-Experiment-2/tree/" + hash, "gitee:" + hash-head)
            ])
        }
        rows
    }
    set table.cell(align: center + horizon)
    align(center)[
        #table(
            columns: 3,
            [#sym.hash], [branch], [hash],
            .._commit-hash-table-rows(),
        )
    ]
}

// Let line numbers be more visible and add highlight for changed lines
#let zebraw = zebraw.with(
    numbering-separator: true,
    radius: 10pt,
    lang: false,
    highlight-color: palette.highlight,
)
#let _normalize-numbering-cols(numbering) = {
    if numbering == none or numbering == auto or numbering == false {
        return ()
    }
    if type(numbering) == array and numbering.len() > 0 and type(numbering.at(0)) == array {
        numbering
    } else if type(numbering) == array {
        (numbering,)
    } else {
        panic(
            "zebraw-jump: numbering must be none / false / array / array of arrays. "
                + "If you only want to set the starting line number, please pass numbering-offset.",
        )
    }
}
#let _is-continuous-step(prev, curr) = {
    if type(prev) == int and type(curr) == int {
        curr == prev or curr == prev + 1
    } else if prev == none and curr == none {
        true
    } else {
        false
    }
}
#let _row-number(cols, idx) = {
    for col in cols {
        let value = col.at(idx)
        if type(value) == int {
            return value
        }
    }
    none
}
#let _jump-highlight-lines-core(cols) = {
    if cols.len() == 0 {
        return ()
    }
    let line-count = cols.at(0).len()
    for col in cols {
        assert(col.len() == line-count, message: "zebraw-jump: numbering columns length mismatch")
    }
    if line-count == 0 {
        return ()
    }
    let marks = (1,)
    for line-no in range(2, line-count + 1) {
        let idx = line-no - 1
        let prev-idx = idx - 1
        let prev = _row-number(cols, prev-idx)
        let curr = _row-number(cols, idx)
        if not _is-continuous-step(prev, curr) {
            marks.push(line-no)
        }
    }
    if marks.len() < 2 {
        return ()
    }
    marks
}
#let _jump-highlight-lines(numbering: none, column: 0) = {
    let cols = _normalize-numbering-cols(numbering)
    if cols.len() == 0 {
        return ()
    }
    if column >= cols.len() {
        panic("zebraw-jump: column out of range of numbering columns")
    }
    _jump-highlight-lines-core((cols.at(column),))
}
#let _jump-highlight-lines-all(numbering: none) = {
    let cols = _normalize-numbering-cols(numbering)
    _jump-highlight-lines-core(cols)
}
#let _raw-file-key(filepath) = {
    let normalized = filepath.replace("\\", "/")
    normalized.replace("/", "-")
}
#let _raw-numbering(line) = {
    let trimmed = line.trim()
    if trimmed == "" { () } else { eval(trimmed) }
}
#let _display-numbering(numbering) = {
    let cols = _normalize-numbering-cols(numbering)
    cols.map(col => col.map(v => if type(v) == int { v } else { [ ] }))
}
#let zebraw-file(filepath) = context {
    let heading-no = counter(heading).get().at(0, default: 0)
    let raw-path = "raw/" + str(heading-no) + "/" + _raw-file-key(filepath) + ".txt"
    let data = read(raw-path)
    let lines = data.split("\n")
    if lines.len() < 2 {
        panic("raw diff typ file is empty: " + raw-path)
    }
    let numbering = _raw-numbering(lines.at(0))
    let display-numbering = _display-numbering(numbering)
    let block = lines.slice(1).join("\n").trim()
    let hl = _jump-highlight-lines-all(numbering: numbering)
    if hl.len() == 0 {
        zebraw(
            header: [#filepath],
            numbering: display-numbering,
            eval(block, mode: "markup"),
        )
    } else {
        zebraw(
            header: [#filepath],
            numbering: display-numbering,
            highlight-lines: hl,
            eval(block, mode: "markup"),
        )
    }
}
#let zebraw-test(filepath) = {
    let dirname = "test/"
    let testfile = "case/test/" + filepath + ".test"
    let resultfile = "case/result/" + filepath + ".result"
    let _clamp-lines(text, tail-note: "...") = {
        let lines = text.split("\n")
        let compacted = lines.map(line => {
            if line.len() > 70 {
                tail-note
            } else {
                line
            }
        })
        if lines.len() > 80 {
            compacted.slice(0, 80).join("\n") + "\n" + tail-note
        } else {
            compacted.join("\n")
        }
    }
    zebraw(
        header: dirname + testfile,
        raw(
            _clamp-lines(read(testfile), tail-note: "-- ... extra content not shown"),
            block: true,
            lang: "sql",
        ),
    )
    zebraw(
        header: dirname + resultfile,
        raw(_clamp-lines(read(resultfile)), block: true, lang: "text"),
    )
}

// Define some units for the report
#let (B, KB) = (
    unit[B],
    unit[KB],
)

// #outline()
// #outline(
//     title: [List of Figures],
//     target: figure.where(kind: image),
// )

= Experiment 1 <exp1>
- 实验内容:
    + 完成从拉取源代码到构建运行数据库系统的全过程#footnote[环境搭建:@zhihu-662734805.].
    + 熟悉#link("https://www.docker.com", "Docker")和#link("https://code.visualstudio.com", "VSCode")的使用,为后续的开发和调试打下基础.
    + 提测#link("https://open.oceanbase.com/train/TopicDetails?questionId=600004&subQesitonId=800004&subQuestionName=basic", "题目1").
== Setup
拉取miniob:
#zebraw(
    ```powershell
    git clone https://github.com/oceanbase/miniob.git
    rm -rf miniob/.git
    cp -r miniob/* ./
    rm -rf miniob
    ```,
)
将源代码推送至个人仓库,配置好即可提测:
#figure(image("fig/1/judge_result/1.png"), caption: [实验1提测结果])<fig:exp1_judge_result_1>
== Docker
挂载目录并查看容器:
#zebraw(
    ```powershell
    docker run -d --name miniob --privileged -v "${PWD}:/root/miniob" oceanbase/miniob
    ```,
)
== VSCode Configuration
=== Tasks
在VSCode中配置如下的Tasks:
#zebraw(raw(read(".vscode/tasks.json"), block: true, lang: "json"))
上述Tasks配置了以下几个任务:
- CMake:
    + Configure: 配置CMake.
    + Build: 构建项目,依赖于Configure.
- Observer:
    + PID: 查看Observer进程PID.
    + Run: 启动Observer服务端.
- Obclient:
    + Run: 启动Obclient客户端.
- Test:
    #{
        enum.item(0)[如果想要通过Tasks运行,作如下修改:#zebraw(
                header: [test/case/miniob_test.py],
                numbering-offset: 1100,
                ```python
                # os.setpgrp()
                try:
                    os.setpgrp()
                except PermissionError:
                    pass
                ```,
            )
        ]
    }
    + All: 运行测试脚本,依赖于Build.
    + All (Report Only): 仅运行测试脚本并输出报告.
    + Basic: 运行测试脚本的basic测试用例,依赖于Build.
    + Case: 运行测试脚本的指定测试用例,依赖于Build.
    + Case (Report Only): 仅运行测试脚本的指定测试用例并输出报告.
=== Debug
在VSCode中配置Debug功能:
#zebraw(raw(read(".vscode/launch.json"), block: true, lang: "json"))
上述Debug配置了一个调试配置"(gdb) Attach to observer",可以通过输入Observer进程的PID来附加到Observer进程进行调试.
== Build
运行CMake: Build构建项目(可以手动先运行CMake: Configure):
#figure(image("fig/1/build_result/1.png"), caption: [实验1构建结果])<fig:exp1_build_result_1>
== Run
运行Observer: Run启动服务端:
#figure(image("fig/1/run_result/1.png"), caption: [实验1服务端运行结果])<fig:exp1_run_result_2>
运行Obclient: Run启动客户端:
#figure(image("fig/1/run_result/2.png"), caption: [实验1客户端运行结果])<fig:exp1_run_result_3>
== Test
使用内置测试集:
#zebraw-test("basic")
== Debug
首先运行Observer: PID获得Observer进程的PID:
#figure(image("fig/1/run_result/3.png"), caption: [实验1 Observer PID])<fig:exp1_run_result_4>
选择"(gdb) Attach to observer"并输入`PID`即可进入调试状态(在`src/observer/net/plain_communicator.cpp`的```cpp PlainCommunicator::read_event(SessionEvent *&event)```打断点)并测试```sql show tables;```:
#figure(image("fig/1/debug_result/1.png"), caption: [实验1调试结果])<fig:exp1_debug_result_1>
== 总结
@exp1 主要完成了从拉取源代码到构建运行数据库系统的全过程,熟悉了Docker和VSCode的使用,并且通过测试验证了基本功能的正确性.

= Experiment 2 <exp2>
- 基于@exp1.
- 实验内容:
    + 实现删除表功能,包括删除元数据文件、数据文件、LOB文件及索引等.
    + 增加日期类型,支持日期的存储、比较、字符串化、解析校验、隐式类型转换等功能.
    + 提测#link("https://open.oceanbase.com/train/TopicDetails?questionId=600004&subQesitonId=800006&subQuestionName=drop-table", "题目3")和#link("https://open.oceanbase.com/train/TopicDetails?questionId=600004&subQesitonId=800005&subQuestionName=date", "题目2").
== Drop Table
=== 实现
#{
    [实现删除功能,包括删除元数据文件、数据文件、LOB文件及索引等:]
    zebraw-file("src/observer/storage/db/db.h")
    zebraw-file("src/observer/storage/db/db.cpp")
    [然后增加删除表的stmt:]
    zebraw-file("src/observer/sql/stmt/drop_table_stmt.h")
    zebraw-file("src/observer/sql/stmt/drop_table_stmt.cpp")
    zebraw-file("src/observer/sql/stmt/stmt.cpp")
    [最后增加删除表的executor:]
    zebraw-file("src/observer/sql/executor/drop_table_executor.h")
    zebraw-file("src/observer/sql/executor/drop_table_executor.cpp")
    zebraw-file("src/observer/sql/executor/help_executor.h")
    zebraw-file("src/observer/sql/executor/command_executor.cpp")
}
=== Build
编译配置同@exp1, 直接运行CMake: Build即可.随后运行Observer: Run和Obclient: Run启动服务端和客户端.
=== Test
使用内置测试集:
#zebraw-test("primary-drop-table")
== Date
=== 实现
#{
    [增加类型枚举与注册:]
    zebraw-file("src/observer/common/type/attr_type.h")
    zebraw-file("src/observer/common/type/attr_type.cpp")
    zebraw-file("src/observer/common/type/data_type.cpp")
    [实现类型(4字节 *YYYYMMDD* 存储、比较、字符串化、解析校验、闰年):]
    zebraw-file("src/observer/common/type/date_type.h")
    zebraw-file("src/observer/common/type/date_type.cpp")
    [提供Value支持:]
    zebraw-file("src/observer/common/value.h")
    zebraw-file("src/observer/common/value.cpp")
    [增加隐式类型转换支持:]
    zebraw-file("src/observer/common/type/char_type.cpp")
    [接着修改词法分析器和语法分析器支持日期类型:]
    zebraw-file("src/observer/sql/parser/lex_sql.l")
    zebraw-file("src/observer/sql/parser/yacc_sql.y")
    [最后增加日期类型的比较和编码支持:]
    zebraw-file("src/observer/sql/optimizer/physical_plan_generator.cpp")
    zebraw-file("src/observer/sql/expr/expression.cpp")
    zebraw-file("src/observer/storage/common/codec.h")
}
=== Build
编译配置同@exp1, 直接运行CMake: Build即可.接下来运行Observer: Run和Obclient: Run启动服务端和客户端.
=== Test
使用内置测试集:
#zebraw-test("primary-date")
== 提测
推送至仓库并提测:
#figure(image("fig/2/judge_result/1.png"), caption: [实验2提测结果])<fig:exp2_judge_result_2>
== 总结
@exp2 主要实现了删除表功能和日期类型,并且在此过程中熟悉了数据库系统中DDL操作和数据类型实现的相关知识,同时通过测试验证了功能的正确性.

= Experiment 3 <exp3>
- 基于@exp2.
- 实验内容:
    + 实现更新行数据功能,支持根据条件更新表中的数据.
    + 提测#link("https://open.oceanbase.com/train/TopicDetails?questionId=600004&subQesitonId=800007&subQuestionName=update", "题目4").
== 实现
#{
    [完成语句上的支持:]
    zebraw-file("src/observer/sql/stmt/update_stmt.h")
    zebraw-file("src/observer/sql/stmt/update_stmt.cpp")
    zebraw-file("src/observer/sql/stmt/stmt.cpp")
    [接着增加逻辑算子和物理算子支持:]
    zebraw-file("src/observer/sql/operator/logical_operator.h")
    zebraw-file("src/observer/sql/operator/logical_operator.cpp")
    zebraw-file("src/observer/sql/operator/physical_operator.h")
    zebraw-file("src/observer/sql/operator/physical_operator.cpp")
    zebraw-file("src/observer/sql/operator/update_logical_operator.h")
    zebraw-file("src/observer/sql/operator/update_logical_operator.cpp")
    zebraw-file("src/observer/sql/operator/update_physical_operator.h")
    zebraw-file("src/observer/sql/operator/update_physical_operator.cpp")
    zebraw-file("src/observer/sql/optimizer/logical_plan_generator.h")
    zebraw-file("src/observer/sql/optimizer/logical_plan_generator.cpp")
    zebraw-file("src/observer/sql/optimizer/physical_plan_generator.h")
    zebraw-file("src/observer/sql/optimizer/physical_plan_generator.cpp")
    [最后增加表和事务的更新接口支持:]
    zebraw-file("src/observer/storage/table/heap_table_engine.h")
    zebraw-file("src/observer/storage/table/heap_table_engine.cpp")
    zebraw-file("src/observer/storage/trx/mvcc_trx.h")
    zebraw-file("src/observer/storage/trx/mvcc_trx.cpp")
    zebraw-file("src/observer/storage/trx/vacuous_trx.h")
    zebraw-file("src/observer/storage/trx/vacuous_trx.cpp")
}
== Build
编译配置同@exp1, 直接运行CMake: Build即可.接下来运行Observer: Run和Obclient: Run启动服务端和客户端.
== Test
使用内置测试集:
#zebraw-test("primary-update")
== 提测
推送至仓库并提测:
#figure(image("fig/3/judge_result/1.png"), caption: [实验3提测结果])<fig:exp3_judge_result_1>
== 总结
@exp3 主要实现了更新行数据功能,并且在此过程中熟悉了数据库系统中DML操作的相关知识,同时通过测试验证了功能的正确性.

= Experiment 4 <exp4>
- 基于@exp3.
- 实验内容:
    + 实现多表连接查询功能,支持使用JOIN关键字连接多张表进行查询.
    + 提测#link("https://open.oceanbase.com/train/TopicDetails?questionId=600004&subQesitonId=800010&subQuestionName=join-tables", "题目7").
== 实现
#{
    [先实现`char`类型的强转换支持#footnote[见@miniob-wiki #sym.hash 类型转换.]:]
    zebraw-file("src/observer/common/type/char_type.cpp")
    [接着给出对from子句中join关系的描述支持:]
    zebraw-file("src/observer/sql/parser/parse_defs.h")
    [最后修改词法分析器和语法分析器支持JOIN语句:]
    zebraw-file("src/observer/sql/parser/lex_sql.l")
    zebraw-file("src/observer/sql/parser/yacc_sql.y")
}
== Build
编译配置同@exp1, 直接运行CMake: Build即可.接下来运行Observer: Run和Obclient: Run启动服务端和客户端.
== Test
使用内置测试集:
#zebraw-test("primary-join-tables")
== 提测
推送至仓库并提测:
#figure(image("fig/4/judge_result/1.png"), caption: [实验4提测结果])<fig:exp4_judge_result_1>
== 总结
@exp4 主要实现了基于JOIN的多表查询功能,并且在此过程中熟悉了数据库系统中多表查询的相关知识,同时通过测试验证了功能的正确性.

= Experiment 5 <exp5>
- 基于@exp4.
- 实验内容:
    + 实现大文本类型支持,增加TEXT数据类型用于存储大文本数据.
    + 提测#link("https://open.oceanbase.com/train/TopicDetails?questionId=600004&subQesitonId=800017&subQuestionName=text", "题目16").
== 实现
#{
    [语法支持:]
    zebraw-file("src/observer/sql/parser/lex_sql.l")
    zebraw-file("src/observer/sql/parser/yacc_sql.y")
    [增加类型支持:]
    zebraw-file("src/observer/common/type/attr_type.h")
    zebraw-file("src/observer/common/type/attr_type.cpp")
    [注意保持旧类型枚举值兼容:]
    zebraw-file("src/observer/common/type/char_type.h")
    zebraw-file("src/observer/common/type/char_type.cpp")
    zebraw-file("src/observer/common/type/data_type.cpp")
    zebraw-file("src/observer/common/value.h")
    zebraw-file("src/observer/common/value.cpp")
    [溢出实现:]
    zebraw-file("src/observer/storage/record/record_manager.h")
    zebraw-file("src/observer/storage/record/record_manager.cpp")
    [接口实现+功能补充:]
    zebraw-file("src/observer/storage/table/table_engine.h")
    zebraw-file("src/observer/storage/table/heap_table_engine.h")
    zebraw-file("src/observer/storage/table/heap_table_engine.cpp")
    zebraw-file("src/observer/storage/table/lsm_table_engine.h")
    zebraw-file("src/observer/storage/table/table.h")
    zebraw-file("src/observer/storage/table/table.cpp")
    zebraw-file("src/observer/sql/operator/update_physical_operator.cpp")
    [读取:]
    zebraw-file("src/observer/sql/expr/tuple.h")
    [兼容性调整:]
    zebraw-file("src/observer/sql/expr/expression.cpp")
    zebraw-file("src/observer/sql/executor/load_data_executor.cpp")
    zebraw-file("src/observer/storage/common/codec.h")
    [最后调整协议防止$64 #KB$请求被截断#footnote[@zhihu-671981637, #link("https://github.com/oceanbase/miniob/pull/28", "miniob#28"), #link("https://github.com/oceanbase/miniob/pull/559", "miniob#559").]:]
    zebraw-file("src/observer/net/plain_communicator.cpp")
}
== Build
编译配置同@exp1, 直接运行CMake: Build即可.接下来运行Observer: Run和Obclient: Run启动服务端和客户端.
== Test
使用内置测试集:
#zebraw-test("primary-text")
== 提测
推送至仓库并提测:
#figure(image("fig/5/judge_result/1.png"), caption: [实验5提测结果])<fig:exp5_judge_result_1>
== 总结
@exp5 主要实现了TEXT数据类型支持,包括语法解析、类型定义、接口设计和溢出处理等方面的工作,并且在此过程中熟悉了数据库系统中大文本数据的存储和管理相关知识,同时通过测试验证了功能的正确性.

#{
    pagebreak()
    show "“": ["]
    show "”": ["]
    show "‘": [']
    show "’": [']
    show link: it => text(fill: black, style: "italic", it.body)
    bibliography("ref/ref.yml", style: "ieee", title: [References], full: true)
}
