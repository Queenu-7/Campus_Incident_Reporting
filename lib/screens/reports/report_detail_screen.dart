import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../widgets/status_timeline.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_update_card.dart';

class ReportDetailScreen extends StatelessWidget {
  final String incidentId;

  const ReportDetailScreen({super.key, required this.incidentId});

  Future<void> _confirmDelete(BuildContext context, incident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final success = await context.read<IncidentProvider>().deleteIncident(
      incident,
    );
    if (!context.mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete the report.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final auth = context.watch<AuthProvider>();
    final incident = provider.findById(incidentId);
    final user = auth.appUser;

    if (user == null) return const SizedBox.shrink();
    if (incident == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off,
          message: 'This report no longer exists.',
        ),
      );
    }

    final joined = incident.meToo.contains(user.uid);
    // Students can delete only their own report, and only before staff act.
    final canDelete =
        incident.reporterId == user.uid && incident.status == 'Submitted';

    return Scaffold(
      appBar: AppBar(title: const Text('Report details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (incident.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                incident.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                errorBuilder: (context, error, stack) => const SizedBox(
                  height: 120,
                  child: Center(child: Text('Photo could not be loaded')),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            incident.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip(status: incident.status),
              Chip(
                avatar: Icon(categoryIcon(incident.category), size: 18),
                label: Text(incident.category),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status timeline',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  StatusTimeline(status: incident.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Description', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(incident.description),
          const Divider(height: 32),
          _InfoRow(icon: Icons.place_outlined, text: incident.location),
          _InfoRow(
            icon: Icons.person_outline,
            text: 'Reported by ${incident.displayName}',
          ),
          _InfoRow(
            icon: Icons.schedule,
            text: DateFormat('d MMM yyyy, HH:mm').format(incident.createdAt),
          ),
          const SizedBox(height: 12),
          if (incident.staffNote.isNotEmpty)
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Staff response',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(incident.staffNote),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => provider.toggleMeToo(incident, user.uid),
            icon: Icon(joined ? Icons.thumb_up : Icons.thumb_up_outlined),
            label: Text('Me too (${incident.meToo.length})'),
          ),
          // Staff-only controls (also protected by Firestore rules later)
          if (auth.isStaff) StatusUpdateCard(incident: incident),
          if (canDelete)
            TextButton.icon(
              onPressed: () => _confirmDelete(context, incident),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Delete my report',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
