# README
用于下载高亮语法定义文件并生成diff等文本内容
## Usage
```bash
usage: main.py [-h] [--branches BRANCHES [BRANCHES ...]] [--unified UNIFIED] [--hash-branches HASH_BRANCHES [HASH_BRANCHES ...]] [--output-dir OUTPUT_DIR] [urls ...]

Report tooling: always download highlight syntaxes then generate raw diff files.

positional arguments:
  urls                  Highlight syntax URLs to download. (default: ['https://raw.githubusercontent.com/SublimeText/PowerShell/master/PowerShell.sublime-syntax'])

options:
  -h, --help            show this help message and exit
  --branches BRANCHES [BRANCHES ...]
                        Branches used for raw diff generation. (default: ['exp2', 'exp3', 'exp4', 'exp5'])
  --unified UNIFIED     Unified diff context lines. (default: 0)
  --hash-branches HASH_BRANCHES [HASH_BRANCHES ...]
                        Branches used for commit hash export. (default: ['exp1', 'exp2', 'exp3', 'exp4', 'exp5'])
  --output-dir OUTPUT_DIR
                        Target directory for downloaded highlight files. (default: D:\Program\Project\SDU-Database-System-Experiment-2\report\highlight)
```
