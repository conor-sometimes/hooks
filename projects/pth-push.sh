source "$HOOKS_DIR/projects/go-common-push.sh"

echo "pre-push: fuzzing (10s)..."
(cd "$ROOT" && go test ./internal/model/ -fuzz=FuzzKeySequenceNeverCorruptsState -fuzztime=10s)
