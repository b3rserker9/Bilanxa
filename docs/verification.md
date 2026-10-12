# Verifica del 12 ottobre 2026

Ambiente: Windows, Flutter stable 3.47.7, Dart 3.13.5, Android SDK installato.

| Controllo | Risultato |
|---|---|
| flutter pub get | Completato; dipendenze e lockfile aggiornati |
| flutter gen-l10n | Completato; italiano e inglese |
| dart format lib test tools | 43 file; nessuna modifica residua |
| flutter analyze | No issues found |
| flutter test --concurrency=1 --dart-define-from-file=config/local.json | 20 test passati |
| Test preview login, Home chiara/scura | Passato; immagini generate dai widget con i repository HTTP mock reali |
| flutter build apk --debug --dart-define-from-file=config/local.json | Completato sul codice finale |
| Installazione/esecuzione fisica Android | Non eseguita in questa verifica |
| Build iOS | Non eseguita: richiede macOS e Xcode |
| Firebase reale / Spring Boot reale | Non verificati: configurazione Firebase e contratto backend non forniti |
| AAB release / pubblicazione store | Non eseguiti: identità definitive, configurazioni e firma richieste |

APK locale: build/app/outputs/flutter-apk/app-debug.apk. Contiene la modalità di prova esplicitamente abilitata da config/local.json. Non è una build destinata agli store.

I test verificano validazione login, autenticazione e routing, importi esatti, parsing DTO mock, header Bearer, errori HTTP/rete, dashboard (loading, dati, vuoto, errore, retry), layout da 320 px con text scale 1.8, creazione movimento tramite form e HTTP, creazione conto e isolamento delle sessioni. Le chiamate simulate attraversano Dio e HttpFinanceRepository. Il contratto mock non dimostra compatibilità con un backend non fornito.

Gli stati di configurazione mancante non mostrano saldi inventati. La modalità mock è limitata ad APP_ENV=local e segnala sempre che i dati e le operazioni sono simulati. I dati vengono ripristinati al logout o al riavvio.

Gradle mostra avvisi relativi al plugin Kotlin usato dalle dipendenze Firebase e alle API native Java. Con le versioni bloccate nel lockfile la build debug è riuscita; verificare la compatibilità quando si aggiorneranno Flutter/Gradle/plugin.

## Anteprime

I PNG in previews/ sono dati di prova, generati con gli stessi adapter mock della configurazione locale. Login e Home chiara/scura sono stati controllati visivamente.

```powershell
flutter test tools/preview_test.dart --dart-define-from-file=config/local.json --dart-define=FLUTTER_SDK=C:/percorso/flutter
```

Lo strumento carica i font dello SDK per evitare il font Ahem dei widget test. Non modifica i font distribuiti con la app.
