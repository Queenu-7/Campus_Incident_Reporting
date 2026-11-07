import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final String? imageUrl;
  final String reporterId;
  final String reporterName;
  final bool anonymous;
  final String staffNote;
  final List<String> meToo;
  final DateTime createdAt;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    this.imageUrl,
    required this.reporterId,
    required this.reporterName,
    required this.anonymous,
    required this.staffNote,
    required this.meToo,
    required this.createdAt,
  });

  String get displayName => anonymous ? 'Anonymous' : reporterName;

  factory Incident.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['createdAt'];
    return Incident(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      location: map['location'] ?? '',
      status: map['status'] ?? 'Submitted',
      imageUrl: map['imageUrl'],
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      anonymous: map['anonymous'] ?? false,
      staffNote: map['staffNote'] ?? '',
      meToo: List<String>.from(map['meToo'] ?? []),

      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'category': category,
    'location': location,
    'status': status,
    'imageUrl': imageUrl,
    'reporterId': reporterId,
    'reporterName': reporterName,
    'anonymous': anonymous,
    'staffNote': staffNote,
    'meToo': meToo,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
