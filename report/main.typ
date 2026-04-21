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
