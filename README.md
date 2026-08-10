# hooks

My git hooks: common guards for every repo + per-repo specialisations,
one dispatcher.

## Layout

- `pre-commit` - entrypoint. Sources `common.sh`, then the repo's script
  (matched on repo directory name in a case block).
- `common.sh` - every repo: no em dashes in newly added lines.
- `projects/hledger.sh` - finances: auto-format staged journals (hledger-fmt), ban
  inline amount+assert lines, ban em dashes in `years/*.journal`, validate
  (`hledger check --strict ordereddates tags`).
- `commit-msg` - every repo: block AI/co-author attribution trailers and
  em dashes in commit messages. (Message checks can't run in pre-commit;
  the message doesn't exist yet at that point.)

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
