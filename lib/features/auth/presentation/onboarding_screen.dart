import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/theme.dart';
import '../../../core/widgets/components.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  @override
  Widget build(BuildContext context) {
    final it = Localizations.localeOf(context).languageCode == 'it';
    final titles = it
        ? [
            'Tutti i tuoi soldi, in un unico posto',
            'Dividere le spese non è mai stato così semplice',
            'Trova il tuo equilibrio finanziario',
          ]
        : [
            'All your money, in one place',
            'Sharing expenses made simple',
            'Find your financial balance',
          ];
    final descriptions = it
        ? [
            'Tieni sotto controllo entrate, uscite e risparmi con la massima trasparenza, senza stress.',
            'Organizza le quote con amici, viaggi di gruppo e coinquilini.',
            'Pianifica i tuoi limiti mensili e dai spazio ai tuoi obiettivi.',
          ]
        : [
            'Keep track of income, expenses and savings with clarity.',
            'Organize expenses with friends, travel groups and housemates.',
            'Plan monthly limits and make room for your goals.',
          ];
    return BilanqoScaffold(
      title: 'Bilanqo',
      actions: [
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text(it ? 'Salta' : 'Skip'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == step ? 40 : 12,
                height: 6,
                decoration: BoxDecoration(
                  color: i == step ? Tokens.primary : Tokens.mint,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 240,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary
                                  .withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          const CustomPaint(
                            size: Size(170, 120),
                            painter: _BalanceIllustration(),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.balance,
                                      color: Tokens.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      it
                                          ? 'In perfetto equilibrio'
                                          : 'Perfectly balanced',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    it
                        ? 'I tuoi soldi, in perfetto equilibrio'
                        : 'Your money, perfectly balanced',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              titles[step],
              key: ValueKey(step),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 12),
          Text(descriptions[step], textAlign: TextAlign.center),
          const SizedBox(height: 24),
          for (var i = 0; i < 3; i++) ...[
            Card(
              child: ListTile(
                onTap: () => setState(() => step = i),
                leading: Icon(
                  [
                    Icons.account_balance_wallet,
                    Icons.group,
                    Icons.pie_chart,
                  ][i],
                  color: Tokens.primary,
                ),
                title: Text(
                  (it
                      ? [
                          'Tutti i conti uniti',
                          'Dividere le spese',
                          'Equilibrio finanziario',
                        ]
                      : [
                          'All accounts together',
                          'Shared expenses',
                          'Financial balance',
                        ])[i],
                ),
                trailing: Icon(
                  i == step ? Icons.check_circle : Icons.chevron_right,
                  color: Tokens.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          PrimaryButton(
            label: step == 2
                ? (it ? 'Inizia subito' : 'Get started')
                : (it ? 'Continua' : 'Continue'),
            onPressed: () =>
                step == 2 ? context.go('/register') : setState(() => step++),
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(context.l.login),
          ),
        ],
      ),
    );
  }
}

class _BalanceIllustration extends CustomPainter {
  const _BalanceIllustration();
  @override
  void paint(Canvas canvas, Size size) {
    final left = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * .35, size.height * .5),
          radius: 48,
        ),
      );
    final right = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * .65, size.height * .5),
          radius: 48,
        ),
      );
    canvas.drawPath(left, Paint()..color = Tokens.primaryContainer);
    canvas.drawPath(right, Paint()..color = const Color(0xFF8AD6B4));
    canvas.drawPath(
      Path.combine(PathOperation.intersect, left, right),
      Paint()..color = Tokens.background,
    );
  }

  @override
  bool shouldRepaint(covariant _BalanceIllustration oldDelegate) => false;
}
