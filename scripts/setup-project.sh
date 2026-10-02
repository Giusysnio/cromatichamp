#!/usr/bin/env bash
# =============================================================================
# setup-project.sh
# Crea un GitHub Project ("tabella" di roadmap), lo collega al repository
# e ci aggiunge tutte le issue esistenti.
#
# Requisiti: gh installata e autenticata, con il permesso "project":
#            gh auth refresh -s project
# Uso:       ./scripts/setup-project.sh
# Rilanciabile: se il Project esiste già, lo riusa.
# =============================================================================
set -euo pipefail

TITLE="Cromatichamp Roadmap"

command -v gh >/dev/null 2>&1 || { echo "Errore: gh non trovata."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Errore: esegui prima gh auth login"; exit 1; }

REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
OWNER=${REPO%%/*}
echo "Repository: $REPO"

# --- 1) Project: riusa se esiste, altrimenti crea ----------------------------
NUM=$(gh project list --owner "$OWNER" --format json \
      --jq ".projects[] | select(.title==\"$TITLE\") | .number" 2>/dev/null | head -n1 || true)

if [[ -z "${NUM:-}" ]]; then
  NUM=$(gh project create --owner "$OWNER" --title "$TITLE" --format json --jq .number)
  echo "Project creato: n. $NUM"
else
  echo "Project esistente: n. $NUM"
fi

# --- 2) Collega il Project al repository -------------------------------------
gh project link "$NUM" --owner "$OWNER" --repo "$REPO" >/dev/null 2>&1 || true

# --- 3) Aggiunge tutte le issue ----------------------------------------------
COUNT=0
while IFS= read -r -u 3 url; do
  [[ -z "$url" ]] && continue
  gh project item-add "$NUM" --owner "$OWNER" --url "$url" </dev/null >/dev/null
  COUNT=$((COUNT + 1))
  echo "  aggiunta ($COUNT): $url"
done 3< <(gh issue list --state all --limit 1000 --json url --jq '.[].url')

echo
echo "Fatto: $COUNT issue nel Project."
echo "Aprilo su: https://github.com/users/$OWNER/projects/$NUM"
