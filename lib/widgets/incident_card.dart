import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../screens/reports/report_detail_screen.dart';
import '../utils/app_constants.dart';
import 'status_chip.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;

  const IncidentCard({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportDetailScreen(incidentId: incident.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Thumbnail(incident: incident),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${incident.location} • ${timeAgo(incident.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatusChip(status: incident.status),
                        const SizedBox(width: 10),
                        const Icon(Icons.thumb_up_alt_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text('${incident.meToo.length}'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

/// The photo if there is one, otherwise the category icon.
class _Thumbnail extends StatelessWidget {
  final Incident incident;

  const _Thumbnail({required this.incident});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final iconBox = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(categoryIcon(incident.category), color: scheme.primary),
    );

    if (incident.imageUrl == null) return iconBox;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        incident.imageUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        // If the photo can't load, show the icon instead.
        errorBuilder: (context, error, stack) => iconBox,
      ),
    );
  }
}
