import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/summary_tile.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNewReport;
  final VoidCallback onSeeAll;

  const DashboardScreen({
    super.key,
    required this.onNewReport,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<IncidentProvider>();
    final user = auth.appUser;
    if (user == null) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final firstName = user.name.trim().split(' ').first;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

    // Students see their own numbers. Staff see the whole campus.
    final List<Incident> numbers = auth.isStaff
        ? provider.allIncidents
        : provider.incidentsBy(user.uid);
    int countOf(String status) =>
        numbers.where((incident) => incident.status == status).length;

    final recent = provider.allIncidents.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ----- greeting -----
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Hello, $firstName',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.waving_hand, color: Colors.amber),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Help make our campus safer.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(radius: 22, child: Text(initial)),
              ],
            ),
            const SizedBox(height: 20),

            // ----- big report button -----
            _ReportBanner(onPressed: onNewReport),
            const SizedBox(height: 24),

            // ----- numbers -----
            Text(
              auth.isStaff ? 'Campus summary' : 'My summary',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SummaryRow(
              tiles: [
                SummaryTile(
                  label: 'Total',
                  count: numbers.length,
                  icon: Icons.description_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SummaryTile(
                  label: 'Submitted',
                  count: countOf('Submitted'),
                  icon: statusIcon('Submitted'),
                  color: statusColor('Submitted'),
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

            // ----- recent reports -----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent reports',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(onPressed: onSeeAll, child: const Text('See all')),
              ],
            ),
            if (provider.loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (recent.isEmpty)
              const EmptyState(
                icon: Icons.inbox_outlined,
                message: 'No reports yet. Tap "Report an Issue" to add one.',
              )
            else
              for (final incident in recent) IncidentCard(incident: incident),
          ],
        ),
      ),
    );
  }
}

class _ReportBanner extends StatelessWidget {
  final VoidCallback onPressed;

  const _ReportBanner({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF6C4EF2), Color(0xFF9B7BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'See an issue on campus?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Report it and help improve our learning environment.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6C4EF2),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Report an Issue'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.apartment, size: 72, color: Colors.white24),
        ],
      ),
    );
  }
}
