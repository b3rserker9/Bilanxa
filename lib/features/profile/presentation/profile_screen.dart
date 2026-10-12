import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../core/widgets/components.dart';
import '../../../core/widgets/dropdown.dart';
import '../../auth/data/auth_repository.dart';
import '../../transactions/data/finance_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _busy = false;
  Object? _error;
  Future<void> _logout() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => BilanqoScaffold(
    title: context.l.profile,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AsyncSection(
          value: ref.watch(profileProvider),
          retry: () => ref.invalidate(profileProvider),
          builder: (p) => Card(
            child: Padding(
              padding: const EdgeInsets.all(Tokens.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: Tokens.small),
                  Text(p.email),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Tokens.page),
        Text(context.l.theme, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Tokens.gap),
        BilanqoDropdown<ThemeMode>(
          leading: Icons.palette_outlined,
          initialValue: ref.watch(themeProvider),
          items: [
            DropdownMenuItem(
              value: ThemeMode.system,
              child: Text(context.l.system),
            ),
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Text(context.l.light),
            ),
            DropdownMenuItem(
              value: ThemeMode.dark,
              child: Text(context.l.dark),
            ),
          ],
          onChanged: (mode) => ref.read(themeProvider.notifier).set(mode!),
        ),
        const SizedBox(height: Tokens.page),
        if (_error != null) Text(context.errorMessage(_error!)),
        PrimaryButton(label: context.l.logout, onPressed: _logout, busy: _busy),
      ],
    ),
  );
}
