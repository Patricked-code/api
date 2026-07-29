#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat "$ROOT"/001_core_parts/part_*.sql.part > "$ROOT/001_africafunds_core.sql"

echo "Assembled: $ROOT/001_africafunds_core.sql"
echo "Expected SHA-256: e00154738ced3004e8e034a679570d281886111aea65a2b6832b083bf5f3cf0e"
sha256sum "$ROOT/001_africafunds_core.sql"
