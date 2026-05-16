#!/usr/bin/env bash
# tools/diff_sram_size.sh <design> <platform>
#
# Extract (macro, SIZE_X, SIZE_Y) from each LEF in
# designs/<platform>/<design>/sram/lef/*.lef (current worktree) and compare
# against the version at git HEAD. Prints a markdown table with area_pct,
# aspect ratios, and a flag column. Useful as a pre-commit gate after
# regenerate_sram.sh runs.
#
# Usage: tools/diff_sram_size.sh <design> <platform>

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <design> <platform>" >&2
  exit 2
fi

DESIGN=$1
PLAT=$2
ROOT=$(git rev-parse --show-toplevel)
LEF_DIR="designs/$PLAT/$DESIGN/sram/lef"

if [[ ! -d "$ROOT/$LEF_DIR" ]]; then
  echo "error: $ROOT/$LEF_DIR does not exist" >&2
  exit 1
fi

printf '| macro | old W×H (µm²) | new W×H (µm²) | Δarea | old aspect | new aspect | flag |\n'
printf '|---|---|---|---|---|---|---|\n'

cd "$ROOT"
for new in "$LEF_DIR"/*.lef; do
  name=$(basename "$new" .lef)
  new_size=$(awk '/^  SIZE/{print $2, $4; exit}' "$new")
  read -r new_w new_h <<< "$new_size"
  if git cat-file -e "HEAD:$new" 2>/dev/null; then
    old_size=$(git show "HEAD:$new" | awk '/^  SIZE/{print $2, $4; exit}')
    read -r old_w old_h <<< "$old_size"
  else
    old_w=NA; old_h=NA
  fi
  python3 - "$name" "$old_w" "$old_h" "$new_w" "$new_h" <<'PY'
import sys
name, old_w, old_h, new_w, new_h = sys.argv[1:6]
def fnum(s):
    try: return float(s)
    except ValueError: return None
ow, oh, nw, nh = map(fnum, (old_w, old_h, new_w, new_h))
def aspect(w, h):
    if w is None or h is None or min(w, h) == 0: return None
    return max(w, h) / min(w, h)
old_area = ow * oh if ow and oh else None
new_area = nw * nh if nw and nh else None
old_asp = aspect(ow, oh)
new_asp = aspect(nw, nh)
area_pct = (100 * (new_area - old_area) / old_area) if old_area and new_area else None
flag = "OK"
if old_area is None:
    flag = "NEW"
elif area_pct is not None and abs(area_pct) > 25:
    flag = f"AREA Δ{area_pct:+.0f}%"
elif old_asp and new_asp and (max(old_asp, new_asp) / min(old_asp, new_asp)) > 2:
    flag = "ASPECT>2x"
def fmt_size(w, h):
    if w is None or h is None: return "—"
    return f"{w:.2f}×{h:.2f} ({w*h:.0f})"
def fmt_pct(p): return f"{p:+.1f}%" if p is not None else "—"
def fmt_asp(a): return f"{a:.2f}" if a is not None else "—"
print(f"| `{name}` | {fmt_size(ow, oh)} | {fmt_size(nw, nh)} | {fmt_pct(area_pct)} | {fmt_asp(old_asp)} | {fmt_asp(new_asp)} | {flag} |")
PY
done
