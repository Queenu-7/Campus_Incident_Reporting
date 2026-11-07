import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/incident_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/option_chips.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final incidents = provider.filteredIncidents;

    Widget content;
    if (provider.loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (provider.error != null) {
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: ErrorBanner(message: provider.error!),
      );
    } else if (incidents.isEmpty) {
      content = EmptyState(
        icon: Icons.search_off,
        message: provider.allIncidents.isEmpty
            ? 'No reports yet. Be the first to report an issue!'
            : 'No reports match your search or filters.',
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: incidents.length,
        itemBuilder: (context, index) =>
            IncidentCard(incident: incidents[index]),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        // stretch makes the chip rows start at the left edge
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: provider.setSearch,
              decoration: InputDecoration(
                hintText: 'Search title, description or location',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: OptionChips(
              options: ['All', ...categories],
              selected: provider.categoryFilter,
              onSelected: provider.setCategoryFilter,
              scrollable: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: OptionChips(
              options: ['All', ...statuses],
              selected: provider.statusFilter,
              onSelected: provider.setStatusFilter,
              scrollable: true,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: content),
        ],
      ),
    );
  }
}
