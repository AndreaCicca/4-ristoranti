# 4 Ristoranti - Dashboard di Visualizzazione

Una dashboard web interattiva per visualizzare e analizzare i dati del programma televisivo "4 Ristoranti".

## 📋 Descrizione

Questo progetto fornisce un'interfaccia web intuitiva per esplorare i dati relativi alle puntate di "4 Ristoranti". Gli utenti possono visualizzare, filtrare e analizzare le informazioni relative a tutte le stagioni del programma attraverso una tabella interattiva e grafici dettagliati.


## Provenienza dei Dati

I dati provengono dalla pagina wikipedia del programma. Sono stati raccolti e organizzati in un file JSON per facilitarne l'utilizzo e la visualizzazione.

## ✨ Funzionalità

### Visualizzazione Dati
- Tabella interattiva con tutti i dati delle puntate
- Filtro rapido per stagione
- Barra di ricerca per ricerche veloci
- Filtri avanzati per:
  - Anno
  - Location
  - Categoria Speciale
  - Vincitore
  - Titolare
  - Periodo di messa in onda

### Analisi Grafica
- Visualizzazione della distribuzione geografica delle location
- Evoluzione temporale delle location nel corso delle stagioni
- Grafico delle location più visitate

## 🛠️ Tecnologie Utilizzate

- Bootstrap 5.3.3
- ECharts per la visualizzazione dei grafici

## 🚀 Come Iniziare

1. Clona il repository:
```bash
git clone https://github.com/AndreaCicca/4-ristoranti
```
2. Usa docker
```bash
docker-compose up -d --build
```
3 Apri il browser e vai all'indirizzo `http://localhost:7778`

## 💡 Note

- Il progetto utilizza dati in formato JSON per la massima compatibilità e facilità di aggiornamento
- L'interfaccia è completamente responsive e ottimizzata per dispositivi mobili
- Tutti i componenti sono stati progettati seguendo le best practice di accessibilità web

## 📄 Licenza

MIT License