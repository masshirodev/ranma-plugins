# ranma plugins

The official plugin list for [ranma](https://github.com/masshirodev/ranma),
the terminal tiling window manager. [hako](https://github.com/masshirodev/hako.ranma),
the plugin manager ranma ships with, shows it in **Browse** (`leader L`, then
`B`): every plugin here, installed with one key.

`plugins.json` is the whole list. Its format is hako's
[`doc/LISTS.md`](https://github.com/masshirodev/hako.ranma/blob/main/doc/LISTS.md).

## Adding a plugin

Open a pull request that adds its entry to `plugins.json`, in alphabetical
order by repository:

```json
{
  "repo": "you/thing.ranma",
  "description": "What it does, in one or two sentences.",
  "tags": ["panes"],
  "needs": ["git"],
  "ranma": "0.1.0"
}
```

`needs` lists programs it uses outside ranma; `ranma` is the oldest ranma
it works with.

## What "reviewed" means

hako tells people that this list, unlike any other, is reviewed before a
plugin goes on it: a plugin is Lua that runs as you, and can read your files
and run any program. So before an entry is merged, someone reads the
plugin's code and checks that:

- it does what its description says, and nothing it does not say (no network
  calls, files written or programs run that its description does not
  explain)
- it loads cleanly into the latest ranma release (CI checks this)
- its repository has a license and a README saying how to use it
- it follows ranma's plugin rules: strict options, nothing on the render
  path (ranma's [`CONTRIBUTING.md`](https://github.com/masshirodev/ranma/blob/main/CONTRIBUTING.md))

Review is of the commit merged. Later commits are the author's; a plugin that
turns into something else is taken off the list.

## Checks

`scripts/check.sh` reads `plugins.json` with hako's own reader (what Browse
does), then clones every plugin and loads it into ranma. CI runs it on every
pull request, on every push to `main`, and weekly, against the latest ranma
release, so a plugin that stops loading is noticed.

```sh
scripts/check.sh                                  # needs ranma and git
HAKO_DIR=~/projects/hako.ranma scripts/check.sh   # with a hako checkout
```

## Your own list

Anyone can publish a list in the same format, anywhere `curl` can fetch it,
and anyone can add it to their Browse (`a`, then its URL). Those lists are
not reviewed, and hako says so before adding one.

## License

MIT or Apache-2.0, as ranma.
