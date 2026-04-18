#import "dependency.typ": *

// #let _regex = regex("[^a-zA-Z0-9，。、；：？！\"\"''（）《》〈〉…—·]")
#let font = (
    "Times New Roman",
    "Noto Serif CJK SC",
    "Noto Sans CJK SC",
    "SimHei",
    "IBM Plex Mono",
)

#let report(
    institute: "计算机科学与技术",
    course: "计算概论",
    student-id: "202512111715",
    student-name: "Arshtyi",
    date: datetime.today(),
    lab-title: "实验题目",
    class: "你的班级",
    email: "你的邮箱",
    body,
) = {
    set document(title: lab-title, author: student-name)
    set text(
        font: font,
        size: 12pt,
        lang: "en",
        region: "us",
    )
    set smartquote(quotes: "\"\"")
    set page(
        paper: "a4",
        margin: (top: 2.6cm, bottom: 2.3cm, inside: 2cm, outside: 2cm),
        footer: [
            #set align(center)
            #set text(9pt)
            #context { counter(page).display("- 1 -") }
        ],
    )
    set heading(
        numbering: numbly(
            none,
            "{2:1}.",
            "({3:1})",
        ),
    )
    set par(justify: true)
    show math.equation.where(block: true): it => block(width: 100%, align(center, it))
    set raw(syntaxes: "highlight/PowerShell.sublime-syntax")
    show: zebraw
    show link: it => text(fill: blue.darken(20%), underline(evade: false, it))
    // show link: it => text(fill: blue.darken(20%), underline(evade: true, it)) // https://typst.app/docs/reference/text/underline/#parameters-evade
    set list(indent: 6pt)
    set enum(
        indent: 6pt,
        numbering: numbly(
            n => emph(strong(numbering("a.", n))),
        ),
    )
    counter(page).update(1)
    [
        #show heading: it => {
            set align(center)
            set text(size: 18pt, weight: "bold")
            it
        }
        #set text(tracking: 0.1em)
        #heading(numbering: none, depth: 1)[ #institute 学院 #underline(extent: 2pt, [#course]) 课程实验报告]
    ]
    show heading: set block(spacing: 1em)
    show heading: it => text(size: 12pt, it)
    set text(size: 12pt)
    set par(first-line-indent: (amount: 2em, all: true))

    [
        #set par(justify: true)
        #set text(size: 12pt)
        #table(
            inset: .5em,
            align: left + horizon,
            columns: (2fr, 1fr),
            [题目：#lab-title], [学号： #student-id],
        )
        #v(0em, weak: true)
        #table(
            align: left + horizon,
            inset: 0.5em,
            columns: (3fr, 2fr, 2fr),
            [日期：#date.display("[year].[month].[day]")], [班级：#class], [姓名：#student-name],
        )
        #v(0em, weak: true)
        #table(
            align: left + horizon,
            inset: .5em,
            columns: 1fr,
            [Email: #email],
        )
    ]
    v(0em, weak: true)
    show heading.where(depth: 1): it => {
        show h.where(amount: 0.3em): none
        set text(size: 12pt)
        [
            #block(
                width: 100%,
                inset: 0em,
                stroke: none,
                breakable: true,
                it,
            )
        ]
    }
    body
}
#let exp-block(content) = {
    v(0em, weak: true)
    block(
        width: 100%,
        inset: .5em,
        stroke: 1pt,
        breakable: true,
        content,
    )
}
