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
#show figure.where(kind: "image"): it => {
    set image(width: 67%)
    it
}

#exp-block([
    = 实验贡献
    == 实验1
])
#exp-block([
    = 实验环境
    - Ubuntu: 24.04
])
#exp-block([
    = 实验1
])
