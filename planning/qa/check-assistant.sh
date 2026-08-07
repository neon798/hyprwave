#!/usr/bin/env bash
# Assistant package check: go test ./... when apps/hyprwave-assistant is present.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
cd "$ROOT"

CHECK_ID="assistant"
echo "== check-assistant (repo: $ROOT) =="

APP_DIR="apps/hyprwave-assistant"

if [[ ! -d "$APP_DIR" ]]; then
  qa_warn "${CHECK_ID}.tree" \
    "missing ${APP_DIR} — soft-skip until lane/c-assistant merged"
  if [[ -d planning/integration/c-assistant ]]; then
    qa_warn "${CHECK_ID}.snippets-only" \
      "integration snippets present without apps/ tree on this checkout"
  fi
  qa_print_summary "check-assistant"
  qa_exit_code
  exit $?
fi

qa_pass "${CHECK_ID}.tree" "${APP_DIR} present"

if [[ ! -f "${APP_DIR}/go.mod" ]]; then
  qa_fail "${CHECK_ID}.gomod" "missing ${APP_DIR}/go.mod"
  qa_print_summary "check-assistant"
  qa_exit_code
  exit $?
fi
qa_pass "${CHECK_ID}.gomod" "go.mod present"

if ! command -v go >/dev/null 2>&1; then
  qa_fail "${CHECK_ID}.go-toolchain" "go not installed on host — cannot run tests"
  qa_print_summary "check-assistant"
  qa_exit_code
  exit $?
fi
qa_pass "${CHECK_ID}.go-toolchain" "go $(go env GOVERSION 2>/dev/null || go version)"

# Network must not be required for tests (task contract for C). Use offline-friendly flags.
export GOFLAGS="${GOFLAGS:-}"
# Prevent accidental proxy fetches from failing CI hosts without net — try modules as-is first.

echo "-- go test ./... (cwd: ${APP_DIR}) --"
set +e
(
  cd "$APP_DIR"
  # -count=1 disables cache so results reflect tree; short timeout for host harness
  go test ./... -count=1 -timeout=120s
)
rc=$?
set -e

if [[ "$rc" -eq 0 ]]; then
  qa_pass "${CHECK_ID}.go-test" "go test ./... passed"
else
  qa_fail "${CHECK_ID}.go-test" "go test ./... failed (exit $rc)"
fi

# Optional: ensure no obvious network in tests via env leak check (soft)
if grep -RInE 'http\.(Get|Post|Head)|DefaultClient' \
  "${APP_DIR}"/*_test.go "${APP_DIR}"/**/*_test.go 2>/dev/null \
  | grep -vE 'httptest|example\.com|127\.0\.0\.1|localhost' >/dev/null 2>&1; then
  qa_warn "${CHECK_ID}.net-in-tests" \
    "tests may perform live HTTP — confirm offline safety"
else
  qa_pass "${CHECK_ID}.net-in-tests" "no obvious live-HTTP patterns in *_test.go"
fi

# Integration snippets hygiene when present
for snip in \
  planning/integration/c-assistant/build.sh.snippet \
  planning/integration/c-assistant/Containerfile.snippet; do
  if [[ -f "$snip" ]]; then
    qa_pass "${CHECK_ID}.snippet-$(basename "$snip")" "present: $snip"
  else
    qa_warn "${CHECK_ID}.snippet-$(basename "$snip")" "missing $snip"
  fi
done

qa_print_summary "check-assistant"
qa_exit_code
