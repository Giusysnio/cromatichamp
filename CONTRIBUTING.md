# Contribuire a Cromatichamp

Grazie per l'interesse! Il progetto segue il [Capitolato](docs/CAPITOLATO.md): leggilo prima di proporre modifiche.

## Flusso di lavoro (GitHub Flow)

1. Scegli un'attività dalla tabella di roadmap (una alla volta).
2. Crea un branch da `main`: `feat/<nome>`, `fix/<nome>`, `docs/<nome>` o `chore/<nome>`.
3. Lavora a piccoli commit.
4. Apri una Pull Request verso `main` e compila la checklist del template.
5. Con la CI verde, la PR viene unita con **squash merge**.

## Conventional Commits

Formato: `tipo(ambito): descrizione` (in italiano, al presente, in minuscolo).

| Tipo | Uso |
|---|---|
| `feat` | nuova funzionalità |
| `fix` | correzione di bug |
| `docs` | documentazione |
| `test` | test |
| `refactor` | modifica senza cambio di comportamento |
| `chore` | configurazione, dipendenze, tooling |
| `ci` | pipeline |

Ambiti consigliati: `frontend`, `backend`, `docs`, `ci`.
Esempi: `feat(frontend): aggiunge il mirino di campionamento`, `fix(backend): corregge la paginazione del catalogo`.

## Versionamento

SemVer `MAJOR.MINOR.PATCH`. Fino alla `1.0.0` ogni milestone è una versione MINOR (`0.x.0`). Dettagli nel Capitolato, sezione 11.

## Regole di qualità

- TypeScript `strict`, nessun `any` non giustificato.
- Il motore colore (`core/color/`) non dipende da Angular ed è coperto da test.
- Backend a livelli: controller → service → repository, con DTO separati dalle entità.
- Nessun segreto nel repository: usa file `.env` non versionati.
- Niente dati Pantone®: solo dataset con licenza aperta.
