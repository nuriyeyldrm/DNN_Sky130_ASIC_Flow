from __future__ import annotations
from pathlib import Path


def load_results(path: Path):
    data = {}
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            parts = line.strip().split()
            if not parts:
                continue
            idx = int(parts[0])
            out0 = int(parts[1])
            out1 = int(parts[2])
            r0 = int(parts[3])
            r1 = int(parts[4])
            data[idx] = (out0, out1, r0, r1)
    return data


def main() -> None:
    this_dir = Path(__file__).resolve().parent
    build_dir = this_dir.parent.parent / "build"

    expected_file = build_dir / "scoreboard_expected.txt"
    observed_file = build_dir / "scoreboard_observed.txt"

    if not expected_file.is_file():
        raise SystemExit(f"[PY] Missing expected file: {expected_file}")

    if not observed_file.is_file():
        raise SystemExit(f"[PY] Missing observed file: {observed_file}")

    expected = load_results(expected_file)
    observed = load_results(observed_file)

    missing = sorted(set(expected) - set(observed))
    extra = sorted(set(observed) - set(expected))

    fail = False

    if missing:
        print(f"[PY] Missing observed test indices: {missing}")
        fail = True

    if extra:
        print(f"[PY] Unexpected observed test indices: {extra}")
        fail = True

    common = sorted(set(expected) & set(observed))
    mismatches = 0

    for idx in common:
        if expected[idx] != observed[idx]:
            mismatches += 1
            print(
                f"[PY] MISMATCH test {idx}: "
                f"expected={expected[idx]} observed={observed[idx]}"
            )

    if fail or mismatches:
        raise SystemExit(f"[PY] FAIL: missing={len(missing)} extra={len(extra)} mismatches={mismatches}")

    print(f"[PY] PASS: all {len(common)} scoreboard tests matched")


if __name__ == "__main__":
    main()