import 'package:flutter/material.dart';

import '../../../core/widgets/components.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});
  @override
  Widget build(BuildContext context) => BilanqoScaffold(
    title: context.l.budgets,
    child: EmptyState(
      icon: Icons.pie_chart_outline,
      message: '${context.l.comingSoon}\n\n${context.l.budgetsText}',
    ),
  );
}
