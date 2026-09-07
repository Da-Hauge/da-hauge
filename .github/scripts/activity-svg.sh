#!/usr/bin/env bash
# Renders a GitHub contribution grid as a dark-mode SVG.
#
# Data comes from GitHub's own GraphQL API, and the SVG is committed into this
# repo - nothing is fetched from a third-party renderer when the README loads.
# That matters here: ghchart, github-readme-stats and profile-trophy were all
# either returning 5xx or out of quota, and metrics.lecoq.io going down is what
# broke this profile in the first place.
set -euo pipefail

user="${1:?usage: activity-svg.sh <user> <outfile>}"
out="${2:?usage: activity-svg.sh <user> <outfile>}"

read -r -d '' query <<'GQL' || true
query($u: String!) {
  user(login: $u) {
    contributionsCollection {
      contributionCalendar {
        totalContributions
        weeks { firstDay contributionDays { contributionCount weekday } }
      }
    }
  }
}
GQL

read -r -d '' render <<'JQ' || true
.data.user.contributionsCollection.contributionCalendar as $c
| ([$c.weeks[].contributionDays[].contributionCount] | max) as $max
| {"01":"Jan","02":"Feb","03":"Mar","04":"Apr","05":"May","06":"Jun",
   "07":"Jul","08":"Aug","09":"Sep","10":"Oct","11":"Nov","12":"Dec"} as $mon
| 14 as $step | 12 as $pad | 30 as $top
| (($c.weeks | length) * $step - 3 + $pad * 2) as $w
| ($top + 7 * $step - 3 + $pad + 22) as $h
| ([ $c.weeks | to_entries[] as $wk
     | $wk.value.contributionDays[] as $d
     | ($d.contributionCount) as $n
     | (if   $n == 0            then "#161b22"
        elif $n <= $max * 0.25  then "#0e4429"
        elif $n <= $max * 0.5   then "#006d32"
        elif $n <= $max * 0.75  then "#26a641"
        else                         "#39d353" end) as $fill
     | "<rect x=\"\($wk.key * $step + $pad)\" y=\"\($d.weekday * $step + $top)\""
       + " width=\"11\" height=\"11\" rx=\"2\" fill=\"\($fill)\"/>"
   ] | join("")) as $cells
| ([ $c.weeks | to_entries[] as $wk
     | ($wk.value.firstDay[5:7]) as $m
     | select($wk.key > 0 and ($c.weeks[$wk.key - 1].firstDay[5:7]) != $m)
     | "<text x=\"\($wk.key * $step + $pad)\" y=\"22\" class=\"m\">\($mon[$m])</text>"
   ] | join("")) as $months
| "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\($w)\" height=\"\($h)\""
  + " viewBox=\"0 0 \($w) \($h)\" role=\"img\""
  + " aria-label=\"\($c.totalContributions) contributions in the last year\">"
  + "<style>.m,.c{font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif;fill:#7d8590}"
  + ".m{font-size:10px}.c{font-size:11px}</style>"
  + "<rect width=\"\($w)\" height=\"\($h)\" rx=\"6\" fill=\"#0d1117\"/>"
  + $months + $cells
  + "<text x=\"\($pad)\" y=\"\($h - 8)\" class=\"c\">\($c.totalContributions) contributions in the last year</text>"
  + "</svg>"
JQ

gh api graphql -f query="$query" -F u="$user" --jq "$render" > "$out"
printf 'wrote %s (%s bytes)\n' "$out" "$(wc -c < "$out")"
