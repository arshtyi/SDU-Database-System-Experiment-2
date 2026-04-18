from pathlib import Path
from urllib.parse import urlparse
from urllib.request import Request, urlopen
import sys
import time


DEFAULT_URLS = [
    "https://raw.githubusercontent.com/SublimeText/PowerShell/master/PowerShell.sublime-syntax",
]


def filename_from_url(url: str) -> str:
    path = urlparse(url).path
    name = Path(path).name
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


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    output_dir = script_dir.parent

    # Optional: pass URLs from command line; otherwise use defaults.
    urls = sys.argv[1:] if len(sys.argv) > 1 else DEFAULT_URLS

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


if __name__ == "__main__":
    raise SystemExit(main())
