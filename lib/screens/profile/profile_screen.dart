import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/summary_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    final provider = context.watch<IncidentProvider>();
    if (user == null) return const SizedBox.shrink();

    final mine = provider.incidentsBy(user.uid);
    int countOf(String status) =>
        mine.where((incident) => incident.status == status).length;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ----- who am I -----
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    child: Text(initial, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          avatar: Icon(
                            user.role == 'staff'
                                ? Icons.admin_panel_settings_outlined
                                : Icons.school_outlined,
                            size: 18,
                          ),
                          label: Text(user.role.toUpperCase()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ----- my numbers -----
          SummaryRow(
            tiles: [
              SummaryTile(
                label: 'Total reports',
                count: mine.length,
                icon: Icons.description_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              SummaryTile(
                label: 'In Progress',
                count: countOf('In Progress'),
                icon: statusIcon('In Progress'),
                color: statusColor('In Progress'),
              ),
              SummaryTile(
                label: 'Resolved',
                count: countOf('Resolved'),
                icon: statusIcon('Resolved'),
                color: statusColor('Resolved'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ----- my reports -----
          Text(
            'My reports',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (provider.loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (mine.isEmpty)
            const EmptyState(
              icon: Icons.inbox_outlined,
              message: "You haven't reported anything yet.",
            )
          else
            for (final incident in mine) IncidentCard(incident: incident),

          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton.tonalIcon(
              onPressed: () => context.read<AuthProvider>().logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ),
        ],
      ),
    );
  }
}
