# Interfaccia da Google Stitch

Riferimento: Bilanqo Fintech App UI/UX, progetto 4807265959871042460, recuperato il 12 ottobre 2026.

Schermate adattate in Flutter: onboarding a tre passi, accesso/registrazione, Home Dashboard e Movimenti. I riferimenti HTML e le immagini sono conservati in tools/stitch-reference.

Lo stile condiviso usa Inter e Plus Jakarta Sans (font inclusi localmente con licenze OFL), fondo menta #E7FFF5, verde #176B52, scheda saldo con gradiente, superfici bianche arrotondate e navigazione sospesa con azione centrale. Gli importi nell’interfaccia hanno il simbolo euro davanti; il modello monetario conserva i calcoli esatti in centesimi.

L’onboarding si apre dal collegamento “Scopri Bilanqo” nella schermata di accesso. Ricerca, filtri per tipo/conto/mese e dettaglio movimento operano sui dati del repository. Il grafico settimanale e le categorie sono calcolati dai movimenti disponibili; nessun importo o andamento del mockup Stitch è copiato nei dati dell’app.

Google/Apple Sign-In, Face ID, scanner scontrini e divisione delle spese non sono implementati dal backend attuale. Il pulsante Dividi porta alla schermata Gruppi esistente. Le dichiarazioni PSD2/GDPR e di crittografia del mockup non sono state aggiunte come promesse del prodotto. Gruppi e budget conservano lo stato “Funzionalità in arrivo”.

Anteprime reali generate dai widget Flutter in docs/previews: login.png, onboarding.png, home-light.png, home-dark.png, transactions.png.

Verifiche: analisi statica senza problemi; suite di test con configurazione locale passata (22 test), comprendente ricerca, filtri, cambio mese, dettaglio movimento, onboarding, login/logout e layout stretto con testo ingrandito. APK debug compilato con config/local.json.

## Palette esatta (aggiornamento)

Tema chiaro importato dai namedColors di Google Stitch: primary #00513C, primary-container #176B52, surface/background #E7FFF5, surface-container-lowest #FFFFFF, secondary-container #BDEDDC, on-surface #0B1F19, on-surface-variant #3F4944, inverse-surface #20342E, error #BA1A1A. Gradiente saldo copiato dallo schermo Home: #103F34 → #135342 → #176B52. Il tema iniziale è chiaro come il progetto Stitch; resta possibile selezionare scuro o sistema dal profilo.
