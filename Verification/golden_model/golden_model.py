from __future__ import annotations
import random
from pathlib import Path
from typing import Dict, List

NUM_TESTS_DEFAULT = 20
SEED_DEFAULT = 755


SIGNAL_ORDER = [
    "x0", "x1", "x2", "x3",
    "w04", "w05", "w06", "w07",
    "w14", "w15", "w16", "w17",
    "w24", "w25", "w26", "w27",
    "w34", "w35", "w36", "w37",
    "w48", "w58", "w68", "w78",
    "w49", "w59", "w69", "w79",
]


def to_signed(val: int, bits: int) -> int:
    mask = (1 << bits) - 1
    val &= mask
    if val & (1 << (bits - 1)):
        val -= (1 << bits)
    return val


def relu(x: int) -> int:
    return x if x > 0 else 0


def s5(v: int) -> int:
    return to_signed(v, 5)


def run_golden(inputs: Dict[str, int]) -> Dict[str, int]:
    x0 = s5(inputs["x0"])
    x1 = s5(inputs["x1"])
    x2 = s5(inputs["x2"])
    x3 = s5(inputs["x3"])

    w04 = s5(inputs["w04"]); w05 = s5(inputs["w05"]); w06 = s5(inputs["w06"]); w07 = s5(inputs["w07"])
    w14 = s5(inputs["w14"]); w15 = s5(inputs["w15"]); w16 = s5(inputs["w16"]); w17 = s5(inputs["w17"])
    w24 = s5(inputs["w24"]); w25 = s5(inputs["w25"]); w26 = s5(inputs["w26"]); w27 = s5(inputs["w27"])
    w34 = s5(inputs["w34"]); w35 = s5(inputs["w35"]); w36 = s5(inputs["w36"]); w37 = s5(inputs["w37"])

    w48 = s5(inputs["w48"]); w58 = s5(inputs["w58"]); w68 = s5(inputs["w68"]); w78 = s5(inputs["w78"])
    w49 = s5(inputs["w49"]); w59 = s5(inputs["w59"]); w69 = s5(inputs["w69"]); w79 = s5(inputs["w79"])

    y4 = relu(x0*w04 + x1*w14 + x2*w24 + x3*w34)
    y5 = relu(x0*w05 + x1*w15 + x2*w25 + x3*w35)
    y6 = relu(x0*w06 + x1*w16 + x2*w26 + x3*w36)
    y7 = relu(x0*w07 + x1*w17 + x2*w27 + x3*w37)

    y4 = to_signed(y4, 11)
    y5 = to_signed(y5, 11)
    y6 = to_signed(y6, 11)
    y7 = to_signed(y7, 11)

    out0 = y4*w48 + y5*w58 + y6*w68 + y7*w78
    out1 = y4*w49 + y5*w59 + y6*w69 + y7*w79

    out0 = to_signed(out0, 17)
    out1 = to_signed(out1, 17)

    return {
        "out0": out0,
        "out1": out1,
        "out0_ready": 1,
        "out1_ready": 1,
    }


def random_5bit_value(rng: random.Random) -> int:
    return rng.randint(-16, 15)


def generate_test_vector(rng: random.Random) -> Dict[str, int]:
    return {name: random_5bit_value(rng) for name in SIGNAL_ORDER}


def generate_dataset(num_tests: int = NUM_TESTS_DEFAULT, seed: int = SEED_DEFAULT) -> List[Dict[str, int]]:
    rng = random.Random(seed)
    return [generate_test_vector(rng) for _ in range(num_tests)]


def write_vectors_file(vectors: List[Dict[str, int]], path: Path) -> None:
    with path.open("w", encoding="utf-8") as f:
        for idx, vec in enumerate(vectors):
            values = [str(vec[name]) for name in SIGNAL_ORDER]
            f.write(f"{idx} " + " ".join(values) + "\n")


def write_expected_file(vectors: List[Dict[str, int]], path: Path) -> None:
    with path.open("w", encoding="utf-8") as f:
        for idx, vec in enumerate(vectors):
            out = run_golden(vec)
            f.write(f"{idx} {out['out0']} {out['out1']} {out['out0_ready']} {out['out1_ready']}\n")


def main() -> None:
    this_dir = Path(__file__).resolve().parent
    build_dir = this_dir.parent.parent / "build"
    build_dir.mkdir(parents=True, exist_ok=True)

    vectors = generate_dataset()
    vec_file = build_dir / "scoreboard_vectors.txt"
    exp_file = build_dir / "scoreboard_expected.txt"

    write_vectors_file(vectors, vec_file)
    write_expected_file(vectors, exp_file)

    print(f"[PY] Generated {len(vectors)} tests")
    print(f"[PY] Vectors : {vec_file}")
    print(f"[PY] Expected: {exp_file}")


if __name__ == "__main__":
    main()