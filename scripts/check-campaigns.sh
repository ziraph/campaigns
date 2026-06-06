#!/usr/bin/env bash
# Verify the campaigns layout the `ziraph campaign remote <name>` resolver depends on:
#   1. each campaign subdir holds exactly one TOML, named campaign.toml
#   2. campaigns/index.json lists exactly the campaign subdirs that exist
# Run from the repo root:  bash scripts/check-campaigns.sh
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0

# 1) exactly one campaign.toml per campaign subdir
for d in campaigns/*/; do
  name=$(basename "$d")
  tomls=$(find "$d" -maxdepth 1 -name '*.toml' | wc -l | tr -d ' ')
  if [ "$tomls" -ne 1 ]; then
    echo "FAIL: $name has $tomls .toml file(s) (expected exactly 1)"; fail=1
  elif [ ! -f "${d}campaign.toml" ]; then
    echo "FAIL: $name's TOML is not named campaign.toml"; fail=1
  fi
done

# 2) index.json lists exactly the existing campaign subdirs
idx=campaigns/index.json
if [ ! -f "$idx" ]; then
  echo "FAIL: $idx missing"; fail=1
else
  listed=$(python3 -c "import json;print(chr(10).join(c['name'] for c in json.load(open('$idx'))))" | sort)
  actual=$(for d in campaigns/*/; do basename "$d"; done | sort)
  if [ "$listed" != "$actual" ]; then
    echo "FAIL: campaigns/index.json does not match the campaign subdirs:"
    diff <(echo "$listed") <(echo "$actual") || true
    fail=1
  fi
fi

[ "$fail" -eq 0 ] && echo "OK: campaigns layout + index are consistent"
exit $fail
