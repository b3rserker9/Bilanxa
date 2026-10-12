import 'package:flutter/material.dart';

import '../../../core/widgets/components.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});
  @override
  Widget build(BuildContext context) => BilanqoScaffold(
    title: context.l.groups,
    child: EmptyState(
      icon: Icons.people_outline,
      message: '${context.l.comingSoon}\n\n${context.l.groupsText}',
    ),
  );
}
