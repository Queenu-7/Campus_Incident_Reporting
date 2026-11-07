import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/summary_tile.dart';

/// Staff dashboard: counts per status + reports that need attention.
class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<IncidentProvider>();

    // Double check: even if someone reaches this screen, block non-staff.
    if (!auth.isStaff) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.lock_outline,
          message: 'Staff access only.',
        ),
      );
    }

    final open = provider.openIncidents;

    return Scaffold(
      appBar: AppBar(title: const Text('Staff dashboard')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SummaryRow(
              tiles: [
                for (final status in statuses)
                  SummaryTile(
                    label: status,
                    count: provider.countByStatus(status),
                    icon: statusIcon(status),
                    color: statusColor(status),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Needs attention (${open.length})',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: open.isEmpty
                ? const EmptyState(
                    icon: Icons.check_circle_outline,
                    message: 'All caught up!',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: open.length,
                    itemBuilder: (context, index) =>
                        IncidentCard(incident: open[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
