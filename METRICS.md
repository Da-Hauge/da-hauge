# Profile card setup

## Why the old card died

`README.md` used to contain nothing but an image hot-linked from
`metrics.lecoq.io`. That hosted instance now returns
`HTTP 500 - Internal Server Error: failed to process metrics correctly`,
so the profile rendered as one broken image and nothing else.

The workflow that was supposed to be the local alternative never worked
either: it passed `token: ${{ secrets.METRICS_TOKEN }}` while this repo has no
secrets configured, and `token` is a **required** input of the action. Every
one of its 92 scheduled runs failed in under a minute.

## The workflow in this repo

`.github/workflows/metrics.yml` renders the card with
[lowlighter/metrics](https://github.com/lowlighter/metrics) (pinned to `v3.34`)
and commits it here as `github-metrics.svg`. The README will then reference a
file in this repo rather than someone else's server, so no outage can blank the
page again.

Two things are still needed before it produces anything:

### 1. Actions has to be running

Pushing this workflow to a branch triggered **no run at all** - no queued job,
no check run, nothing in the Actions API. Open the Actions tab:

<https://github.com/Da-Hauge/da-hauge/actions>

GitHub disables workflows after a long period of repository inactivity (the last
run here was 2025-12-15) and shows a banner with an **Enable** button. Click it,
then re-run the workflow manually.

### 2. METRICS_TOKEN (optional, for the full card)

The workflow falls back to the built-in `GITHUB_TOKEN`, which renders the base
card but cannot see private-repo stats, follower data or traffic. For the full
version:

1. Create a **classic** token at <https://github.com/settings/tokens/new>
2. Scopes: `repo`, `read:user`, `read:org`
3. Add it as a repo secret named `METRICS_TOKEN`:
   <https://github.com/Da-Hauge/da-hauge/settings/secrets/actions/new>

It is picked up automatically on the next run.

## Once the first run succeeds

`github-metrics.svg` will appear in the repo root. Add this line at the top of
`README.md` to display it:

```markdown
[![Metrics](./github-metrics.svg)](https://github.com/Da-Hauge)
```

It is deliberately **not** in the README yet - embedding an image that does not
exist would put a broken image back on the profile, which is the bug this is
meant to fix.

## Notes on what changed from the old workflow

- `steam` and `traffic` plugins removed: both need credentials that are not
  configured (`STEAM_TOKEN`, and a PAT with `repo` scope respectively).
- Cron moved from hourly to daily - the stats do not change fast enough to
  justify 24 renders a day.
