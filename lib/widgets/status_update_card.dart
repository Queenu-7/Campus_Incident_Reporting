import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/incident_provider.dart';
import '../utils/app_constants.dart';
import 'app_text_field.dart';
import 'loading_button.dart';
import 'option_chips.dart';

/// Lets STAFF change a report's status and leave a note.
class StatusUpdateCard extends StatefulWidget {
  final Incident incident;

  const StatusUpdateCard({super.key, required this.incident});

  @override
  State<StatusUpdateCard> createState() => _StatusUpdateCardState();
}

class _StatusUpdateCardState extends State<StatusUpdateCard> {
  late String _selectedStatus;
  late final TextEditingController _noteController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.incident.status;
    _noteController = TextEditingController(text: widget.incident.staffNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final success = await context.read<IncidentProvider>().updateStatus(
      widget.incident.id,
      _selectedStatus,
      _noteController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Status updated' : 'Update failed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            OptionChips(
              options: statuses,
              selected: _selectedStatus,
              onSelected: (value) => setState(() => _selectedStatus = value),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _noteController,
              label: 'Note to students (optional)',
              icon: Icons.chat_bubble_outline,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            LoadingButton(
              label: 'Save update',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
