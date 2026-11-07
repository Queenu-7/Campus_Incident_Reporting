import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const List<String> categories = [
  'Water',
  'Electricity',
  'Facilities',
  'Furniture',
  'Sanitation',
  'Safety',
  'Other',
];

const List<String> statuses = [
  'Submitted',
  'In Review',
  'In Progress',
  'Resolved',
];

// Category icons
IconData categoryIcon(String category) {
  switch (category) {
    case 'Water':
      return Icons.water_drop_outlined;
    case 'Electricity':
      return Icons.bolt;
    case 'Facilities':
      return Icons.apartment;
    case 'Furniture':
      return Icons.chair_alt;
    case 'Sanitation':
      return Icons.clean_hands;
    case 'Safety':
      return Icons.health_and_safety;
    default:
      return Icons.report_problem_outlined;
  }
}

// Status colors
Color statusColor(String status) {
  switch (status) {
    case 'In Review':
      return Colors.blue.shade700;
    case 'In Progress':
      return Colors.purple.shade700;
    case 'Resolved':
      return Colors.green.shade700;
    default:
      return Colors.orange.shade800;
  }
}

// Status icons
IconData statusIcon(String status) {
  switch (status) {
    case 'Submitted':
      return Icons.pending_actions;
    case 'In Review':
      return Icons.rate_review_outlined;
    case 'In Progress':
      return Icons.hourglass_top;
    case 'Resolved':
      return Icons.check_circle_outline;
    default:
      return Icons.help_outline;
  }
}

// Time ago function
String timeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return DateFormat('d MMM yyyy').format(dateTime);
  }
}
