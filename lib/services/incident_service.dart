import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../models/incident.dart';

class IncidentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Supabase connection for image storage
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _bucketName = 'incident-images';

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection('incidents');

  // Watch incidents from Firebase
  Stream<List<Incident>> watchIncidents() {
    return _incidents
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Incident.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Upload image to Supabase Storage
  Future<String> _uploadImage(Uint8List bytes) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabase.storage
        .from(_bucketName)
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        )
        .timeout(const Duration(seconds: 30));

    return _supabase.storage.from(_bucketName).getPublicUrl(fileName);
  }

  // Create incident in Firebase and save image URL
  Future<void> createIncident(Incident incident, Uint8List? imageBytes) async {
    String? imageUrl;

    if (imageBytes != null) {
      imageUrl = await _uploadImage(imageBytes);
    }

    final data = incident.toMap();
    data['imageUrl'] = imageUrl;

    await _incidents.add(data);
  }

  // Update incident status in Firebase
  Future<void> updateStatus(String id, String status, String note) async {
    await _incidents.doc(id).update({'status': status, 'staffNote': note});
  }

  // Join or leave an incident
  Future<void> toggleMeToo(String id, String uid, bool alreadyJoined) async {
    await _incidents.doc(id).update({
      'meToo': alreadyJoined
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }

  // Delete incident and its image
  Future<void> deleteIncident(Incident incident) async {
    await _incidents.doc(incident.id).delete();

    if (incident.imageUrl != null) {
      try {
        final uri = Uri.parse(incident.imageUrl!);
        final segments = uri.pathSegments;

        final bucketIndex = segments.indexOf(_bucketName);

        if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
          final filePath = segments.skip(bucketIndex + 1).join('/');

          await _supabase.storage.from(_bucketName).remove([filePath]);
        }
      } catch (e) {
        debugPrint('Could not delete incident photo: $e');
      }
    }
  }
}
