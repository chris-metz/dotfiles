#!/bin/bash
# SwiftBar plugin: shows the nuc-tunnel fish function's state, a click toggles it.
# Below that, the ports the tunnel always forwards, with a dialog to add one and a
# submenu to remove one, and the apps Bauhof runs for an Abnahme; a click forwards one
# through the tunnel and opens it.
# ".10s" in the file name makes SwiftBar rerun it every 10 seconds.
fish=/opt/homebrew/bin/fish
toggle="bash=$fish param1=-c param2=nuc-tunnel terminal=false refresh=true"
# Bauhof's address and the per-project app URLs, kept on this Mac rather than in the repo
config=~/.config/nuc-tunnel

# A click reruns the plugin as: open <port> <url>, add, or remove <port>
case $1 in
  open)
    [[ $2 =~ ^[0-9]+$ && $3 =~ ^https?:// ]] || exit 1
    $fish -c "nuc-tunnel open $2" && open "$3"
    exit
    ;;
  add)
    # Cancel makes osascript fail, and leaves nothing to do
    port=$(osascript -e 'text returned of (display dialog "Welchen Port soll der Tunnel immer weiterleiten?" default answer "" with title "NUC-Tunnel")') || exit 0
    # nuc-tunnel checks the port and says why it refuses one; as an argument, not
    # inside the command, so that the text typed in stays text
    if ! error=$($fish -c 'nuc-tunnel add $argv' -- "${port//[[:space:]]/}" 2>&1 >/dev/null); then
      osascript -e 'on run argv' -e 'display alert "Port nicht hinzugefügt" message (item 1 of argv)' -e 'end run' "$error" >/dev/null
    fi
    exit
    ;;
  remove)
    [[ $2 =~ ^[0-9]+$ ]] || exit 1
    $fish -c "nuc-tunnel remove $2"
    exit
    ;;
esac

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

# The ports on the list, each with a submenu to remove it, then those forwarded only
# for now (by hand or for an Abnahme)
print_ports() {
  local port
  for port in "${ports[@]}"; do
    if [[ " ${forwarded[*]} " == *" $port "* ]]; then
      echo "localhost:$port → nucubuntu | size=11"
    else
      echo "localhost:$port · frei | size=11"
    fi
    echo "--Entfernen | bash=$0 param1=remove param2=$port terminal=false refresh=true"
  done
  for port in "${forwarded[@]}"; do
    [[ " ${ports[*]} " == *" $port "* ]] || echo "localhost:$port → nucubuntu | size=11"
  done
  echo "Port hinzufügen… | bash=$0 param1=add terminal=false refresh=true"
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
# The ports the tunnel always forwards, from ~/.config/nuc-tunnel/ports. Numbers only,
# so splitting them on line breaks is safe.
ports=($($fish -c 'nuc-tunnel ports'))

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
  print_ports
  print_apps
  echo "---"
  echo "Ausschalten | $toggle"
else
  echo "NUC | sfimage=circle"
  echo "---"
  echo "Tunnel aus | sfimage=circle"
  print_ports
  print_apps
  echo "---"
  echo "Einschalten | $toggle"
fi
