#!/usr/bin/env bash
# =============================================================================
# setup-roadmap.sh
# Crea su GitHub label, milestone e issue della roadmap di Cromatichamp
# (Angular + Spring Boot).
#
# Requisiti: GitHub CLI (gh) installata e autenticata (gh auth login).
# Uso:       ./scripts/setup-roadmap.sh --dry-run   # mostra cosa farebbe
#            ./scripts/setup-roadmap.sh             # esegue davvero
#
# Lo script è idempotente: se label, milestone o issue esistono già
# (stesso nome/titolo), vengono saltati. Si può rilanciare senza duplicati.
# Va eseguito dentro la cartella del repository clonato.
# =============================================================================
set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# --- Controlli iniziali ------------------------------------------------------
command -v gh >/dev/null 2>&1 || { echo "Errore: GitHub CLI (gh) non trovata. Installala da https://cli.github.com"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Errore: non sei autenticato. Esegui: gh auth login"; exit 1; }

REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null) \
  || { echo "Errore: esegui lo script dentro un repository collegato a GitHub."; exit 1; }

echo "Repository: $REPO"
$DRY_RUN && echo ">>> MODALITÀ DRY-RUN: nessuna modifica verrà effettuata <<<"
echo

# =============================================================================
# 1) LABEL            formato: nome|colore(hex senza #)|descrizione
# =============================================================================
echo "== Label =="
while IFS='|' read -r -u 3 name color desc; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  if $DRY_RUN; then
    echo "  [dry-run] label: $name"
  else
    gh label create "$name" --color "$color" --description "$desc" --force </dev/null >/dev/null
    echo "  ok label: $name"
  fi
done 3<<'EOF'
feat|0e8a16|Nuova funzionalità
fix|d73a4a|Correzione di bug
chore|c5def5|Configurazione e manutenzione
docs|0075ca|Documentazione
test|fbca04|Test
frontend|7057ff|Angular / interfaccia web
backend|b60205|Spring Boot / API
camera|5319e7|Fotocamera e campionamento
color-engine|1d76db|Motore colore e algoritmi
ui|f9d0c4|Interfaccia utente
security|e99695|Sicurezza e autenticazione
devops|bfd4f2|CI/CD, Docker, deploy
pwa|006b75|PWA e offline
a11y|bfdadc|Accessibilità
EOF
echo

# =============================================================================
# 2) MILESTONE        formato: titolo|descrizione
# =============================================================================
echo "== Milestone =="
EXISTING_MS=$(gh api "repos/$REPO/milestones?state=all&per_page=100" --jq '.[].title' 2>/dev/null || true)

while IFS='|' read -r -u 3 title desc; do
  [[ -z "$title" || "$title" == \#* ]] && continue
  if grep -Fxq -- "$title" <<<"$EXISTING_MS"; then
    echo "  skip milestone (esiste): $title"
  elif $DRY_RUN; then
    echo "  [dry-run] milestone: $title"
  else
    gh api "repos/$REPO/milestones" -f title="$title" -f description="$desc" -f state=open </dev/null >/dev/null
    echo "  ok milestone: $title"
  fi
done 3<<'EOF'
v0.1.0|Fondamenta: monorepo, scaffolding Angular e Spring Boot, tooling, CI
v0.2.0|Fotocamera e campionamento del colore
v0.3.0|Motore colore: conversioni, Delta E, catalogo locale, matching
v0.4.0|Interfaccia dei risultati, copia valori, cronologia locale
v0.5.0|Calibrazione con riferimento bianco/grigio
v0.6.0|Backend: API del catalogo colori e integrazione nel frontend
v0.7.0|Account e sicurezza: registrazione, login JWT, Spring Security
v0.8.0|Palette e sincronizzazione: k-means, API palette e cronologia
v0.9.0|PWA offline, accessibilità, prestazioni
v1.0.0|Rilascio: deploy, test su dispositivi, documentazione finale
EOF
echo

# =============================================================================
# 3) ISSUE            formato: milestone|label (separate da virgola)|titolo|descrizione
#    Evitare il carattere "|" dentro titolo e descrizione.
# =============================================================================
echo "== Issue =="
EXISTING_ISSUES=$(gh issue list --state all --limit 1000 --json title --jq '.[].title' 2>/dev/null || true)

CREATED=0
SKIPPED=0

while IFS='|' read -r -u 3 ms labels title body; do
  [[ -z "$ms" || "$ms" == \#* ]] && continue
  if grep -Fxq -- "$title" <<<"$EXISTING_ISSUES"; then
    echo "  skip issue (esiste): $title"
    SKIPPED=$((SKIPPED + 1))
  elif $DRY_RUN; then
    echo "  [dry-run] [$ms] $title"
    CREATED=$((CREATED + 1))
  else
    gh issue create --title "$title" --body "$body" --label "$labels" --milestone "$ms" </dev/null >/dev/null
    echo "  ok [$ms] $title"
    CREATED=$((CREATED + 1))
  fi
done 3<<'EOF'
# ---------------------------------- v0.1.0 -----------------------------------
v0.1.0|chore,devops|Creare la struttura del monorepo|Cartelle frontend e backend nella radice, con .gitignore e .editorconfig condivisi.
v0.1.0|chore,frontend|Creare il progetto Angular in frontend|Generato con Angular CLI: TypeScript strict, routing, componenti standalone, SCSS. Criterio: ng serve e ng build funzionano.
v0.1.0|chore,backend|Creare il progetto Spring Boot in backend|Generato con Spring Initializr (Maven, Java, Web, Validation, Actuator). Criterio: l'app parte e l'endpoint di health risponde.
v0.1.0|chore,frontend|Configurare ESLint con angular-eslint e Prettier|Lint e formattazione automatici per il frontend. Criterio: lint senza errori e format check verde.
v0.1.0|chore,backend|Configurare formattazione e analisi statica del backend|Spotless o Checkstyle integrati in Maven. Criterio: la build fallisce se il codice non rispetta le regole.
v0.1.0|chore,devops|Configurare Husky, lint-staged e commitlint|Hook Git nella radice: controlli sui file modificati e messaggi in formato Conventional Commits.
v0.1.0|chore,devops|Aggiungere Docker Compose con PostgreSQL|Database locale per lo sviluppo avviabile con un solo comando; credenziali in file .env non versionato.
v0.1.0|chore,devops|Configurare CI su GitHub Actions|Due job: frontend (lint, test, build) e backend (test, build). Criterio: CI verde su PR e su main.
v0.1.0|docs|Aggiungere README, CONTRIBUTING e CHANGELOG|Documenti base del repository, con link al Capitolato in docs.
v0.1.0|chore|Aggiungere template per issue e pull request|Template in .github con checklist (test, documentazione, issue collegata).
# ---------------------------------- v0.2.0 -----------------------------------
v0.2.0|feat,camera,frontend|CameraService con getUserMedia|Servizio Angular che mostra il flusso video (RF-01). Preferire la camera posteriore.
v0.2.0|feat,camera,frontend|Gestione permessi negati e fallback|Messaggio chiaro se il permesso è negato o la camera manca; fallback con caricamento immagine (RF-02).
v0.2.0|feat,camera,frontend|Selezione fotocamera anteriore e posteriore|Pulsante per cambiare camera quando ne sono disponibili più di una.
v0.2.0|feat,camera,ui|Componente mirino e area di campionamento|Overlay con mirino che indica l'area analizzata (RF-03).
v0.2.0|feat,camera,frontend|Campionamento della media su area NxN con canvas|SamplerService: disegna il fotogramma su canvas e calcola la media RGB dell'area; N configurabile (RF-04).
v0.2.0|feat,camera,frontend|Congelamento del fotogramma|Pulsante per bloccare il fotogramma e analizzarlo (RF-09).
# ---------------------------------- v0.3.0 -----------------------------------
v0.3.0|feat,color-engine|Conversione sRGB, XYZ e CIE Lab|Funzioni TypeScript pure in core/color, con linearizzazione sRGB e senza dipendenze da Angular (RF-05).
v0.3.0|feat,color-engine|Implementare CIEDE2000|Calcolo del Delta E con la formula CIEDE2000.
v0.3.0|feat,color-engine,frontend|Catalogo colori aperto in JSON e CatalogService locale|Dataset con licenza aperta, schema id/name/hex, fonte e licenza dichiarate nel README.
v0.3.0|feat,color-engine|Ricerca delle N corrispondenze migliori|Ordinare il catalogo per Delta E e restituire le prime N (RF-06).
v0.3.0|test,color-engine|Test unitari del motore colore|Verificare le funzioni con valori di riferimento noti. Obiettivo: copertura di almeno 80%.
# ---------------------------------- v0.4.0 -----------------------------------
v0.4.0|feat,frontend|Routing e struttura delle pagine|Pagine camera, risultati e cronologia con navigazione e lazy loading.
v0.4.0|feat,ui|Pagina risultati con candidati|Colore campionato e lista delle corrispondenze con nome, codice e campione (RF-07).
v0.4.0|feat,ui|Delta E e indicatore di affidabilità|Mostrare il Delta E e una scala qualitativa (ottima, buona, approssimativa).
v0.4.0|feat,ui|Copia valori HEX, RGB e Lab|Copia negli appunti con un tocco e feedback visivo (RF-08).
v0.4.0|feat,frontend|Cronologia locale delle rilevazioni|Salvataggio in localStorage con signals; modalità ospite (RF-12).
# ---------------------------------- v0.5.0 -----------------------------------
v0.5.0|feat,camera,ui|Modalità di calibrazione|Flusso guidato per inquadrare un riferimento bianco o grigio (RF-10).
v0.5.0|feat,color-engine|Correzione colore basata sul riferimento|Calcolare i fattori di correzione per canale e applicarli al campionamento.
v0.5.0|feat,ui|Suggerimenti su luce e riflessi|Messaggi contestuali, ad esempio se l'immagine è troppo scura o sovraesposta (RF-11).
# ---------------------------------- v0.6.0 -----------------------------------
v0.6.0|feat,backend|Entità Color con JPA e migrazioni Flyway|Modello dati del catalogo e prima migrazione dello schema su PostgreSQL.
v0.6.0|feat,backend|Seed del catalogo colori aperto|Caricare nel database i colori del dataset aperto tramite migrazione.
v0.6.0|feat,backend|API REST del catalogo con paginazione e ricerca|Endpoint pubblico di lettura dei colori con paginazione e ricerca per nome (RF-20).
v0.6.0|chore,backend|Documentazione API con OpenAPI e Swagger UI|Integrare springdoc-openapi (RF-26).
v0.6.0|chore,backend|Configurazione CORS e profili dev e prod|Profili Spring separati; CORS limitato all'origine del frontend.
v0.6.0|feat,backend|Gestione errori uniforme e validazione input|Gestione centralizzata con risposte di errore in formato coerente (RF-27).
v0.6.0|test,backend|Test dell'API del catalogo|Test unitari dei servizi e test di integrazione dei controller.
v0.6.0|feat,frontend|CatalogService con API e fallback al JSON locale|Il frontend usa l'API; se non è raggiungibile ricade sul catalogo incluso nell'app.
# ---------------------------------- v0.7.0 -----------------------------------
v0.7.0|feat,backend,security|Registrazione utente con password cifrata|Endpoint di registrazione con validazione e password salvata con BCrypt (RF-21).
v0.7.0|feat,backend,security|Login con token JWT|Endpoint di login che restituisce un JWT con scadenza breve (RF-22).
v0.7.0|feat,backend,security|Spring Security: protezione degli endpoint|Endpoint pubblici solo per catalogo, registrazione e login; tutto il resto richiede autenticazione (RF-25).
v0.7.0|feat,frontend,ui|Pagine di login e registrazione|Form con validazione e messaggi di errore chiari.
v0.7.0|feat,frontend,security|Interceptor HTTP e guard per le rotte protette|Aggiungere il token alle richieste e proteggere le pagine riservate; gestire la scadenza.
v0.7.0|test,backend,security|Test di sicurezza e autenticazione|Verificare accessi consentiti e negati, inclusa l'impossibilità di leggere i dati di altri utenti.
# ---------------------------------- v0.8.0 -----------------------------------
v0.8.0|feat,color-engine|Estrazione palette con k-means|Estrarre i colori dominanti da un'immagine; valutare l'esecuzione in un Web Worker (RF-13).
v0.8.0|feat,backend|API CRUD delle palette per utente|Creare, leggere, modificare ed eliminare le proprie palette (RF-23).
v0.8.0|feat,backend|API della cronologia delle rilevazioni|Salvare e recuperare la cronologia dell'utente autenticato (RF-24).
v0.8.0|feat,frontend,ui|Salvataggio e gestione delle palette|Salvare su account se autenticati, in locale se ospiti (RF-14).
v0.8.0|feat,frontend|Esportazione in CSS variables e JSON|Esportare la palette in formati riutilizzabili (RF-14).
v0.8.0|test,backend|Test delle API palette e cronologia|Test di integrazione, compresi i casi di accesso non autorizzato.
# ---------------------------------- v0.9.0 -----------------------------------
v0.9.0|feat,pwa|Manifest e service worker|App installabile con icone e manifest tramite il supporto PWA di Angular (RF-15).
v0.9.0|feat,pwa|Funzionamento offline|Caching degli asset e del catalogo; modalità ospite verificata in modalità aereo.
v0.9.0|a11y|Audit di accessibilità|Contrasto, navigazione da tastiera, etichette ARIA; conformità WCAG 2.1 AA.
v0.9.0|chore,frontend|Ottimizzazione delle prestazioni|Lighthouse almeno 90 in tutte le categorie.
# ---------------------------------- v1.0.0 -----------------------------------
v1.0.0|chore,devops|Deploy del backend con database|Pubblicazione in HTTPS con PostgreSQL gestito, variabili d'ambiente per i segreti.
v1.0.0|chore,devops|Deploy del frontend in HTTPS|Pubblicazione su GitHub Pages, Vercel o Netlify, collegata al backend di produzione.
v1.0.0|chore,test|Test su dispositivi reali iOS e Android|Verifica manuale con checklist e annotazione dei limiti noti.
v1.0.0|docs|README finale e documentazione API|GIF di utilizzo, istruzioni di avvio, fonti dati e licenze, disclaimer sulla precisione, link a Swagger UI.
v1.0.0|chore|Tag v1.0.0 e release notes|Aggiornare il CHANGELOG, creare il tag e la GitHub Release.
EOF

echo
echo "== Riepilogo =="
if $DRY_RUN; then
  echo "Dry-run completato: $CREATED issue verrebbero create, $SKIPPED già presenti."
else
  echo "Fatto: $CREATED issue create, $SKIPPED già presenti."
  echo "Controlla su: https://github.com/$REPO/milestones"
fi
