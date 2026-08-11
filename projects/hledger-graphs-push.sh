source "$HOOKS_DIR/projects/go-common-push.sh"

echo "pre-push: fuzzing (10s)..."
(cd "$ROOT" && go test ./ledger/... -fuzz=FuzzParseFile -fuzztime=10s)
