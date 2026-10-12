import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @home.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @transactions.
  ///
  /// In it, this message translates to:
  /// **'Movimenti'**
  String get transactions;

  /// No description provided for @groups.
  ///
  /// In it, this message translates to:
  /// **'Gruppi'**
  String get groups;

  /// No description provided for @budgets.
  ///
  /// In it, this message translates to:
  /// **'Budget'**
  String get budgets;

  /// No description provided for @profile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get profile;

  /// No description provided for @accounts.
  ///
  /// In it, this message translates to:
  /// **'Conti'**
  String get accounts;

  /// No description provided for @login.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get login;

  /// No description provided for @register.
  ///
  /// In it, this message translates to:
  /// **'Crea un account'**
  String get register;

  /// No description provided for @reset.
  ///
  /// In it, this message translates to:
  /// **'Recupera password'**
  String get reset;

  /// No description provided for @email.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @invalidEmail.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un’email valida'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la password'**
  String get invalidPassword;

  /// No description provided for @weakPassword.
  ///
  /// In it, this message translates to:
  /// **'Usa almeno 8 caratteri'**
  String get weakPassword;

  /// No description provided for @welcome.
  ///
  /// In it, this message translates to:
  /// **'Le tue finanze, più semplici.'**
  String get welcome;

  /// No description provided for @intro.
  ///
  /// In it, this message translates to:
  /// **'Un posto per capire le tue spese e fare spazio ai tuoi progetti.'**
  String get intro;

  /// No description provided for @firebaseSetup.
  ///
  /// In it, this message translates to:
  /// **'Il servizio di accesso non è ancora disponibile.'**
  String get firebaseSetup;

  /// No description provided for @resetSent.
  ///
  /// In it, this message translates to:
  /// **'Se l’indirizzo è registrato, riceverai le istruzioni per recuperare la password.'**
  String get resetSent;

  /// No description provided for @networkError.
  ///
  /// In it, this message translates to:
  /// **'Non riusciamo a connetterci. Controlla la connessione e riprova.'**
  String get networkError;

  /// No description provided for @unauthorized.
  ///
  /// In it, this message translates to:
  /// **'La sessione non è valida. Esci e accedi di nuovo.'**
  String get unauthorized;

  /// No description provided for @genericError.
  ///
  /// In it, this message translates to:
  /// **'Non è stato possibile completare l’operazione. Riprova.'**
  String get genericError;

  /// No description provided for @authError.
  ///
  /// In it, this message translates to:
  /// **'Accesso non riuscito. Verifica i dati o riprova più tardi.'**
  String get authError;

  /// No description provided for @contractError.
  ///
  /// In it, this message translates to:
  /// **'I dati ricevuti non sono compatibili con questa versione dell’app.'**
  String get contractError;

  /// No description provided for @configurationError.
  ///
  /// In it, this message translates to:
  /// **'Il servizio non è ancora disponibile. Riprova più tardi.'**
  String get configurationError;

  /// No description provided for @validationError.
  ///
  /// In it, this message translates to:
  /// **'Controlla i dati inseriti e riprova.'**
  String get validationError;

  /// No description provided for @forbidden.
  ///
  /// In it, this message translates to:
  /// **'Non hai accesso a questi dati.'**
  String get forbidden;

  /// No description provided for @retry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;

  /// No description provided for @empty.
  ///
  /// In it, this message translates to:
  /// **'Ancora nessun elemento'**
  String get empty;

  /// No description provided for @emptyMovements.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi il tuo primo movimento per iniziare.'**
  String get emptyMovements;

  /// No description provided for @emptyAccounts.
  ///
  /// In it, this message translates to:
  /// **'Crea un conto per iniziare a registrare le tue spese.'**
  String get emptyAccounts;

  /// No description provided for @balance.
  ///
  /// In it, this message translates to:
  /// **'Saldo totale'**
  String get balance;

  /// No description provided for @income.
  ///
  /// In it, this message translates to:
  /// **'Le tue entrate'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In it, this message translates to:
  /// **'Le tue spese'**
  String get expense;

  /// No description provided for @remaining.
  ///
  /// In it, this message translates to:
  /// **'Quanto ti rimane questo mese?'**
  String get remaining;

  /// No description provided for @recent.
  ///
  /// In it, this message translates to:
  /// **'Ultimi movimenti'**
  String get recent;

  /// No description provided for @addMovement.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi un movimento'**
  String get addMovement;

  /// No description provided for @addExpense.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi una spesa'**
  String get addExpense;

  /// No description provided for @newAccount.
  ///
  /// In it, this message translates to:
  /// **'Crea un conto'**
  String get newAccount;

  /// No description provided for @name.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @accountType.
  ///
  /// In it, this message translates to:
  /// **'Tipo di conto'**
  String get accountType;

  /// No description provided for @bank.
  ///
  /// In it, this message translates to:
  /// **'Conto bancario'**
  String get bank;

  /// No description provided for @cash.
  ///
  /// In it, this message translates to:
  /// **'Contanti'**
  String get cash;

  /// No description provided for @savings.
  ///
  /// In it, this message translates to:
  /// **'Risparmi'**
  String get savings;

  /// No description provided for @initialBalance.
  ///
  /// In it, this message translates to:
  /// **'Saldo iniziale'**
  String get initialBalance;

  /// No description provided for @amount.
  ///
  /// In it, this message translates to:
  /// **'Importo'**
  String get amount;

  /// No description provided for @invalidAmount.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un importo valido, con massimo 2 decimali'**
  String get invalidAmount;

  /// No description provided for @positiveAmount.
  ///
  /// In it, this message translates to:
  /// **'L’importo deve essere maggiore di zero'**
  String get positiveAmount;

  /// No description provided for @required.
  ///
  /// In it, this message translates to:
  /// **'Questo campo è obbligatorio'**
  String get required;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @description.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get description;

  /// No description provided for @date.
  ///
  /// In it, this message translates to:
  /// **'Data'**
  String get date;

  /// No description provided for @account.
  ///
  /// In it, this message translates to:
  /// **'Conto'**
  String get account;

  /// No description provided for @category.
  ///
  /// In it, this message translates to:
  /// **'Categoria'**
  String get category;

  /// No description provided for @type.
  ///
  /// In it, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @newMovement.
  ///
  /// In it, this message translates to:
  /// **'Nuovo movimento'**
  String get newMovement;

  /// No description provided for @comingSoon.
  ///
  /// In it, this message translates to:
  /// **'Funzionalità in arrivo'**
  String get comingSoon;

  /// No description provided for @groupsText.
  ///
  /// In it, this message translates to:
  /// **'Dividi con gli amici. Presto potrai gestire spese condivise e rimborsi in un solo posto.'**
  String get groupsText;

  /// No description provided for @budgetsText.
  ///
  /// In it, this message translates to:
  /// **'Dai spazio ai tuoi obiettivi. Presto potrai scegliere quanto spendere ogni mese.'**
  String get budgetsText;

  /// No description provided for @theme.
  ///
  /// In it, this message translates to:
  /// **'Aspetto'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get system;

  /// No description provided for @logout.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get logout;

  /// No description provided for @loading.
  ///
  /// In it, this message translates to:
  /// **'Caricamento'**
  String get loading;

  /// No description provided for @noCategories.
  ///
  /// In it, this message translates to:
  /// **'Nessuna categoria disponibile per questo tipo di movimento.'**
  String get noCategories;

  /// No description provided for @tooLong.
  ///
  /// In it, this message translates to:
  /// **'Usa al massimo 200 caratteri'**
  String get tooLong;

  /// No description provided for @month.
  ///
  /// In it, this message translates to:
  /// **'Questo mese'**
  String get month;

  /// No description provided for @mockMode.
  ///
  /// In it, this message translates to:
  /// **'MODALITÀ PROVA · Dati simulati, modifiche temporanee'**
  String get mockMode;

  /// No description provided for @mockLogin.
  ///
  /// In it, this message translates to:
  /// **'Per provare l’app, usa un’email valida e una password qualsiasi. Non verrà creato un account reale.'**
  String get mockLogin;

  /// No description provided for @mockReset.
  ///
  /// In it, this message translates to:
  /// **'Modalità prova: nessuna email è stata inviata.'**
  String get mockReset;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
