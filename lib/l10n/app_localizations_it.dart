// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get transactions => 'Movimenti';

  @override
  String get groups => 'Gruppi';

  @override
  String get budgets => 'Budget';

  @override
  String get profile => 'Profilo';

  @override
  String get accounts => 'Conti';

  @override
  String get login => 'Accedi';

  @override
  String get register => 'Crea un account';

  @override
  String get reset => 'Recupera password';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get invalidEmail => 'Inserisci un’email valida';

  @override
  String get invalidPassword => 'Inserisci la password';

  @override
  String get weakPassword => 'Usa almeno 8 caratteri';

  @override
  String get welcome => 'Le tue finanze, più semplici.';

  @override
  String get intro =>
      'Un posto per capire le tue spese e fare spazio ai tuoi progetti.';

  @override
  String get firebaseSetup =>
      'Il servizio di accesso non è ancora disponibile.';

  @override
  String get resetSent =>
      'Se l’indirizzo è registrato, riceverai le istruzioni per recuperare la password.';

  @override
  String get networkError =>
      'Non riusciamo a connetterci. Controlla la connessione e riprova.';

  @override
  String get unauthorized =>
      'La sessione non è valida. Esci e accedi di nuovo.';

  @override
  String get genericError =>
      'Non è stato possibile completare l’operazione. Riprova.';

  @override
  String get authError =>
      'Accesso non riuscito. Verifica i dati o riprova più tardi.';

  @override
  String get contractError =>
      'I dati ricevuti non sono compatibili con questa versione dell’app.';

  @override
  String get configurationError =>
      'Il servizio non è ancora disponibile. Riprova più tardi.';

  @override
  String get validationError => 'Controlla i dati inseriti e riprova.';

  @override
  String get forbidden => 'Non hai accesso a questi dati.';

  @override
  String get retry => 'Riprova';

  @override
  String get empty => 'Ancora nessun elemento';

  @override
  String get emptyMovements => 'Aggiungi il tuo primo movimento per iniziare.';

  @override
  String get emptyAccounts =>
      'Crea un conto per iniziare a registrare le tue spese.';

  @override
  String get balance => 'Saldo totale';

  @override
  String get income => 'Le tue entrate';

  @override
  String get expense => 'Le tue spese';

  @override
  String get remaining => 'Quanto ti rimane questo mese?';

  @override
  String get recent => 'Ultimi movimenti';

  @override
  String get addMovement => 'Aggiungi un movimento';

  @override
  String get addExpense => 'Aggiungi una spesa';

  @override
  String get newAccount => 'Crea un conto';

  @override
  String get name => 'Nome';

  @override
  String get accountType => 'Tipo di conto';

  @override
  String get bank => 'Conto bancario';

  @override
  String get cash => 'Contanti';

  @override
  String get savings => 'Risparmi';

  @override
  String get initialBalance => 'Saldo iniziale';

  @override
  String get amount => 'Importo';

  @override
  String get invalidAmount =>
      'Inserisci un importo valido, con massimo 2 decimali';

  @override
  String get positiveAmount => 'L’importo deve essere maggiore di zero';

  @override
  String get required => 'Questo campo è obbligatorio';

  @override
  String get save => 'Salva';

  @override
  String get description => 'Descrizione';

  @override
  String get date => 'Data';

  @override
  String get account => 'Conto';

  @override
  String get category => 'Categoria';

  @override
  String get type => 'Tipo';

  @override
  String get newMovement => 'Nuovo movimento';

  @override
  String get comingSoon => 'Funzionalità in arrivo';

  @override
  String get groupsText =>
      'Dividi con gli amici. Presto potrai gestire spese condivise e rimborsi in un solo posto.';

  @override
  String get budgetsText =>
      'Dai spazio ai tuoi obiettivi. Presto potrai scegliere quanto spendere ogni mese.';

  @override
  String get theme => 'Aspetto';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get system => 'Sistema';

  @override
  String get logout => 'Esci';

  @override
  String get loading => 'Caricamento';

  @override
  String get noCategories =>
      'Nessuna categoria disponibile per questo tipo di movimento.';

  @override
  String get tooLong => 'Usa al massimo 200 caratteri';

  @override
  String get month => 'Questo mese';

  @override
  String get mockMode => 'MODALITÀ PROVA · Dati simulati, modifiche temporanee';

  @override
  String get mockLogin =>
      'Per provare l’app, usa un’email valida e una password qualsiasi. Non verrà creato un account reale.';

  @override
  String get mockReset => 'Modalità prova: nessuna email è stata inviata.';
}
