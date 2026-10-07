# Cromatichamp

> Inquadra un colore, trova il campione più vicino.

**Cromatichamp** (da *cromatico* e *champ*, "campione") è una web app che usa la fotocamera dello smartphone per rilevare il colore di un oggetto e mostrare le **corrispondenze più vicine** in un catalogo di colori aperto, indicando quanto è affidabile ciascun risultato (Delta E, CIEDE2000).

> **Stato:** in sviluppo iniziale (`0.x`). Vedi la [roadmap](docs/CAPITOLATO.md#12-roadmap).

![Screenshot o GIF dell'app: da aggiungere](docs/screenshot-placeholder.png)

## Funzionalità previste

- Rilevazione del colore da fotocamera o da immagine caricata (tutto nel browser)
- Conversione in CIE Lab e ricerca delle N corrispondenze con Delta E
- Calibrazione con riferimento bianco o grigio
- Palette dominanti (k-means), salvataggio ed esportazione in CSS/JSON
- Account opzionale con palette e cronologia sincronizzate
- PWA installabile e funzionante offline in modalità ospite

## Privacy

Nessuna immagine lascia il dispositivo: il server riceve solo valori di colore e palette. Dati personali raccolti: solo email e password cifrata (BCrypt). L'account può essere cancellato con `DELETE /me`.

## Limiti noti

- Misura **approssimativa**: dipende da luce, bilanciamento del bianco e sensore del telefono. Non sostituisce uno spettrofotometro.
- I nomi e i codici **Pantone®** sono proprietari e **non sono inclusi**: l'app usa un catalogo con licenza aperta.
- Il token di accesso è salvato in `localStorage` (miglioramento futuro: cookie `HttpOnly`).

## Stack

| Ambito | Tecnologie |
|---|---|
| Frontend | Angular, TypeScript strict, signals, RxJS, CSS puro |
| Backend | Java 21+, Spring Boot, Spring Security (JWT), Spring Data JPA |
| Database | PostgreSQL, Flyway |
| Qualità | ESLint, Prettier, JUnit 5, Mockito, Husky, commitlint |
| CI/CD | GitHub Actions |

## Avvio in locale

> Le istruzioni complete arriveranno con la v0.1.0.

Requisiti: Git, Node.js LTS, JDK 21+, Maven, Docker.

```bash
git clone https://github.com/<tuo-utente>/cromatichamp.git
cd cromatichamp
docker compose up -d   # PostgreSQL
```

## Dati colore e licenze

Il catalogo usa dati con licenza aperta. **Fonte e licenza: da dichiarare qui** quando sarà scelto il dataset (v0.3.0).

## Struttura del repository

```
cromatichamp/
├── .github/       # CI e template PR
├── backend/       # Spring Boot (Maven)
├── frontend/      # Angular
├── docs/          # capitolato e decisioni
├── scripts/       # script di supporto
└── CHANGELOG.md
```

## Documentazione

- [Capitolato di progetto](docs/CAPITOLATO.md)
- [Come contribuire](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

## Licenza

Da scegliere (consigliata: MIT). Aggiungere il file `LICENSE` prima della v1.0.0.
