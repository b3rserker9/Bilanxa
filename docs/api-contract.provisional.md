# Contratto sintetico delle chiamate mock

**Questo file NON è il contratto Spring Boot.** Non è stato fornito `docs/api-contract.md` del backend. I campi seguenti sono usati soltanto da MockBackendAdapter e MockFinanceApiContract, su richiesta dell’utente di simulare le chiamate. Prima di attivare il backend confrontare endpoint, enum, nullabilità, paginazione, valuta e campi di richiesta/risposta con il contratto effettivo. Implementare FinanceApiContract secondo il documento reale e aggiornare i test. Non riusare il parser mock per Spring Boot.

Gli endpoint sono quelli richiesti. Importi JSON: stringhe decimali EUR a due cifre, mai numeri JSON. Date: `yyyy-MM-dd`, senza conversione UTC. Identificativi: stringhe opache. Importi transazione positivi; il verso è `income` o `expense`.

## GET /api/v1/me

```json
{"id":"user-id","email":"mario@example.com","name":"Mario"}
```

## GET /api/v1/accounts

Array semplice, senza envelope o paginazione nella proposta:

```json
[{"id":"account-id","name":"Conto personale","type":"bank","balance":"2480.00"}]
```

Tipi proposti: `bank`, `cash`, `savings`.

## POST /api/v1/accounts

```json
{"name":"Conto personale","type":"bank","initialBalance":"0.00"}
```

Il client considera riuscita una risposta 2xx, senza utilizzare un corpo di risposta.

## GET /api/v1/categories

```json
[{"id":"category-id","name":"Spesa","type":"expense"}]
```

## GET /api/v1/transactions

```json
[{"id":"transaction-id","accountId":"account-id","categoryId":"category-id","type":"expense","amount":"42.80","description":"Spesa al supermercato","date":"2026-10-10"}]
```

Il repository conserva l’ordine ricevuto. In produzione ordinamento e paginazione dovranno essere definiti dal backend.

## POST /api/v1/transactions

```json
{"accountId":"account-id","categoryId":"category-id","type":"expense","amount":"42.80","description":"Spesa al supermercato","date":"2026-10-10"}
```

Risposta 2xx senza corpo richiesto. Non si ritenta automaticamente un POST: non c’è un contratto di idempotenza. Dopo un timeout verificare l’elenco prima di ripetere il salvataggio.

## GET /api/v1/dashboard

```json
{"totalBalance":"3680.00","monthlyIncome":"2100.00","monthlyExpense":"620.00","remaining":"1480.00","recentTransactions":[]}
```

Tutti gli aggregati arrivano dal backend. Il frontend non calcola la disponibilità residua o il saldo. Nel mock gli aggregati si aggiornano dai dati di prova con BigInt quando aggiungi conti o movimenti. Non sono regole di business reali. Una nuova sessione ripristina i dati di prova.

## Sicurezza ed errori

Il client reale aggiunge `Authorization: Bearer <Firebase ID Token>` letto dal Firebase SDK prima di ogni richiesta. Nessun JWT applicativo né token salvato dal codice Dart. Il backend deve verificare token, autorizzazione e proprietà dei dati con Firebase Admin.

Errori mappati: 401 sessione, 403 accesso, 400/409/422 validazione, 5xx servizio, timeout/connessione rete. JSON incompatibile produce uno stato di errore, senza fallback ai mock. I dettagli del corpo errore non vengono mostrati o registrati.

