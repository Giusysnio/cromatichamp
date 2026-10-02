# Capitolato di progetto: Cromatichamp

| | |
|---|---|
| **Versione documento** | 2.0 |
| **Stato** | Bozza iniziale |
| **Tipo progetto** | Progetto di portfolio full-stack (open source) |
| **Architettura** | Single Page Application (Angular) + API REST (Spring Boot) |

---

## 1. Introduzione

**Cromatichamp** (da "cromatico" e "champ", cioè *campione*: il campione di colore) è una web app che usa la fotocamera di uno smartphone (o webcam) per rilevare il colore di un oggetto e restituire le **corrispondenze più vicine** in un catalogo di colori di riferimento, indicando per ciascuna quanto è affidabile il risultato.

Gli utenti possono usare l'app liberamente come ospiti oppure registrarsi per salvare palette e cronologia su un proprio account, sincronizzati tra dispositivi.

Il progetto nasce come **portfolio di uno sviluppatore junior**: l'obiettivo è dimostrare competenze full-stack (Angular, Spring Boot, database, sicurezza), elaborazione di immagini, qualità del software e buone pratiche di versionamento.

## 2. Obiettivi

### 2.1 Obiettivi principali
1. Acquisire il flusso video dalla fotocamera nel browser, senza installazione.
2. Campionare il colore in un'area inquadrata e convertirlo in uno spazio percettivo (CIE Lab).
3. Trovare e mostrare le N corrispondenze più vicine in un catalogo colori, con relativo Delta E.
4. Migliorare l'affidabilità tramite calibrazione con un riferimento bianco/grigio.
5. Offrire account utente, palette salvate e cronologia tramite un backend REST sicuro.
6. Offrire un'interfaccia curata, accessibile e utilizzabile con una mano.

### 2.2 Obiettivi di apprendimento (per il portfolio)
- **Frontend:** Angular, TypeScript, RxJS e signals, API del browser (`getUserMedia`, Canvas, Service Worker).
- **Backend:** Spring Boot, Spring Data JPA, Spring Security (JWT), migrazioni database, documentazione OpenAPI.
- **Trasversali:** colorimetria applicata (sRGB, XYZ, Lab, CIEDE2000), testing, CI/CD, Docker, versionamento semantico.

## 3. Ambito

### 3.1 Incluso
- Rilevazione del colore da fotocamera o da immagine caricata (elaborazione locale).
- Catalogo colori **aperto**, distribuito dal backend (vedi sezione 9).
- Calibrazione, palette, cronologia, esportazione.
- Registrazione, login e dati per utente (palette, cronologia).
- Funzionamento offline (PWA) con modalità ospite.

### 3.2 Escluso (non-obiettivi)
- Misure di precisione professionale (stampa, tessile): servirebbe uno spettrofotometro.
- Distribuzione su App Store / Play Store.
- Invio al server di immagini o fotogrammi: il server riceve solo valori di colore e palette.
- Login social (Google, Apple), pagamenti, pannello di amministrazione.
- Uso dei dati proprietari della libreria Pantone®.

## 4. Utenti target

| Utente | Esigenza |
|---|---|
| Designer / appassionato di grafica | Trovare rapidamente un colore e salvare le palette |
| Studente / curioso | Esplorare i colori intorno a sé |
| Recruiter / sviluppatore | Valutare qualità del codice e delle scelte tecniche |

## 5. Requisiti funzionali

### 5.1 Frontend (rilevazione colore)

| ID | Requisito | Priorità |
|---|---|---|
| RF-01 | L'app accede alla fotocamera (posteriore di default) previo consenso dell'utente | Alta |
| RF-02 | Se il permesso è negato o la camera non è disponibile, mostra un messaggio chiaro e permette di caricare un'immagine | Alta |
| RF-03 | Un mirino centrale indica l'area di campionamento | Alta |
| RF-04 | Il colore è la media di un'area NxN (configurabile), non di un singolo pixel | Alta |
| RF-05 | L'app converte il colore campionato in CIE Lab | Alta |
| RF-06 | L'app calcola il Delta E (CIEDE2000) rispetto ai colori del catalogo e mostra le prime N corrispondenze (default 5) | Alta |
| RF-07 | Per ogni corrispondenza sono mostrati nome, codice, campione di colore, Delta E e indicatore di affidabilità | Alta |
| RF-08 | L'utente può copiare HEX, RGB e Lab con un tocco | Media |
| RF-09 | L'utente può congelare il fotogramma per analizzarlo con calma | Media |
| RF-10 | Modalità di calibrazione con riferimento bianco o grigio inquadrato | Media |
| RF-11 | Suggerimenti contestuali su illuminazione e riflessi | Media |
| RF-12 | Cronologia delle ultime rilevazioni (locale per gli ospiti, sul server per gli utenti registrati) | Media |
| RF-13 | Estrazione di una palette dominante da un'immagine (k-means) | Media |
| RF-14 | Salvataggio delle palette ed esportazione in CSS variables e JSON | Media |
| RF-15 | L'app è installabile e funziona offline dopo il primo caricamento | Media |

### 5.2 Backend (API e account)

| ID | Requisito | Priorità |
|---|---|---|
| RF-20 | L'API espone il catalogo colori con paginazione e ricerca per nome | Alta |
| RF-21 | Un utente può registrarsi con email e password (password salvata cifrata) | Alta |
| RF-22 | Un utente può autenticarsi e ricevere un token JWT | Alta |
| RF-23 | Un utente autenticato può creare, leggere, modificare ed eliminare le **proprie** palette | Alta |
| RF-24 | Un utente autenticato può salvare e recuperare la propria cronologia di rilevazioni | Media |
| RF-25 | Gli endpoint dei dati utente rifiutano le richieste non autenticate e l'accesso ai dati di altri utenti | Alta |
| RF-26 | L'API è documentata con OpenAPI/Swagger UI | Media |
| RF-27 | Le risposte di errore hanno un formato uniforme e le richieste sono validate | Media |

## 6. Requisiti non funzionali

| ID | Requisito |
|---|---|
| RNF-01 | **Privacy:** nessuna immagine lascia il dispositivo; il server riceve solo valori di colore e palette |
| RNF-02 | **Prestazioni:** aggiornamento del risultato in tempo reale (≥ 10 fps percepiti); Lighthouse ≥ 90 |
| RNF-03 | **Compatibilità:** ultime 2 versioni di Safari iOS e Chrome Android; Chrome/Firefox/Edge desktop |
| RNF-04 | **Accessibilità:** conformità WCAG 2.1 AA (contrasto, tastiera, etichette per screen reader) |
| RNF-05 | **Qualità:** copertura test ≥ 80% sul motore colore e sui servizi backend; lint e test obbligatori in CI |
| RNF-06 | **Manutenibilità:** TypeScript strict; motore colore separato da Angular; backend a livelli (controller, service, repository) |
| RNF-07 | **Sicurezza:** HTTPS ovunque, password con BCrypt, validazione degli input, CORS limitato al frontend, nessun segreto nel repository |
| RNF-08 | **Portabilità:** ambiente di sviluppo avviabile con pochi comandi (Docker Compose per il database) |

## 7. Stack tecnologico

| Ambito | Scelta | Note |
|---|---|---|
| Frontend | Angular (ultima versione stabile), TypeScript strict, componenti standalone | Stile con SCSS |
| Test frontend | Test runner predefinito della CLI Angular | |
| Qualità frontend | `angular-eslint`, Prettier | |
| Backend | Java (JDK 21 o superiore), Spring Boot, Maven | |
| Moduli Spring | Web, Validation, Data JPA, Security, Actuator | |
| Database | PostgreSQL (sviluppo con Docker Compose) | Migrazioni con Flyway |
| Documentazione API | springdoc-openapi (Swagger UI) | |
| Test backend | JUnit 5, Mockito, Spring Boot Test | Testcontainers opzionale |
| Qualità backend | Spotless o Checkstyle | |
| Hook Git | Husky, lint-staged, commitlint (nella radice) | |
| CI/CD | GitHub Actions | |
| Hosting | Frontend: GitHub Pages, Vercel o Netlify. Backend + database: servizio gratuito/economico da verificare al momento del rilascio | |

## 8. Architettura

```
┌────────────────────────┐      HTTPS / JSON       ┌────────────────────────┐
│  Frontend (Angular)    │ ──────────────────────► │  Backend (Spring Boot) │
│  fotocamera, calcolo   │ ◄────────────────────── │  REST API, JWT         │
│  colore, UI, PWA       │                         │                        │
└────────────────────────┘                         └───────────┬────────────┘
                                                               │ JPA
                                                    ┌──────────▼───────────┐
                                                    │  PostgreSQL          │
                                                    └──────────────────────┘
```

**Flusso di rilevazione (tutto nel browser):** video → fotogramma su canvas → media area NxN (sRGB) → eventuale correzione da calibrazione → XYZ → Lab → CIEDE2000 contro il catalogo → ordinamento → top-N.

**Cosa passa dal server:** il catalogo colori (in lettura), la registrazione/login, le palette e la cronologia dell'utente. Il calcolo del colore resta **sul client**, per privacy e prestazioni.

**Modalità ospite:** senza account, l'app funziona con catalogo incluso nell'app e dati salvati in locale. Il backend è un potenziamento, non un requisito per usarla.

### Frontend
- `core/color/`: funzioni TypeScript pure (conversioni, Delta E, k-means), senza dipendenze da Angular, testabili in isolamento.
- Servizi Angular: `CameraService`, `SamplerService`, `CatalogService`, `AuthService`, `PaletteService`.
- Componenti per pagina: camera, risultati, cronologia, palette, login.
- Stato con signals; chiamate HTTP con `HttpClient` e interceptor per il token.

### Backend
- Pacchetti per funzionalità: `catalog`, `auth`, `palette`, `history`.
- Livelli: `controller` → `service` → `repository`, con DTO separati dalle entità JPA.
- Spring Security con filtro JWT, endpoint pubblici solo per catalogo, registrazione e login.
- Gestione errori centralizzata (`@RestControllerAdvice`).

### Struttura repository

```
cromatichamp/
├── .github/            # workflow CI e template PR
├── backend/            # Spring Boot (Maven)
│   └── src/main/java/...
├── frontend/           # Angular
│   └── src/app/
│       ├── core/       # algoritmi colore (puri)
│       ├── services/
│       ├── components/
│       └── pages/
├── docs/               # capitolato, decisioni di progetto
├── scripts/            # script di supporto (tabella di roadmap)
├── docker-compose.yml  # PostgreSQL per lo sviluppo
├── CHANGELOG.md
├── CONTRIBUTING.md
└── README.md
```

## 9. Dati colore e aspetti legali

- I nomi, i codici e i valori della libreria **Pantone®** sono proprietari: **non verranno inclusi** nel repository né nel database.
- Il catalogo iniziale usa dati con licenza aperta (ad esempio colori CSS/X11 o un dataset di colori nominati con licenza compatibile), con fonte e licenza dichiarate nel README.
- Schema del catalogo: `id`, `name`, `hex`. Può essere sostituito o esteso in futuro con dati licenziati.
- L'interfaccia parla di "corrispondenza approssimativa" e mostra sempre un disclaimer sui limiti della misura da fotocamera.
- Dati personali: si raccolgono solo email e password cifrata; nel README va indicato come cancellare l'account.

## 10. Aspetti tecnici critici

| Problema | Impatto | Mitigazione |
|---|---|---|
| Illuminazione variabile | Colore misurato non fedele | Calibrazione con riferimento; suggerimenti all'utente |
| Auto white balance e HDR del telefono | Deriva dei colori tra dispositivi | Documentare il limite; congelamento del fotogramma |
| Superfici lucide o testurizzate | Campionamento rumoroso | Media su area; area più ampia |
| Permessi camera su iOS Safari | Funzionalità inutilizzabile | Fallback con caricamento immagine; test su dispositivi reali |
| Furto o abuso di token JWT | Accesso ai dati altrui | Scadenza breve, HTTPS, controllo del proprietario su ogni risorsa |
| CORS tra frontend e backend | Richieste bloccate dal browser | Configurazione per profilo (dev/prod) |
| Avvio lento dei servizi gratuiti di hosting | Prima risposta lenta | Documentarlo; la modalità ospite non dipende dal server |

## 11. Versionamento e flusso di lavoro

### 11.1 Versionamento semantico (SemVer)
Formato `MAJOR.MINOR.PATCH`:
- **MAJOR**: cambiamenti incompatibili.
- **MINOR**: nuove funzionalità retrocompatibili.
- **PATCH**: correzioni di bug.

Fino alla `1.0.0` il progetto è in sviluppo iniziale (`0.x.y`): ogni milestone corrisponde a una versione MINOR. Frontend e backend condividono la stessa versione del progetto.

### 11.2 Conventional Commits
Formato: `tipo(ambito): descrizione`, con ambiti consigliati `frontend`, `backend`, `docs`, `ci`.

| Tipo | Uso |
|---|---|
| `feat` | nuova funzionalità |
| `fix` | correzione di bug |
| `docs` | documentazione |
| `test` | test |
| `refactor` | modifica senza cambio di comportamento |
| `chore` | configurazione, dipendenze, tooling |
| `ci` | pipeline |

Esempio: `feat(backend): aggiunge endpoint di login con JWT`

### 11.3 Branching (GitHub Flow)
- `main`: sempre stabile e rilasciabile, protetto.
- `feat/<nome>`, `fix/<nome>`, `docs/<nome>`, `chore/<nome>`: un branch per attività della roadmap.
- Ogni modifica entra in `main` tramite **Pull Request** con CI verde (squash merge).

### 11.4 Rilascio
1. Tutte le attività della versione sono nello stato **Done** nella tabella di roadmap.
2. Si aggiorna `CHANGELOG.md`.
3. Si crea il tag `vX.Y.Z` e la GitHub Release con le note.

## 12. Roadmap

| Versione | Titolo | Contenuto |
|---|---|---|
| **v0.1.0** | Fondamenta | Monorepo, scaffolding Angular e Spring Boot, lint, hook Git, Docker Compose, CI, template |
| **v0.2.0** | Fotocamera e campionamento | `getUserMedia`, permessi, mirino, media area, fotogramma congelato |
| **v0.3.0** | Motore colore | sRGB → Lab, CIEDE2000, catalogo locale, top-N, test unitari |
| **v0.4.0** | Interfaccia risultati | Routing, candidati, Delta E, copia valori, cronologia locale |
| **v0.5.0** | Calibrazione | Riferimento bianco/grigio, correzione, suggerimenti |
| **v0.6.0** | Backend: catalogo | Entità JPA, Flyway, API catalogo, OpenAPI, test, integrazione nel frontend |
| **v0.7.0** | Account e sicurezza | Registrazione, login JWT, Spring Security, pagine di login, interceptor e guard |
| **v0.8.0** | Palette e sincronizzazione | k-means, API palette e cronologia, salvataggio, export |
| **v0.9.0** | PWA e qualità | Offline, installabile, accessibilità, prestazioni |
| **v1.0.0** | Rilascio | Deploy di frontend e backend, test su dispositivi, documentazione finale |

Il dettaglio delle attività è mantenuto in una **tabella di roadmap su GitHub Projects** (colonne: attività, versione, area, stato), creata dallo script `scripts/setup-roadmap-table.sh`.

## 13. Criteri di accettazione della v1.0.0

- [ ] Tutti i requisiti di priorità Alta e Media sono implementati.
- [ ] La CI è verde (lint, test, build di frontend e backend) su `main`.
- [ ] Copertura test ≥ 80% su motore colore e servizi backend.
- [ ] Lighthouse ≥ 90 in Performance, Accessibilità, Best Practices, PWA.
- [ ] Un utente non può leggere né modificare i dati di un altro utente (verificato da test automatici).
- [ ] Provata su almeno un dispositivo iOS e uno Android reali.
- [ ] Demo pubblica online in HTTPS, con documentazione API raggiungibile.
- [ ] README con screenshot/GIF, istruzioni di avvio, fonti dati, limiti noti.

## 14. Rischi

| Rischio | Probabilità | Impatto | Piano |
|---|---|---|---|
| Risultati poco fedeli su alcuni telefoni | Alta | Medio | Calibrazione, disclaimer, trasparenza nel README |
| Licenza del catalogo non chiara | Media | Alto | Usare solo dataset con licenza esplicita |
| Scope creep (due applicazioni da mantenere) | Alta | Medio | Rispettare la roadmap; idee nuove nel backlog post-1.0 |
| Poco tempo disponibile | Media | Medio | Milestone piccole, ognuna con valore autonomo; il frontend è utilizzabile già dalla v0.5.0 |
| Costi o limiti dell'hosting del backend | Media | Basso | Modalità ospite indipendente dal server |

## 15. Glossario

- **sRGB**: spazio colore standard per schermi e fotocamere.
- **CIE Lab**: spazio colore pensato per riflettere la percezione umana.
- **Delta E (CIEDE2000)**: misura della differenza percepita tra due colori; sotto ~2 è difficilmente distinguibile a occhio.
- **PWA**: web app installabile, anche offline.
- **JWT**: token firmato usato per autenticare le richieste all'API.
- **JPA / Flyway**: mappatura oggetti-database e gestione versionata dello schema.
- **SemVer**: schema di numerazione delle versioni.
- **k-means**: algoritmo di clustering usato per estrarre i colori dominanti.
