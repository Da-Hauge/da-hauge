# Profile card setup

`README.md` embeds `github-metrics.svg`, which is rendered by
[lowlighter/metrics](https://github.com/lowlighter/metrics) in
`.github/workflows/metrics.yml` and committed straight into this repo.

Nothing is fetched from a third-party host at page-render time. That is the
difference from the old setup, which pointed at `metrics.lecoq.io` and went
blank when that service started returning HTTP 500.

## Adding METRICS_TOKEN (optional, for the full card)

The workflow falls back to the built-in `GITHUB_TOKEN`, which renders the card
but only sees public data. For private-repo stats, follower/following data and
traffic, add a personal access token:

1. Create a **classic** token at <https://github.com/settings/tokens/new>
   (no expiry, or set a reminder to rotate it).
2. Scopes: `repo`, `read:user`, `read:org`.
3. Add it to this repo as a secret named `METRICS_TOKEN`:
   <https://github.com/Da-Hauge/da-hauge/settings/secrets/actions/new>

The workflow picks it up automatically on the next run - no file changes needed.

> The original workflow failed on **every** run because it referenced
> `secrets.METRICS_TOKEN` while no such secret existed, and `token` is a
> required input.

## Re-rendering on demand

Actions tab -> **Metrics** -> **Run workflow**. Otherwise it runs daily at 06:17 UTC.
