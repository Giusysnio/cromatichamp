#!/usr/bin/env bash
# =============================================================================
# setup-roadmap-table.sh
# Crea la roadmap di Cromatichamp come TABELLA / BOARD (GitHub Project), senza
# issue, label o milestone: solo righe con le colonne Versione, Area e Stato.
# Stato: Task, In corso, Revisione, Testato, Fatto.
#
# Requisiti: gh installata e autenticata, con il permesso "project":
#            gh auth refresh -s project,read:project
# Uso:       ./scripts/setup-roadmap-table.sh --dry-run   # mostra le righe
#            ./scripts/setup-roadmap-table.sh             # crea la tabella
#
# Rilanciabile: riusa il Project esistente e salta le righe già presenti.
# Dopo l'esecuzione (a mano, da web): crea le viste Tabella e Board (raggruppa per
# Stato) ed elimina il campo predefinito "Status". Su Windows usa Git Bash.
# =============================================================================
set -euo pipefail

TITLE="Cromatichamp Roadmap"
VERSIONI="v0.1.0,v0.2.0,v0.3.0,v0.4.0,v0.5.0,v0.6.0,v0.7.0,v0.8.0,v0.9.0,v1.0.0"
AREE="Frontend,Motore colore,Backend,Sicurezza,DevOps,Qualità,Docs"
STATI="Task,In corso,Revisione,Testato,Fatto"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# --- Dati: versione|area|attività|descrizione (evitare "|" nei testi) ---------
read -r -d '' ROWS <<'EOF' || true
v0.1.0|DevOps|Creare la struttura del monorepo|Cartelle frontend e backend nella radice, con .gitignore e .editorconfig condivisi.
v0.1.0|Frontend|Creare il progetto Angular in frontend|Angular CLI con TypeScript strict, routing, componenti standalone, CSS. Criterio: ng serve e ng build funzionano.
v0.1.0|Backend|Creare il progetto Spring Boot in backend|Spring Initializr (Maven, Java, Web, Validation, Actuator). Criterio: l'app parte e l'endpoint di health risponde.
v0.1.0|Qualità|Configurare ESLint (angular-eslint) e Prettier|Lint e formattazione automatici per il frontend.
v0.1.0|Qualità|Configurare formattazione e analisi statica del backend|Spotless o Checkstyle integrati in Maven.
v0.1.0|DevOps|Configurare Husky, lint-staged e commitlint|Hook Git nella radice: controlli sui file modificati e messaggi Conventional Commits.
v0.1.0|DevOps|Aggiungere Docker Compose con PostgreSQL|Database locale avviabile con un solo comando; credenziali in file .env non versionato.
v0.1.0|DevOps|Configurare CI su GitHub Actions|Due job: frontend (lint, test, build) e backend (test, build).
v0.1.0|Docs|Aggiungere README, CONTRIBUTING e CHANGELOG|Documenti base del repository, con link al Capitolato.
v0.1.0|Docs|Aggiungere il template per le pull request|Checklist con test e documentazione.
v0.2.0|Frontend|CameraService con getUserMedia|Mostra il flusso video; preferisce la camera posteriore (RF-01).
v0.2.0|Frontend|Gestione permessi negati e fallback|Messaggio chiaro e caricamento immagine come alternativa (RF-02).
v0.2.0|Frontend|Selezione fotocamera anteriore e posteriore|Pulsante per cambiare camera se ne esistono più di una.
v0.2.0|Frontend|Componente mirino e area di campionamento|Overlay che indica l'area analizzata (RF-03).
v0.2.0|Frontend|Campionamento della media su area NxN con canvas|SamplerService: media RGB dell'area, N configurabile (RF-04).
v0.2.0|Frontend|Congelamento del fotogramma|Blocca il fotogramma per analizzarlo (RF-09).
v0.3.0|Motore colore|Conversione sRGB, XYZ e CIE Lab|Funzioni TypeScript pure in core/color, senza dipendenze da Angular (RF-05).
v0.3.0|Motore colore|Implementare CIEDE2000|Calcolo del Delta E con la formula CIEDE2000.
v0.3.0|Motore colore|Catalogo colori aperto in JSON e CatalogService locale|Dataset con licenza aperta, schema id/name/hex, fonte e licenza nel README.
v0.3.0|Motore colore|Ricerca delle N corrispondenze migliori|Ordinamento per Delta E e prime N (RF-06).
v0.3.0|Qualità|Test unitari del motore colore|Valori di riferimento noti; copertura almeno 80%.
v0.4.0|Frontend|Routing e struttura delle pagine|Pagine camera, risultati e cronologia con lazy loading.
v0.4.0|Frontend|Pagina risultati con candidati|Colore campionato e lista delle corrispondenze (RF-07).
v0.4.0|Frontend|Delta E e indicatore di affidabilità|Scala qualitativa: ottima, buona, approssimativa.
v0.4.0|Frontend|Copia valori HEX, RGB e Lab|Copia negli appunti con feedback visivo (RF-08).
v0.4.0|Frontend|Cronologia locale delle rilevazioni|localStorage con signals, modalità ospite (RF-12).
v0.5.0|Frontend|Modalità di calibrazione|Flusso guidato con riferimento bianco o grigio (RF-10).
v0.5.0|Motore colore|Correzione colore basata sul riferimento|Fattori di correzione per canale applicati al campionamento.
v0.5.0|Frontend|Suggerimenti su luce e riflessi|Messaggi contestuali, ad esempio immagine troppo scura (RF-11).
v0.6.0|Backend|Entità Color con JPA e migrazioni Flyway|Modello dati del catalogo e prima migrazione su PostgreSQL.
v0.6.0|Backend|Seed del catalogo colori aperto|Caricamento dei colori del dataset aperto tramite migrazione.
v0.6.0|Backend|API REST del catalogo con paginazione e ricerca|Endpoint pubblico di lettura con ricerca per nome (RF-20).
v0.6.0|Backend|Documentazione API con OpenAPI e Swagger UI|Integrazione di springdoc-openapi (RF-26).
v0.6.0|Backend|Configurazione CORS e profili dev e prod|Profili Spring separati; CORS limitato al frontend.
v0.6.0|Backend|Gestione errori uniforme e validazione input|Risposte di errore in formato coerente (RF-27).
v0.6.0|Qualità|Test dell'API del catalogo|Test unitari dei servizi e di integrazione dei controller.
v0.6.0|Frontend|CatalogService con API e fallback al JSON locale|Se l'API non risponde si usa il catalogo incluso nell'app.
v0.7.0|Sicurezza|Registrazione utente con password cifrata|Validazione e password salvata con BCrypt (RF-21).
v0.7.0|Sicurezza|Login con token JWT|JWT con scadenza breve (RF-22).
v0.7.0|Sicurezza|Spring Security: protezione degli endpoint|Pubblici solo catalogo, registrazione e login (RF-25).
v0.7.0|Backend|Cancellazione dell'account (DELETE /me)|Elimina utente, palette e cronologia dell'utente autenticato (RF-28).
v0.7.0|Frontend|Pagine di login e registrazione|Form con validazione e messaggi di errore chiari.
v0.7.0|Frontend|Interceptor HTTP e guard per le rotte protette|Token nelle richieste e gestione della scadenza.
v0.7.0|Qualità|Test di sicurezza e autenticazione|Accessi consentiti e negati; nessun accesso ai dati di altri utenti.
v0.8.0|Motore colore|Estrazione palette con k-means|Colori dominanti da un'immagine, valutando un Web Worker (RF-13).
v0.8.0|Backend|API CRUD delle palette per utente|Gestione delle proprie palette (RF-23).
v0.8.0|Backend|API della cronologia delle rilevazioni|Salvataggio e lettura della cronologia dell'utente (RF-24).
v0.8.0|Frontend|Salvataggio e gestione delle palette|Su account se autenticati, in locale se ospiti (RF-14).
v0.8.0|Frontend|Esportazione in CSS variables e JSON|Palette esportabile in formati riutilizzabili (RF-14).
v0.8.0|Qualità|Test delle API palette e cronologia|Test di integrazione, compresi gli accessi non autorizzati.
v0.9.0|Frontend|Manifest e service worker (PWA)|App installabile con il supporto PWA di Angular (RF-15).
v0.9.0|Frontend|Funzionamento offline|Caching di asset e catalogo; modalità ospite provata in modalità aereo.
v0.9.0|Qualità|Audit di accessibilità|Contrasto, tastiera, ARIA; conformità WCAG 2.1 AA.
v0.9.0|Qualità|Ottimizzazione delle prestazioni|Lighthouse almeno 90 in tutte le categorie.
v1.0.0|DevOps|Deploy del backend con database|HTTPS, PostgreSQL gestito, segreti nelle variabili d'ambiente.
v1.0.0|DevOps|Deploy del frontend in HTTPS|GitHub Pages, Vercel o Netlify, collegato al backend di produzione.
v1.0.0|Qualità|Test su dispositivi reali iOS e Android|Verifica manuale con checklist e limiti noti.
v1.0.0|Docs|README finale e documentazione API|GIF di utilizzo, istruzioni, fonti dati, disclaimer sulla precisione, link a Swagger UI.
v1.0.0|Docs|Tag v1.0.0 e release notes|Aggiornare il CHANGELOG, creare tag e GitHub Release.
EOF

TOTAL=$(grep -c . <<<"$ROWS")

if $DRY_RUN; then
  echo ">>> DRY-RUN: nessuna modifica. Righe che verrebbero create: $TOTAL <<<"
  while IFS='|' read -r ver area title body; do
    printf '  %-7s %-14s %s\n' "$ver" "$area" "$title"
  done <<<"$ROWS"
  exit 0
fi

# --- Controlli iniziali ------------------------------------------------------
command -v gh >/dev/null 2>&1 || { echo "Errore: gh non trovata (https://cli.github.com)"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Errore: esegui prima gh auth login"; exit 1; }

REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null) \
  || { echo "Errore: esegui lo script dentro il repository."; exit 1; }
OWNER=${REPO%%/*}
echo "Repository: $REPO"

# --- 1) Project: riusa se esiste, altrimenti crea -----------------------------
NUM=$(gh project list --owner "$OWNER" --format json \
      --jq ".projects[] | select(.title==\"$TITLE\") | .number" 2>/dev/null | head -n1 || true)
if [[ -z "${NUM:-}" ]]; then
  NUM=$(gh project create --owner "$OWNER" --title "$TITLE" --format json --jq .number)
  echo "Tabella creata: n. $NUM"
else
  echo "Tabella esistente: n. $NUM"
fi
gh project link "$NUM" --owner "$OWNER" --repo "$REPO" >/dev/null 2>&1 || true
PID=$(gh project view "$NUM" --owner "$OWNER" --format json --jq .id)

# --- 2) Colonne (campi): Versione, Area e Stato --------------------------------------
list_fields() {
  gh project field-list "$NUM" --owner "$OWNER" --format json --limit 100 \
    --jq '.fields[] | "\(.name)|\(.id)"'
}
list_options() {
  gh project field-list "$NUM" --owner "$OWNER" --format json --limit 100 \
    --jq '.fields[] | select(.options != null) | .name as $f | .options[] | "\($f)|\(.name)|\(.id)"'
}

FIDS=$(list_fields)
if ! grep -q '^Versione|' <<<"$FIDS"; then
  gh project field-create "$NUM" --owner "$OWNER" --name "Versione" \
     --data-type SINGLE_SELECT --single-select-options "$VERSIONI" >/dev/null
  echo "Colonna creata: Versione"
fi
if ! grep -q '^Area|' <<<"$FIDS"; then
  gh project field-create "$NUM" --owner "$OWNER" --name "Area" \
     --data-type SINGLE_SELECT --single-select-options "$AREE" >/dev/null
  echo "Colonna creata: Area"
fi

CREATED_STATO=false
if ! grep -q '^Stato|' <<<"$FIDS"; then
  gh project field-create "$NUM" --owner "$OWNER" --name "Stato" \
     --data-type SINGLE_SELECT --single-select-options "$STATI" >/dev/null
  CREATED_STATO=true
  echo "Colonna creata: Stato"
fi

FIDS=$(list_fields)
OPTS=$(list_options)
fid() { grep -m1 "^$1|" <<<"$FIDS" | cut -d'|' -f2 || true; }
oid() { grep -m1 "^$1|$2|" <<<"$OPTS" | cut -d'|' -f3 || true; }

F_VER=$(fid "Versione")
F_AREA=$(fid "Area")
F_STATO=$(fid "Stato")
O_TASK=$(oid "Stato" "Task")
[[ -z "$F_VER" || -z "$F_AREA" || -z "$F_STATO" || -z "$O_TASK" ]] && { echo "Errore: colonne non trovate."; exit 1; }

# --- 3) Righe ------------------------------------------------------------------
EXISTING=$(gh project item-list "$NUM" --owner "$OWNER" --format json --limit 500 \
           --jq '.items[].title' 2>/dev/null || true)

N=0; SKIP=0
while IFS='|' read -r -u 3 ver area title body; do
  [[ -z "$ver" ]] && continue
  if grep -Fxq -- "$title" <<<"$EXISTING"; then
    SKIP=$((SKIP + 1)); continue
  fi
  ITEM=$(gh project item-create "$NUM" --owner "$OWNER" --title "$title" --body "$body" \
         --format json --jq .id </dev/null)
  gh project item-edit --id "$ITEM" --project-id "$PID" --field-id "$F_VER" \
     --single-select-option-id "$(oid Versione "$ver")" </dev/null >/dev/null
  gh project item-edit --id "$ITEM" --project-id "$PID" --field-id "$F_AREA" \
     --single-select-option-id "$(oid Area "$area")" </dev/null >/dev/null
  gh project item-edit --id "$ITEM" --project-id "$PID" --field-id "$F_STATO" \
     --single-select-option-id "$O_TASK" </dev/null >/dev/null
  N=$((N + 1))
  echo "  ok ($N/$TOTAL) [$ver] $title"
  sleep 1  # evita i limiti di richieste dell'API GitHub
done 3<<<"$ROWS"

# --- 4) Se la colonna Stato è nuova, porta in "Task" anche le righe già esistenti
if $CREATED_STATO && [[ $SKIP -gt 0 ]]; then
  echo "Imposto lo stato Task sulle righe già presenti..."
  while IFS= read -r -u 4 id; do
    [[ -z "$id" ]] && continue
    gh project item-edit --id "$id" --project-id "$PID" --field-id "$F_STATO" \
       --single-select-option-id "$O_TASK" </dev/null >/dev/null
  done 4< <(gh project item-list "$NUM" --owner "$OWNER" --format json --limit 500 --jq '.items[].id')
fi

echo
echo "Fatto: $N righe create, $SKIP già presenti."
echo "Apri la tabella: https://github.com/users/$OWNER/projects/$NUM"
