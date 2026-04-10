# Istruzioni Copilot per 4-ristoranti

Queste regole valgono per tutto il repository.

## Documentazione Apple
- Quando serve verificare API, framework o best practice Apple, consulta la documentazione ufficiale su developer.apple.com.
- Dai priorita alle fonti ufficiali Apple rispetto a fonti terze.
- Riporta sempre i punti rilevanti in modo sintetico e applicato al codice del progetto.

## Debug Build
- Se l'utente chiede debug, analisi errori di compilazione, o verifica stato build, esegui lo script:
  - `./detect_build_errors.sh` (default Release)
  - `./detect_build_errors.sh Debug` (se richiesto o utile)
- Usa il report generato in `build/logs/` per individuare le cause principali.
- Nella risposta, includi:
  - esito build (success/fail)
  - primi errori rilevanti
  - percorso del report usato

## Sicurezza operativa
- Non cancellare artefatti o file utente senza richiesta esplicita.
- Non eseguire comandi distruttivi su git senza conferma esplicita.
