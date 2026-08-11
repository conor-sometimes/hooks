# Shared Go repo pre-push check (hledger-graphs, pth): coverage (reported,
# not gated on a threshold yet). Sourced by projects/<name>-push.sh; $ROOT set
# by pre-push. Each repo's own script adds its fuzz target after sourcing this.

echo "pre-push: coverage..."
(cd "$ROOT" && go test ./... -cover)
