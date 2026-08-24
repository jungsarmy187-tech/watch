#!/usr/bin/env bash
#
# check.sh - prueft einen X-(Twitter-)Account und schickt eine ntfy-Push,
# sobald ein neuer Post erkannt wird. Laeuft in GitHub Actions (kein PC noetig).
#
set -euo pipefail

USER_HANDLE="${USER_HANDLE:-cyberleeeknet}"
NTFY_TOPIC="${NTFY_TOPIC:?NTFY_TOPIC ist nicht gesetzt}"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"

# --- Profil abrufen: fxtwitter, sonst vxtwitter als Fallback ---------------
count=""
name=""

resp="$(curl -fsSL -A "$UA" "https://api.fxtwitter.com/${USER_HANDLE}" || true)"
if [ -n "$resp" ]; then
  count="$(echo "$resp" | jq -r '.user.tweets // empty')"
  name="$(echo "$resp"  | jq -r '.user.name  // empty')"
fi

if [ -z "$count" ]; then
  resp="$(curl -fsSL -A "$UA" "https://api.vxtwitter.com/${USER_HANDLE}" || true)"
  if [ -n "$resp" ]; then
    count="$(echo "$resp" | jq -r '.tweets // empty')"
    name="$(echo "$resp"  | jq -r '.name   // empty')"
  fi
fi

if ! [[ "$count" =~ ^[0-9]+$ ]]; then
  echo "Konnte Profil nicht abrufen (Dienst evtl. kurz nicht erreichbar) - ueberspringe."
  exit 0
fi
[ -z "$name" ] && name="$USER_HANDLE"

# ntfy-Header muessen ASCII sein -> Umlaute ersetzen, Rest strippen
title_name="$(echo "$name" \
  | sed -e 's/ä/ae/g;s/ö/oe/g;s/ü/ue/g;s/Ä/Ae/g;s/Ö/Oe/g;s/Ü/Ue/g;s/ß/ss/g' \
  | LC_ALL=C tr -cd '\11\12\40-\176')"
[ -z "$title_name" ] && title_name="X-Watcher"

# --- Zustand laden ----------------------------------------------------------
old=""
[ -f state.txt ] && old="$(tr -cd '0-9' < state.txt)"

echo "alt=${old:-<leer>}  neu=$count"

if [ -z "$old" ]; then
  echo "$count" > state.txt
  echo "Erster Lauf: Basiswert auf $count gesetzt (keine Meldung)."
  exit 0
fi

if [ "$count" -gt "$old" ]; then
  delta=$((count - old))
  if [ "$delta" -eq 1 ]; then wort="einen neuen Post"; else wort="$delta neue Posts"; fi
  curl -fsSL \
    -H "Title: Neuer Post von ${title_name}" \
    -H "Tags: bell" \
    -H "Priority: high" \
    -H "Click: https://x.com/${USER_HANDLE}" \
    -d "@${USER_HANDLE} hat ${wort} gemacht (jetzt ${count} Posts). Zum Oeffnen tippen." \
    "https://ntfy.sh/${NTFY_TOPIC}" >/dev/null
  echo "$count" > state.txt
  echo "Push gesendet: $wort."
elif [ "$count" -lt "$old" ]; then
  echo "$count" > state.txt
  echo "Post-Zahl gesunken ($old -> $count), Basiswert angepasst."
else
  echo "keine Aenderung ($count Posts)."
fi
