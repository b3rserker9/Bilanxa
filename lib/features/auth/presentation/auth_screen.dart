import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/theme.dart';
import '../../../core/config/config.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/components.dart';
import '../data/auth_repository.dart';

enum AuthMode { login, register, reset }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.mode = AuthMode.login});
  final AuthMode mode;
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(), _password = TextEditingController();
  bool _busy = false, _hidden = true;
  String? _error, _message;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      final auth = ref.read(authRepositoryProvider);
      switch (widget.mode) {
        case AuthMode.login:
          await auth.login(_email.text, _password.text);
        case AuthMode.register:
          await auth.register(_email.text, _password.text);
        case AuthMode.reset:
          await auth.resetPassword(_email.text);
          if (mounted) {
            setState(
              () => _message = Config.mockAuth && Config.mocksAllowed
                  ? context.l.mockReset
                  : context.l.resetSent,
            );
          }
      }
    } catch (e) {
      if (mounted) setState(() => _error = context.errorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final title = switch (widget.mode) {
      AuthMode.login => l.login,
      AuthMode.register => l.register,
      AuthMode.reset => l.reset,
    };
    return BilanqoScaffold(
      title: 'Bilanqo',
      showHeader: false,
      showMockBanner: false,
      child: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: BrandMark()),
              const SizedBox(height: 12),
              Text(
                'Bilanqo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                Localizations.localeOf(context).languageCode == 'it'
                    ? 'I TUOI SOLDI, IN EQUILIBRIO'
                    : 'YOUR MONEY, IN BALANCE',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 32),
              Text(
                Localizations.localeOf(context).languageCode == 'it'
                    ? 'Bentornato su Bilanqo'
                    : 'Welcome to Bilanqo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: Tokens.gap),
              Text(l.intro, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              if (widget.mode != AuthMode.reset)
                SegmentedButton<AuthMode>(
                  segments: [
                    ButtonSegment(
                      value: AuthMode.login,
                      label: Text(
                        Localizations.localeOf(context).languageCode == 'it'
                            ? 'Accesso'
                            : 'Sign in',
                      ),
                    ),
                    ButtonSegment(
                      value: AuthMode.register,
                      label: Text(l.register),
                    ),
                  ],
                  selected: {widget.mode},
                  showSelectedIcon: false,
                  onSelectionChanged: _busy
                      ? null
                      : (value) => context.go(
                          value.first == AuthMode.login
                              ? '/login'
                              : '/register',
                        ),
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Tokens.page),
                    if (Config.mockAuth && Config.mocksAllowed)
                      Text(
                        l.mockLogin,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (ref.watch(setupErrorProvider) != null)
                      Text(l.firebaseSetup),
                    const SizedBox(height: Tokens.gap),
                    TextFormField(
                      enabled: !_busy,
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l.email,
                        prefixIcon: const Icon(Icons.mail_outline),
                      ),
                      validator: (v) =>
                          Validators.email(v ?? '') ? null : l.invalidEmail,
                    ),
                    if (widget.mode != AuthMode.reset) ...[
                      const SizedBox(height: Tokens.gap),
                      TextFormField(
                        enabled: !_busy,
                        controller: _password,
                        obscureText: _hidden,
                        autofillHints: [
                          widget.mode == AuthMode.register
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        onFieldSubmitted: (_) => _busy ? null : _submit(),
                        decoration: InputDecoration(
                          labelText: l.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: l.password,
                            onPressed: () => setState(() => _hidden = !_hidden),
                            icon: Icon(
                              _hidden
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) =>
                            (widget.mode == AuthMode.register
                                ? Validators.registrationPassword(v ?? '')
                                : Validators.password(v ?? ''))
                            ? null
                            : (widget.mode == AuthMode.register
                                  ? l.weakPassword
                                  : l.invalidPassword),
                      ),
                    ],
                    const SizedBox(height: Tokens.page),
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: Tokens.gap),
                    ],
                    if (_message != null) ...[
                      Text(_message!),
                      const SizedBox(height: Tokens.gap),
                    ],
                    PrimaryButton(
                      label: title,
                      onPressed: ref.watch(setupErrorProvider) == null
                          ? _submit
                          : null,
                      busy: _busy,
                    ),
                    if (widget.mode == AuthMode.login) ...[
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => context.push('/register'),
                        child: Text(l.register),
                      ),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => context.push('/reset-password'),
                        child: Text(l.reset),
                      ),
                    ] else
                      TextButton(
                        onPressed: _busy ? null : () => context.go('/login'),
                        child: Text(l.login),
                      ),
                  ],
                ),
              ),
              if (widget.mode == AuthMode.login)
                TextButton(
                  onPressed: () => context.go('/onboarding'),
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'it'
                        ? 'Scopri Bilanqo'
                        : 'Explore Bilanqo',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
