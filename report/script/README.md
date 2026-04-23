# README
用于下载高亮语法定义文件并生成diff等文本内容
## Usage
```txt
usage: main.py [-h] [--branches BRANCHES [BRANCHES ...]] [--unified UNIFIED] [--output-dir OUTPUT_DIR] [urls ...]

Report tooling: always download highlight syntaxes then generate raw diff files.

positional arguments:
  urls                  Highlight syntax URLs to download (default: built-in list).

options:
  -h, --help            show this help message and exit
  --branches BRANCHES [BRANCHES ...]
                        Branches to process (default: exp2 exp3 exp4 exp5).
  --unified UNIFIED     Unified diff context lines (default: 0).
  --output-dir OUTPUT_DIR
                        Target directory for downloaded highlight files.
```
