# Shared Go repo checks (hledger-graphs, pth): gofmt, vet, test. Sourced by
# each repo's projects/<name>.sh; $ROOT set by pre-commit.

unformatted="$(cd "$ROOT" && gofmt -l .)"
if [ -n "$unformatted" ]; then
    echo "✗ these files aren't gofmt'd:" >&2
    echo "$unformatted" >&2
    echo "Run: gofmt -w ." >&2
    exit 1
fi

echo "pre-commit: go vet..."
(cd "$ROOT" && go vet ./...)

echo "pre-commit: go test..."
(cd "$ROOT" && go test ./...)
