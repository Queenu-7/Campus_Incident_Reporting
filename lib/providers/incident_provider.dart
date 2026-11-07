import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service = IncidentService();
  StreamSubscription? _subscription;

  List<Incident> allIncidents = [];
  bool loading = true;
  bool saving = false;
  String? error;
  String? submitError;

  String searchText = '';
  String categoryFilter = 'All';
  String statusFilter = 'All';

  void startListening() {
    if (_subscription != null) return;
    _subscription = _service.watchIncidents().listen((list) {
      allIncidents = list;
      loading = false;
      error = null;
      notifyListeners();
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    allIncidents = [];
    loading = true;
    error = null;
    searchText = '';
    categoryFilter = 'All';
    statusFilter = 'All';
  }

  List<Incident> get filteredIncidents {
    final text = searchText.toLowerCase();
    return allIncidents.where((incident) {
      final matchesCategory =
          categoryFilter == 'All' || incident.category == categoryFilter;
      final matchesStatus =
          statusFilter == 'All' || incident.status == statusFilter;
      final matchesSearch =
          text.isEmpty ||
          incident.title.toLowerCase().contains(text) ||
          incident.description.toLowerCase().contains(text) ||
          incident.location.toLowerCase().contains(text);
      return matchesCategory && matchesStatus && matchesSearch;
    }).toList();
  }

  List<Incident> incidentsBy(String uid) =>
      allIncidents.where((i) => i.reporterId == uid).toList();

  List<Incident> get openIncidents =>
      allIncidents.where((i) => i.status != 'Resolved').toList();

  int countByStatus(String status) =>
      allIncidents.where((i) => i.status == status).length;

  Incident? findById(String id) {
    for (final incident in allIncidents) {
      if (incident.id == id) return incident;
    }
    return null;
  }

  void setSearch(String value) {
    searchText = value;
    notifyListeners();
  }

  void setCategoryFilter(String value) {
    categoryFilter = value;
    notifyListeners();
  }

  void setStatusFilter(String value) {
    statusFilter = value;
    notifyListeners();
  }

  Future<bool> submitIncident({
    required String title,
    required String description,
    required String category,
    required String location,
    required bool anonymous,
    required String reporterId,
    required String reporterName,
    Uint8List? imageBytes,
  }) async {
    saving = true;
    submitError = null;
    notifyListeners();
    try {
      final incident = Incident(
        id: '',
        title: title.trim(),
        description: description.trim(),
        category: category,
        location: location.trim(),
        status: 'Submitted',
        reporterId: reporterId,
        reporterName: reporterName,
        anonymous: anonymous,
        staffNote: '',
        meToo: [],
        createdAt: DateTime.now(),
      );
      await _service.createIncident(incident, imageBytes);
      saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('SUBMIT ERROR: $e');
      submitError =
          'Could not submit the report. If you attached a photo, '
          'check that Firebase Storage is enabled.\n$e';
      saving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(String id, String status, String note) async {
    try {
      await _service.updateStatus(id, status, note);
      return true;
    } catch (e) {
      debugPrint('UPDATE STATUS ERROR: $e');
      return false;
    }
  }

  Future<void> toggleMeToo(Incident incident, String uid) async {
    try {
      await _service.toggleMeToo(
        incident.id,
        uid,
        incident.meToo.contains(uid),
      );
    } catch (e) {
      debugPrint('ME TOO ERROR: $e');
    }
  }

  Future<bool> deleteIncident(Incident incident) async {
  try {
    await _service.deleteIncident(incident);
    return true;
  } catch (e) {
    debugPrint('DELETE INCIDENT ERROR: $e');
    return false;
  }
}

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
