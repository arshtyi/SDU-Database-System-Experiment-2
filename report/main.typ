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
// #show figure.where(kind: "image"): it => image(width: 67%,it)

#exp-block([
    = 实验环境
    - PowerShell: 7.6.0
    // - Ubuntu: 24.04
])

#exp-block([
    = 实验贡献
    均为个人完成.
])

#exp-block([
    = 实验1
    == Set Up
    拉取#link("https://github.com/oceanbase/miniob", "miniob")并推送至#link("https://github.com/arshtyi/SDU-Database-System-Experiment-2", "repo") (#link("https://gitee.com/arshtyi/SDU-Database-System-Experiment-2", "mirror"). 配置见手册与#link("https://help.gitee.com/repository/settings/sync-between-gitee-github", "sync help")).
    ```powershell
    git clone https://github.com/oceanbase/miniob.git
    rm -rf miniob/.git
    cp -r miniob/* ./
    rm -rf miniob
    ```
    配置好进行提测:
    #figure(image("asset/fig/1/judge_result/1.png"), caption: [实验1提测结果])<fig:judge_result_1>
    == 更新依赖
    如果要在本地进行后续实验,先更新需要的submodule:
    ```powershell
    git submodule update --init --recursive
    ```
    == #link("https://www.docker.com", "Docker")
    挂载项目目录并查看容器:
    ```powershell
    docker run -d --name miniob --privileged -v "${PWD}:/root/miniob" oceanbase/miniob
    docker ps
    docker exec -it miniob bash
    ```
    #figure(image("asset/fig/1/run_result/1.png"), caption: [实验1容器环境])<fig:run_result_1>
    // 还可以创建某一特定版本的容器方便开发.
    == #link("https://code.visualstudio.com", "VSCode") Configuration
    === Tasks
    在VSCode中配置如下的Tasks(以源代码目录为工作目录):
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
    ```
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
    在VSCode中配置Debug功能(以源代码目录为工作目录):
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
    ```
    上述Debug配置了一个调试配置"(gdb) Attach to observer",可以通过输入Observer进程的PID来附加到Observer进程进行调试.
    == Build
    运行CMake: Build构建项目(可以手动先运行CMake: Configure):
    #figure(image("asset/fig/1/build_result/1.png"), caption: [实验1构建结果])<fig:build_result_1>
    == Run
    运行Observer: Run启动服务端:
    #figure(image("asset/fig/1/run_result/2.png"), caption: [实验1服务端运行结果])<fig:run_result_2>
    接着运行Obclient: Run启动客户端:
    #figure(image("asset/fig/1/run_result/3.png"), caption: [实验1客户端运行结果])<fig:run_result_3>
    如此,完成了从拉取源代码到构建运行数据库系统.
    == Test
    使用下述命令测试数据库系统的基本功能:
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
    ```
    #figure(image("asset/fig/1/run_result/4.png"), caption: [实验1测试结果])<fig:run_result_4>
    == Debug
    首先运行Observer: PID获得Observer进程的PID:
    #figure(image("asset/fig/1/run_result/5.png"), caption: [实验1调试结果])<fig:run_result_5>
    选择"(gdb) Attach to observer"并输入PID即可进入调试状态(出于方便,在`src/observer/net/plain_communicator.cpp`的```cpp PlainCommunicator::read_event(SessionEvent *&event)```打一断点)并运行```sql show tables;```测试:
    #figure(image("asset/fig/1/debug_result/1.png"), caption: [实验1调试结果])<fig:debug_result_1>
    == 总结
    实验1主要完成了从拉取源代码到构建运行数据库系统的全过程,并且在此过程中熟悉了Docker和VSCode的使用,为后续的开发和调试打下了基础.
])
