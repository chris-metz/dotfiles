#!/bin/bash
# SwiftBar plugin: shows the nuc-tunnel fish function's state, a click toggles it.
# Below that, the apps Bauhof runs for an Abnahme; a click forwards one through the
# tunnel and opens it.
# ".10s" in the file name makes SwiftBar rerun it every 10 seconds.
fish=/opt/homebrew/bin/fish
toggle="bash=$fish param1=-c param2=nuc-tunnel terminal=false refresh=true"
# Same ports as in nuc-tunnel.fish
ports=(3300 8025)
# Bauhof's address and the per-project app URLs, kept on this Mac rather than in the repo
config=~/.config/nuc-tunnel

# A click on an app reruns the plugin as: open <port> <url>
if [[ $1 == open ]]; then
  [[ $2 =~ ^[0-9]+$ && $3 =~ ^https?:// ]] || exit 1
  $fish -c "nuc-tunnel open $2" && open "$3"
  exit
fi

# The apps that run in Bauhof, one line each: port, end (HH:MM), label, repo.
# Fails without Bauhof, so that the section is left out.
running_apps() {
  local bauhof runs projects
  command -v jq >/dev/null || return 1
  bauhof=$(head -n 1 "$config/bauhof-url" 2>/dev/null | tr -d '[:space:]')
  [[ -n $bauhof ]] || return 1
  # Both together well within the 10 seconds between runs
  runs=$(curl -fsS --max-time 1.5 "${bauhof%/}/api/runs" 2>/dev/null) || return 1
  projects=$(curl -fsS --max-time 1.5 "${bauhof%/}/api/projects" 2>/dev/null) || return 1
  jq -r --argjson projects "$projects" '
    ($projects.projects | map({key: (.id | tostring), value: .repo}) | from_entries) as $repos
    | .runs[]
    | select(.app.state == "running")
    | (.app.url | capture(":(?<port>[0-9]+)/?$")? | .port) as $port
    | [$port,
       (.app.until | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601 | strflocaltime("%H:%M")),
       # A "|" would end the menu line early, a tab or line break the row
       (if .issue then "#\(.issue.number) \(.issue.title)" else "Lauf \(.id)" end
        | gsub("\\|"; "¦") | gsub("[\t\n\r]"; " ")),
       ($repos[.projectId | tostring] // "")]
    | join("\t")' <<<"$runs" 2>/dev/null
}

# The address a click opens: the project's line in app-urls, else localhost
app_url() {
  local repo=$1 port=$2 name template
  if [[ -n $repo && -r $config/app-urls ]]; then
    # The second test keeps a last line that has no line break
    while read -r name template _ || [[ -n $name ]]; do
      if [[ $name == "$repo" && $template =~ ^https?:// ]]; then
        echo "${template//\{port\}/$port}"
        return
      fi
    done <"$config/app-urls"
  fi
  echo "http://localhost:$port"
}

print_apps() {
  ((${#apps[@]})) || return
  echo "---"
  echo "Abnahmen"
  printf '%s\n' "${apps[@]}"
}

status=$($fish -c 'nuc-tunnel status')
# The ports from "nuc-tunnel: on (localhost:3300,8025,41234)"
forwarded=()
if [[ $status =~ \(localhost:([0-9,]+)\) ]]; then
  IFS=, read -ra forwarded <<<"${BASH_REMATCH[1]}"
fi

apps=()
if rows=$(running_apps); then
  needed=("${ports[@]}")
  while IFS=$'\t' read -r port until label repo; do
    [[ -n $port ]] || continue
    needed+=("$port")
    apps+=("$label · bis $until | bash=$0 param1=open param2=$port param3=$(app_url "$repo" "$port") terminal=false refresh=true")
  done <<<"$rows"
  # A forward no running app needs any more goes
  kept=()
  for port in "${forwarded[@]}"; do
    if [[ " ${needed[*]} " == *" $port "* ]]; then
      kept+=("$port")
    else
      $fish -c "nuc-tunnel close $port" >/dev/null
    fi
  done
  forwarded=("${kept[@]}")
fi

if [[ $status == *": on"* ]]; then
  echo "NUC | sfimage=circle.fill sfcolor=#2F9E4F"
  echo "---"
  echo "Tunnel an | sfimage=circle.fill sfcolor=#2F9E4F"
  for port in "${forwarded[@]}"; do
    echo "localhost:$port → nucubuntu | size=11"
  done
  print_apps
  echo "---"
  echo "Ausschalten | $toggle"
else
  echo "NUC | sfimage=circle"
  echo "---"
  echo "Tunnel aus | sfimage=circle"
  echo "Ports ${ports[*]} sind frei | size=11"
  print_apps
  echo "---"
  echo "Einschalten | $toggle"
fi
