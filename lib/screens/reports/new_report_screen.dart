import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/category_picker.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/loading_button.dart';

/// The form students use to submit a report.
class NewReportScreen extends StatefulWidget {
  final VoidCallback onSubmitted; // tells HomeScreen to switch tabs

  const NewReportScreen({super.key, required this.onSubmitted});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = categories.first;
  bool _anonymous = false;
  Uint8List? _imageBytes; // the chosen photo (optional)

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    // imageQuality + maxWidth make the photo smaller = faster upload
    final file = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (file == null) return; // user cancelled
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _imageBytes = bytes);
  }

  Future<void> _choosePhoto() async {
    // The browser has no camera option, so go straight to the gallery.
    if (kIsWeb) {
      await _pickImage(ImageSource.gallery);
      return;
    }
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickImage(source);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().appUser;
    if (user == null) return;

    final success = await context.read<IncidentProvider>().submitIncident(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _category,
      location: _locationController.text,
      anonymous: _anonymous,
      reporterId: user.uid,
      reporterName: user.name,
      imageBytes: _imageBytes,
    );

    if (!mounted) return;
    if (success) {
      // Clear the form for next time.
      _titleController.clear();
      _locationController.clear();
      _descriptionController.clear();
      setState(() {
        _category = categories.first;
        _anonymous = false;
        _imageBytes = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted. Thank you!')),
      );
      widget.onSubmitted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentProvider>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('Select a category'),
              CategoryPicker(
                selected: _category,
                onSelected: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _titleController,
                label: 'Title',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return 'Enter a title (at least 5 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: 'Describe the problem',
                icon: Icons.notes,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Please describe it (at least 10 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _locationController,
                label: 'Location (e.g. Block B, Room 204)',
                icon: Icons.place_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Where is the problem?';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Add a photo (optional)'),
              GestureDetector(
                onTap: _choosePhoto,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD9D4EC)),
                  ),
                  child: _imageBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 36,
                              color: primary,
                            ),
                            const SizedBox(height: 6),
                            const Text('Tap to add a photo'),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(
                            _imageBytes!,
                            width: double.infinity,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              if (_imageBytes != null)
                TextButton.icon(
                  onPressed: () => setState(() => _imageBytes = null),
                  icon: const Icon(Icons.close),
                  label: const Text('Remove photo'),
                ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  title: const Text('Report anonymously'),
                  subtitle: const Text("Other students won't see your name"),
                  value: _anonymous,
                  onChanged: (value) => setState(() => _anonymous = value),
                ),
              ),
              const SizedBox(height: 16),
              if (incidents.submitError != null)
                ErrorBanner(message: incidents.submitError!),
              LoadingButton(
                label: 'Submit report',
                loading: incidents.saving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
