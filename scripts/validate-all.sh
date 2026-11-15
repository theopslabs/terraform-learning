#!/usr/bin/env bash
# Validate every Terraform configuration in the course without touching AWS.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

while IFS= read -r dir; do
  echo "==> $dir"
  if ! (cd "$ROOT/$dir" && terraform init -backend=false -input=false >/dev/null && terraform validate); then
    failures=$((failures + 1))
  fi
done < <(find "$ROOT/labs" "$ROOT/capstone" "$ROOT/solutions" "$ROOT/resources/lab-template" \
  -name '*.tf' -printf '%h\n' 2>/dev/null | sort -u)

if [ "$failures" -ne 0 ]; then
  echo "Validation failed for $failures director(ies)."
  exit 1
fi

echo "All configurations validated."
