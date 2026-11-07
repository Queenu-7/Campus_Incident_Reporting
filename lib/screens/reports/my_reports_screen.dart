import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    final provider = context.watch<IncidentProvider>();
    if (user == null) return const SizedBox.shrink();

    final mine = provider.incidentsBy(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text('My reports')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : mine.isEmpty
          ? const EmptyState(
              icon: Icons.inbox_outlined,
              message: "You haven't reported anything yet.",
            )
          : ListView.builder(
              itemCount: mine.length,
              itemBuilder: (context, index) =>
                  IncidentCard(incident: mine[index]),
            ),
    );
  }
}
