import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/components.dart';
import '../theme/theme.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/accounts/presentation/accounts_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/transactions/presentation/new_transaction_screen.dart';
import '../../features/groups/presentation/groups_screen.dart';
import '../../features/budgets/presentation/budgets_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/recurring/presentation/scheduled_expenses_panel.dart';

String? authRedirect({
  required String path,
  required bool loading,
  required bool signedIn,
  bool failed = false,
}) {
  if (loading || failed) return path == '/splash' ? null : '/splash';
  final public = [
    '/login',
    '/register',
    '/reset-password',
    '/onboarding',
  ].contains(path);
  if (!signedIn) return public ? null : '/login';
  return public || path == '/splash' ? '/home' : null;
}

class _RouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(sessionProvider, (_, _) => refresh.refresh());
  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      return authRedirect(
        path: state.uri.path,
        loading: session.isLoading,
        signedIn: session.asData?.value != null,
        failed: session.hasError,
      );
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const AuthScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/register',
        builder: (_, _) => const AuthScreen(mode: AuthMode.register),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, _) => const AuthScreen(mode: AuthMode.reset),
      ),
      ShellRoute(
        builder: (context, state, child) => _NavigationShell(
          path: state.uri.path,
          scheduled: state.uri.queryParameters['tab'] == 'scheduled',
          child: child,
        ),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const DashboardScreen()),
          GoRoute(
            path: '/transactions',
            builder: (_, state) => TransactionsScreen(
              scheduled: state.uri.queryParameters['tab'] == 'scheduled',
            ),
          ),
          GoRoute(path: '/groups', builder: (_, _) => const GroupsScreen()),
          GoRoute(path: '/budgets', builder: (_, _) => const BudgetsScreen()),
        ],
      ),
      GoRoute(path: '/accounts', builder: (_, _) => const AccountsScreen()),
      GoRoute(
        path: '/transactions/new',
        builder: (_, _) => const NewTransactionScreen(),
      ),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class _NavigationShell extends StatelessWidget {
  const _NavigationShell({
    required this.path,
    required this.child,
    this.scheduled = false,
  });
  final bool scheduled;
  final String path;
  final Widget child;
  static const paths = ['/home', '/transactions', '/groups', '/budgets'];
  @override
  Widget build(BuildContext context) {
    final navigationHeight =
        64.0 + (MediaQuery.textScalerOf(context).scale(14) - 14).clamp(0, 40);
    final labels = [
      context.l.home,
      context.l.transactions,
      context.l.groups,
      context.l.budgets,
    ];
    final icons = [
      Icons.home_outlined,
      Icons.receipt_long_outlined,
      Icons.people_outline,
      Icons.pie_chart_outline,
    ];
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SizedBox(
              height: navigationHeight + 24,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: navigationHeight,
                    decoration: BoxDecoration(
                      color: Tokens.inverseSurface.withValues(alpha: .95),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x28103F34),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        for (var i = 0; i < 4; i++) ...[
                          if (i == 2) const SizedBox(width: 52),
                          Expanded(
                            child: Semantics(
                              selected: path == paths[i],
                              button: true,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () => context.go(paths[i]),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        icons[i],
                                        size: 22,
                                        color: path == paths[i]
                                            ? Tokens.mint
                                            : Colors.white60,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        labels[i],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: path == paths[i]
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: path == paths[i]
                                              ? Tokens.mint
                                              : Colors.white60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 4,
                        ),
                      ),
                      child: FloatingActionButton(
                        heroTag: 'navigation-add',
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        tooltip: scheduled
                            ? tr(
                                context,
                                'Aggiungi spesa fissa',
                                'Add recurring expense',
                              )
                            : context.l.addMovement,
                        backgroundColor: Tokens.primaryContainer,
                        foregroundColor: Colors.white,
                        onPressed: () => scheduled && path == '/transactions'
                            ? showScheduledEditor(context)
                            : context.push('/transactions/new'),
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return BilanqoScaffold(
      title: 'Bilanqo',
      child: Column(
        children: [
          Text('Bilanqo', style: Theme.of(context).textTheme.displayMedium),
          if (session.hasError)
            ErrorState(
              error: session.error!,
              retry: () => ref.invalidate(sessionProvider),
            )
          else
            const LoadingIndicator(),
        ],
      ),
    );
  }
}
