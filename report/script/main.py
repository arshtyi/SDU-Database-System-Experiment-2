"""Generate report assets: highlight syntax files, raw diffs, and branch hashes."""

from __future__ import annotations

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
COMMIT_HASH_FILE = REPO_ROOT / "report" / "asset" / "commit" / "hash.txt"
HIGHLIGHT_ROOT = REPO_ROOT / "report" / "highlight"

DEFAULT_BRANCHES = ("exp2", "exp3", "exp4", "exp5")
DEFAULT_HASH_BRANCHES = ("exp1", "exp2", "exp3", "exp4", "exp5")
DEFAULT_HIGHLIGHT_URLS = (
    "https://raw.githubusercontent.com/SublimeText/PowerShell/master/PowerShell.sublime-syntax",
)

COMMIT_SUBJECT_PATTERN = re.compile(r"^add:\s*experiment\s+(\d+)", re.IGNORECASE)
BRANCH_PATTERN = re.compile(r"exp(\d+)")
HUNK_HEADER_PATTERN = re.compile(r"^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@")
DOWNLOAD_USER_AGENT = "highlight-downloader/1.0"
DOWNLOAD_TIMEOUT_SECONDS = 30


@dataclass(slots=True)
class FileDiff:
    path: str
    lines: list[str]
    old_numbering: list[int | None]
    new_numbering: list[int | None]


def run_git(*args: str) -> str:
    """Run git in repo root and return UTF-8 decoded stdout."""
    try:
        result = subprocess.run(
            ["git", *args],
            cwd=REPO_ROOT,
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
    except subprocess.CalledProcessError as exc:
        stderr = exc.stderr.strip()
        cmd = " ".join(exc.cmd)
        message = f"{cmd} failed with exit code {exc.returncode}"
        if stderr:
            message = f"{message}: {stderr}"
        raise RuntimeError(message) from exc
    return result.stdout


def resolve_branch_ref(branch: str) -> str:
    """Resolve branch name from local or remote refs."""
    candidates = (branch, f"origin/{branch}", f"remotes/origin/{branch}")
    for ref in candidates:
        try:
            run_git("rev-parse", "--verify", ref)
            return ref
        except RuntimeError:
            continue

    checked = ", ".join(candidates)
    raise RuntimeError(
        f"Cannot resolve branch '{branch}'. Checked refs: {checked}. "
        "Ensure experiment branches are fetched (e.g. exp2..exp5)."
    )


def is_readme(path: str) -> bool:
    return Path(path).name.lower().startswith("readme")


def normalize_diff_path(path: str) -> str:
    return path[2:] if path.startswith(("a/", "b/")) else path


def parse_hunk_header(line: str) -> tuple[int, int]:
    """Parse unified-diff hunk header and return start line numbers."""
    match = HUNK_HEADER_PATTERN.match(line)
    if not match:
        raise ValueError(f"Invalid hunk header: {line}")
    old_start, new_start = match.groups()
    return int(old_start), int(new_start)


def parse_unified_diff(diff_text: str) -> list[FileDiff]:
    files: list[FileDiff] = []
    path: str | None = None
    lines: list[str] = []
    old_numbering: list[int | None] = []
    new_numbering: list[int | None] = []
    keep_file = False
    in_hunk = False
    old_line = 0
    new_line = 0

    def flush() -> None:
        nonlocal path, lines, old_numbering, new_numbering, keep_file, in_hunk
        if keep_file and path and lines:
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
        keep_file = False
        in_hunk = False

    for raw in diff_text.splitlines():
        if raw.startswith("diff --git "):
            flush()
            continue

        if raw.startswith("+++ "):
            right = raw[4:].strip()
            if right != "/dev/null":
                path = normalize_diff_path(right)
                keep_file = not is_readme(path)
            continue

        if raw.startswith("--- "):
            if path is None:
                left = raw[4:].strip()
                if left != "/dev/null":
                    path = normalize_diff_path(left)
                    keep_file = not is_readme(path)
            continue

        if raw.startswith("@@ "):
            if not keep_file:
                in_hunk = False
                continue
            old_line, new_line = parse_hunk_header(raw)
            in_hunk = True
            continue

        if not in_hunk or not keep_file or not raw:
            continue

        prefix, body = raw[0], raw[1:]
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


def format_number_column(values: list[int | None]) -> str:
    if not values:
        return "()"
    rendered = ", ".join("none" if value is None else str(value) for value in values)
    return f"({rendered},)"


def format_numbering_line(
    old_numbering: list[int | None], new_numbering: list[int | None]
) -> str:
    return (
        f"({format_number_column(old_numbering)}, "
        f"{format_number_column(new_numbering)},)"
    )


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
    match = BRANCH_PATTERN.fullmatch(branch)
    if not match:
        raise ValueError(f"Unsupported branch name: {branch}")
    return int(match.group(1))


def latest_experiment_commits(branch: str) -> dict[int, tuple[str, str]]:
    commits: dict[int, tuple[str, str]] = {}
    branch_ref = resolve_branch_ref(branch)
    for line in run_git("log", branch_ref, "--format=%H%x09%s").splitlines():
        if "\t" not in line:
            continue
        commit, subject = line.split("\t", 1)
        match = COMMIT_SUBJECT_PATTERN.match(subject)
        if not match:
            continue
        exp_no = int(match.group(1))
        commits.setdefault(exp_no, (commit, subject))
    return commits


def collect_branch_diff(branch: str) -> tuple[str, str, str, str]:
    exp_no = branch_exp_number(branch)
    if exp_no <= 1:
        raise RuntimeError(f"Branch {branch} has no previous experiment baseline")

    commits = latest_experiment_commits(branch)
    prev_exp_no = exp_no - 1
    if prev_exp_no not in commits:
        raise RuntimeError(
            f"Cannot find commit with prefix 'add: experiment {prev_exp_no}' in branch {branch}"
        )
    if exp_no not in commits:
        raise RuntimeError(
            f"Cannot find commit with prefix 'add: experiment {exp_no}' in branch {branch}"
        )

    old_commit, old_subject = commits[prev_exp_no]
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


def latest_branch_commit(branch: str) -> tuple[str, str]:
    branch_ref = resolve_branch_ref(branch)
    commit = run_git("rev-parse", "--verify", branch_ref).strip()
    return branch_ref, commit


def generate_commit_hash_file(
    branches: list[str], output_file: Path = COMMIT_HASH_FILE
) -> None:
    lines: list[str] = []
    for branch in branches:
        branch_ref, commit = latest_branch_commit(branch)
        lines.append(f"{branch},{branch_ref},{commit}")

    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Saved {len(lines)} branch hashes to {output_file.relative_to(REPO_ROOT)}")


def filename_from_url(url: str) -> str:
    name = Path(urlparse(url).path).name
    if not name:
        raise ValueError(f"Cannot infer filename from URL: {url}")
    return name


def download_file(url: str, output_dir: Path) -> tuple[bool, str, int, float, str]:
    start = time.perf_counter()
    target = output_dir / filename_from_url(url)
    request = Request(url, headers={"User-Agent": DOWNLOAD_USER_AGENT})
    try:
        with urlopen(request, timeout=DOWNLOAD_TIMEOUT_SECONDS) as response:
            data = response.read()
        target.write_bytes(data)
    except Exception as exc:
        elapsed = time.perf_counter() - start
        return False, str(target), 0, elapsed, str(exc)

    elapsed = time.perf_counter() - start
    return True, str(target), len(data), elapsed, "OK"


def download_highlight_files(urls: list[str], output_dir: Path) -> int:
    output_dir.mkdir(parents=True, exist_ok=True)
    results: list[tuple[bool, str, int, float, str, str]] = []

    for url in urls:
        ok, saved_to, size, elapsed, message = download_file(url, output_dir)
        results.append((ok, url, size, elapsed, message, saved_to))

    success = sum(1 for item in results if item[0])
    failed = len(results) - success
    print("Download Summary")
    print(f"- output_dir: {output_dir}")
    print(f"- total: {len(results)}")
    print(f"- success: {success}")
    print(f"- failed: {failed}")
    for index, (ok, url, size, elapsed, message, saved_to) in enumerate(results, 1):
        status = "SUCCESS" if ok else "FAILED"
        print(f"[{index}] {status}")
        print(f"    url: {url}")
        print(f"    saved_to: {saved_to}")
        print(f"    bytes: {size}")
        print(f"    elapsed_sec: {elapsed:.3f}")
        if not ok:
            print(f"    error: {message}")

    return 0 if failed == 0 else 1


def non_negative_int(value: str) -> int:
    parsed = int(value)
    if parsed < 0:
        raise argparse.ArgumentTypeError("must be >= 0")
    return parsed


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Report tooling: always download highlight syntaxes then generate raw diff files.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--branches",
        nargs="+",
        default=list(DEFAULT_BRANCHES),
        help="Branches used for raw diff generation.",
    )
    parser.add_argument(
        "--unified",
        type=non_negative_int,
        default=0,
        help="Unified diff context lines.",
    )
    parser.add_argument(
        "--hash-branches",
        nargs="+",
        default=list(DEFAULT_HASH_BRANCHES),
        help="Branches used for commit hash export.",
    )
    parser.add_argument(
        "urls",
        nargs="*",
        default=list(DEFAULT_HIGHLIGHT_URLS),
        help="Highlight syntax URLs to download.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=HIGHLIGHT_ROOT,
        help="Target directory for downloaded highlight files.",
    )
    return parser


def main() -> int:
    args = build_parser().parse_args()
    download_exit_code = download_highlight_files(args.urls, args.output_dir)
    generate_raw_diff_files(args.branches, args.unified)
    generate_commit_hash_file(args.hash_branches)
    return download_exit_code


if __name__ == "__main__":
    raise SystemExit(main())
