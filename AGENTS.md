# AGENTS.md

The official plugin list for ranma: `plugins.json`, read by hako's Browse.
The format is hako's `doc/LISTS.md`; `README.md` says what review means.

- Push to `main` for changes to this repository itself; a new plugin comes as
  a pull request and is reviewed as README.md says before it is merged.
- Entries stay in alphabetical order by `repo`.
- `scripts/check.sh` before a commit (CI runs it too). With an unpushed hako
  change to the format: `HAKO_DIR=~/projects/hako.ranma scripts/check.sh`.
- A field the format does not have is a hako change first (its `lists.lua`
  and `doc/LISTS.md`), never an entry here: hako refuses unknown fields.
- `AGENTS.local.md` (gitignored) carries what is true of one checkout on one
  machine. Never commit it.
