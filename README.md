# hooks

My git hooks: common guards for every repo + per-repo specialisations,
one dispatcher per hook stage.

## Layout

- `pre-commit` - entrypoint. Sources `common.sh`, then the repo's script
  (matched on repo directory name in a case block).
- `pre-push` - entrypoint. No universal checks yet; dispatches straight to
  the repo's `projects/<name>-push.sh` (same case-block pattern).
- `common.sh` - every repo: no em dashes in newly added lines.
- `commit-msg` - every repo: block AI/co-author attribution trailers and
  em dashes in commit messages. (Message checks can't run in pre-commit;
  the message doesn't exist yet at that point.)
- `projects/hledger.sh` - finances: auto-format staged journals (hledger-fmt), ban
  inline amount+assert lines, ban em dashes in `years/*.journal`, validate
  (`hledger check --strict ordereddates tags`).
- `projects/go-common.sh` - shared pre-commit checks for Go repos: gofmt,
  vet, test. `projects/hledger-graphs.sh` and `projects/pth.sh` just source it.
- `projects/go-common-push.sh` - shared pre-push check for Go repos:
  coverage. `projects/hledger-graphs-push.sh` and `projects/pth-push.sh`
  source it and then add their own short (10s) fuzz run against their
  repo's Fuzz* target.
- `projects/routines.sh` - regenerates the markdown export, runs the stdlib
  unittest suite, and (if the repo's opt-in .venv exists) ruff + the
  Hypothesis fuzz test.

## Setup (once per machine)

```
git clone https://github.com/conor-sometimes/hooks ~/hooks
git config --global core.hooksPath ~/hooks
```

Repos must NOT set a local `core.hooksPath`; it would override the global.

## Adding a repo specialisation

1. Write `projects/<name>.sh` (sourced with `$ROOT` = repo root, `$HOOKS_DIR` set;
   `exit 1` aborts the commit).
2. Add a line to the case block in `pre-commit`:
   `myrepo)  source "$HOOKS_DIR/projects/myrepo.sh" ;;`
3. Commit + push; `git -C ~/hooks pull` on other machines.

A brand-new repo needs NOTHING: common checks apply automatically via the
global hooksPath.
