import argparse
import re
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlparse
from urllib.request import Request, urlopen

REPO_ROOT = Path(__file__).resolve().parents[2]
RAW_ROOT = REPO_ROOT / "report" / "asset" / "raw"
HIGHLIGHT_ROOT = REPO_ROOT / "report" / "highlight"
DEFAULT_BRANCHES = ("exp2", "exp3", "exp4", "exp5")
DEFAULT_HIGHLIGHT_URLS = (
    "https://raw.githubusercontent.com/SublimeText/PowerShell/master/PowerShell.sublime-syntax",
)


@dataclass
class FileDiff:
    path: str
    lines: list[str]
    old_numbering: list[int | None]
    new_numbering: list[int | None]


def run_git(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=REPO_ROOT,
        check=True,
        capture_output=True,
    )
    return result.stdout.decode("utf-8", errors="replace")


def is_readme(path: str) -> bool:
    return Path(path).name.lower().startswith("readme")


def normalize_diff_path(path: str) -> str:
    return path[2:] if path.startswith(("a/", "b/")) else path


def parse_hunk_header(line: str) -> tuple[int, int]:
    # Example: @@ -10,3 +12,4 @@
    header = line.split("@@")[1].strip()
    old_part, new_part, *_ = header.split()
    old_start = int(old_part[1:].split(",")[0])
    new_start = int(new_part[1:].split(",")[0])
    return old_start, new_start


def parse_unified_diff(diff_text: str) -> list[FileDiff]:
    files: list[FileDiff] = []
    path: str | None = None
    lines: list[str] = []
    old_numbering: list[int | None] = []
    new_numbering: list[int | None] = []
    keep = False
    in_hunk = False
    old_line = 0
    new_line = 0

    def flush() -> None:
        nonlocal path, lines, old_numbering, new_numbering, keep, in_hunk
        if keep and path and lines:
            files.append(
                FileDiff(
                    path=path,
                    lines=lines,
                    old_numbering=old_numbering,
                    new_numbering=new_numbering,
                )
            )
        path = None
        lines = []
        old_numbering = []
        new_numbering = []
        keep = False
        in_hunk = False

    for raw in diff_text.splitlines():
        if raw.startswith("diff --git "):
            flush()
            continue
        if raw.startswith("+++ "):
            right = raw[4:].strip()
            if right != "/dev/null":
                path = normalize_diff_path(right)
                keep = not is_readme(path)
            continue
        if raw.startswith("--- "):
            if path is None:
                left = raw[4:].strip()
                if left != "/dev/null":
                    path = normalize_diff_path(left)
                    keep = not is_readme(path)
            continue
        if raw.startswith("@@ "):
            if not keep:
                in_hunk = False
                continue
            old_line, new_line = parse_hunk_header(raw)
            in_hunk = True
            continue
        if not in_hunk or not keep or not raw:
            continue

        prefix = raw[0]
        body = raw[1:]
        if prefix == "\\":
            continue
        if prefix == " ":
            lines.append(f" {body}")
            old_numbering.append(old_line)
            new_numbering.append(new_line)
            old_line += 1
            new_line += 1
        elif prefix == "-":
            lines.append(f"-{body}")
            old_numbering.append(old_line)
            new_numbering.append(None)
            old_line += 1
        elif prefix == "+":
            lines.append(f"+{body}")
            old_numbering.append(None)
            new_numbering.append(new_line)
            new_line += 1

    flush()
    return files


def path_to_target_name(path: str) -> str:
    return path.replace("\\", "-").replace("/", "-")


def _format_column(values: list[int | None]) -> str:
    if not values:
        return "()"
    rendered = ", ".join("none" if value is None else str(value) for value in values)
    return f"({rendered},)"


def format_numbering_line(old_numbering: list[int | None], new_numbering: list[int | None]) -> str:
    return f"({_format_column(old_numbering)}, {_format_column(new_numbering)},)"


def write_raw_file(target_dir: Path, file_diff: FileDiff) -> None:
    target_dir.mkdir(parents=True, exist_ok=True)
    target_path = target_dir / f"{path_to_target_name(file_diff.path)}.txt"
    target_path.write_text(
        f"{format_numbering_line(file_diff.old_numbering, file_diff.new_numbering)}\n"
        f"````diff\n"
        f"{chr(10).join(file_diff.lines)}\n"
        "````\n",
        encoding="utf-8",
    )


def clear_existing_raw_files(target_dir: Path) -> None:
    if not target_dir.exists():
        return
    for raw_file in target_dir.glob("*.txt"):
        raw_file.unlink()


def branch_exp_number(branch: str) -> int:
    match = re.fullmatch(r"exp(\d+)", branch)
    if not match:
        raise ValueError(f"Unsupported branch name: {branch}")
    return int(match.group(1))


def latest_experiment_commits(branch: str) -> dict[int, tuple[str, str]]:
    commits: dict[int, tuple[str, str]] = {}
    pattern = re.compile(r"^add:\s*experiment\s+(\d+)", re.IGNORECASE)
    for line in run_git("log", branch, "--format=%H%x09%s").splitlines():
        if "\t" not in line:
            continue
        commit, subject = line.split("\t", 1)
        match = pattern.match(subject)
        if not match:
            continue
        exp_no = int(match.group(1))
        if exp_no not in commits:
            commits[exp_no] = (commit, subject)
    return commits


def collect_branch_diff(branch: str) -> tuple[str, str, str, str]:
    exp_no = branch_exp_number(branch)
    if exp_no <= 1:
        raise RuntimeError(f"Branch {branch} has no previous experiment baseline")
    commits = latest_experiment_commits(branch)
    if exp_no - 1 not in commits:
        raise RuntimeError(
            f"Cannot find commit with prefix 'add: experiment {exp_no - 1}' in branch {branch}"
        )
    if exp_no not in commits:
        raise RuntimeError(
            f"Cannot find commit with prefix 'add: experiment {exp_no}' in branch {branch}"
        )
    old_commit, old_subject = commits[exp_no - 1]
    new_commit, new_subject = commits[exp_no]
    return old_commit, new_commit, old_subject, new_subject


def generate_raw_diff_files(branches: list[str], unified: int) -> None:
    for branch in branches:
        exp_no = branch_exp_number(branch)
        old_commit, new_commit, old_subject, new_subject = collect_branch_diff(branch)
        diff_text = run_git(
            "-c",
            "core.quotePath=false",
            "diff",
            "--no-color",
            "--minimal",
            f"--unified={unified}",
            old_commit,
            new_commit,
        )
        file_diffs = parse_unified_diff(diff_text)
        exp_dir = RAW_ROOT / str(exp_no)
        clear_existing_raw_files(exp_dir)
        for file_diff in file_diffs:
            write_raw_file(exp_dir, file_diff)
        print(
            f"{branch}: {old_commit[:8]}..{new_commit[:8]} -> "
            f"{len(file_diffs)} files at {exp_dir.relative_to(REPO_ROOT)} "
            f"({old_subject} -> {new_subject})"
        )


def filename_from_url(url: str) -> str:
    name = Path(urlparse(url).path).name
    if not name:
        raise ValueError(f"Cannot infer filename from URL: {url}")
    return name


def download_file(url: str, output_dir: Path) -> tuple[bool, str, int, float, str]:
    start = time.perf_counter()
    target = output_dir / filename_from_url(url)
    req = Request(url, headers={"User-Agent": "highlight-downloader/1.0"})
    try:
        with urlopen(req, timeout=30) as resp:
            data = resp.read()
        target.write_bytes(data)
        elapsed = time.perf_counter() - start
        return True, str(target), len(data), elapsed, "OK"
    except Exception as exc:
        elapsed = time.perf_counter() - start
        return False, str(target), 0, elapsed, str(exc)


def download_highlight_files(urls: list[str], output_dir: Path) -> int:
    output_dir.mkdir(parents=True, exist_ok=True)
    results: list[tuple[bool, str, int, float, str, str]] = []
    for url in urls:
        ok, saved_to, size, elapsed, msg = download_file(url, output_dir)
        results.append((ok, url, size, elapsed, msg, saved_to))

    success = sum(1 for r in results if r[0])
    failed = len(results) - success
    print("Download Summary")
    print(f"- output_dir: {output_dir}")
    print(f"- total: {len(results)}")
    print(f"- success: {success}")
    print(f"- failed: {failed}")
    for idx, (ok, url, size, elapsed, msg, saved_to) in enumerate(results, start=1):
        status = "SUCCESS" if ok else "FAILED"
        print(f"[{idx}] {status}")
        print(f"    url: {url}")
        print(f"    saved_to: {saved_to}")
        print(f"    bytes: {size}")
        print(f"    elapsed_sec: {elapsed:.3f}")
        if not ok:
            print(f"    error: {msg}")
    return 0 if failed == 0 else 1


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Report tooling: always download highlight syntaxes then generate raw diff files."
    )
    parser.add_argument(
        "--branches",
        nargs="+",
        default=list(DEFAULT_BRANCHES),
        help="Branches to process (default: exp2 exp3 exp4 exp5).",
    )
    parser.add_argument(
        "--unified",
        type=int,
        default=0,
        help="Unified diff context lines (default: 0).",
    )
    parser.add_argument(
        "urls",
        nargs="*",
        default=list(DEFAULT_HIGHLIGHT_URLS),
        help="Highlight syntax URLs to download (default: built-in list).",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=HIGHLIGHT_ROOT,
        help="Target directory for downloaded highlight files.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    download_code = download_highlight_files(args.urls, args.output_dir)
    generate_raw_diff_files(args.branches, args.unified)
    return download_code


if __name__ == "__main__":
    raise SystemExit(main())
