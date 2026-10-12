# Spese fisse e programmate

Accesso dalla scheda Spese fisse nella Home oppure da Movimenti → Programmate. La barra inferiore resta invariata; il pulsante centrale + nella scheda Programmate apre una nuova spesa fissa.

## Percorso utente

1. Crea una spesa o parti dagli esempi Abbonamento, Bolletta, Affitto.
2. Indica nome, importo, frequenza e prossima scadenza. Conto e categoria sono precompilati e modificabili.
3. Per importi variabili abilita il relativo interruttore: l’importo iniziale è una stima.
4. Segna la scadenza come pagata e conferma importo effettivo, conto e data. Il movimento viene creato soltanto dopo questa conferma.
5. Consulta lo storico o gestisci pausa, riattivazione e termine dal menu della spesa. Puoi saltare una scadenza senza registrare movimenti e annullare subito il salto.

I riepiloghi mensili distinguono importi ancora previsti e pagamenti confermati riferiti alle scadenze del mese. Le scadenze precedenti ancora aperte sono mostrate separatamente nella lista, con stato In ritardo rispetto alla data odierna. Il grafico e i saldi finanziari esistenti cambiano soltanto quando viene registrato un pagamento.

## Regole

Frequenze mensili, bimestrali, trimestrali e annuali. La ricorrenza conserva il giorno originale: 31 gennaio → 28/29 febbraio → 31 marzo. Il pagamento anticipato o tardivo non sposta la frequenza. L’importo effettivo di una bolletta non sostituisce automaticamente la stima delle scadenze successive.

La conferma blocca richieste simultanee per la stessa spesa. Una seconda conferma della stessa scadenza non registra un altro movimento. Se il salvataggio fallisce, scadenza e storico restano invariati. La funzionalità è abilitata soltanto con MOCK_API in APP_ENV=local, dove il trasporto è interno e sincrono: per un servizio reale serve una API con idempotenza e riconciliazione dei timeout.

## Stato dell’integrazione

Prototipo locale integrato con il repository finanziario già presente. Scadenze e storico si azzerano alla fine della sessione e al riavvio, come i mock dell’app. Nessun dato personale o abbonamento reale viene inserito automaticamente. Le spese nelle anteprime sono fixture del test di rendering.

Non sono implementati salvataggio su backend, notifiche o addebiti automatici. La modalità reale mostra uno stato di indisponibilità e non usa un archivio locale nascosto.

## Verifiche

Test del percorso mobile creazione → pagamento variabile → movimento → storico; layout 320 px con testo al 180%; calcolo scadenze e anni bisestili; pagamenti concorrenti e replay; errore di salvataggio; pausa, salto e annullamento; conservazione dello storico; isolamento tra sessioni. Anteprime reali Flutter: docs/previews/scheduled-expenses.png, scheduled-editor.png, home-scheduled.png.
