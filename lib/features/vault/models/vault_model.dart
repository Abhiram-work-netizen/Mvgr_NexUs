import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Type of vault item
enum VaultItemType {
  notes,
  pyq,  // Previous Year Questions
  handwritten,
  assignment,
  slides,
  lab,
  other;
  
  String get displayName {
    switch (this) {
      case VaultItemType.notes:
        return 'Notes';
      case VaultItemType.pyq:
        return 'Previous Year Questions';
      case VaultItemType.handwritten:
        return 'Handwritten Notes';
      case VaultItemType.assignment:
        return 'Assignment';
      case VaultItemType.slides:
        return 'Slides';
      case VaultItemType.lab:
        return 'Lab Manual';
      case VaultItemType.other:
        return 'Other';
    }
  }
  
  String get icon {
    switch (this) {
      case VaultItemType.notes:
        return '📝';
      case VaultItemType.pyq:
        return '📋';
      case VaultItemType.handwritten:
        return '✍️';
      case VaultItemType.assignment:
        return '📄';
      case VaultItemType.slides:
        return '📊';
      case VaultItemType.lab:
        return '🔬';
      case VaultItemType.other:
        return '📁';
    }
  }
  
  /// Material icon for premium UI
  IconData get iconData {
    switch (this) {
      case VaultItemType.notes:
        return Icons.description_rounded;
      case VaultItemType.pyq:
        return Icons.quiz_rounded;
      case VaultItemType.handwritten:
        return Icons.draw_rounded;
      case VaultItemType.assignment:
        return Icons.assignment_rounded;
      case VaultItemType.slides:
        return Icons.slideshow_rounded;
      case VaultItemType.lab:
        return Icons.science_rounded;
      case VaultItemType.other:
        return Icons.folder_rounded;
    }
  }
}

/// Academic resource in The Vault
class VaultItem {
  final String id;
  final String uploaderId;
  final String uploaderName;
  final String title;
  final String description;
  final String fileUrl;
  final String fileName;
  final int fileSizeBytes;
  final VaultItemType type;
  final String subject;
  final String branch;  // CSE, ECE, ME, etc.
  final int year;  // 1, 2, 3, 4
  final int semester;  // 1, 2
  final int downloadCount;
  final double rating;
  final bool isApproved;
  final DateTime createdAt;
  final List<String> tags;

  VaultItem({
    required this.id,
    required this.uploaderId,
    required this.uploaderName,
    required this.title,
    this.description = '',
    required this.fileUrl,
    required this.fileName,
    required this.fileSizeBytes,
    required this.type,
    required this.subject,
    required this.branch,
    required this.year,
    required this.semester,
    this.downloadCount = 0,
    this.rating = 0.0,
    this.isApproved = false,
    required this.createdAt,
    this.tags = const [],
  });

  factory VaultItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VaultItem(
      id: doc.id,
      uploaderId: data['uploaderId'] ?? '',
      uploaderName: data['uploaderName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileName: data['fileName'] ?? '',
      fileSizeBytes: data['fileSizeBytes'] ?? 0,
      type: VaultItemType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => VaultItemType.other,
      ),
      subject: data['subject'] ?? '',
      branch: data['branch'] ?? '',
      year: data['year'] ?? 1,
      semester: data['semester'] ?? 1,
      downloadCount: data['downloadCount'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      isApproved: data['isApproved'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'type': type.name,
      'subject': subject,
      'branch': branch,
      'year': year,
      'semester': semester,
      'downloadCount': downloadCount,
      'rating': rating,
      'isApproved': isApproved,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
    };
  }

  VaultItem copyWith({
    String? id,
    String? uploaderId,
    String? uploaderName,
    String? title,
    String? description,
    String? fileUrl,
    String? fileName,
    int? fileSizeBytes,
    VaultItemType? type,
    String? subject,
    String? branch,
    int? year,
    int? semester,
    int? downloadCount,
    double? rating,
    bool? isApproved,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return VaultItem(
      id: id ?? this.id,
      uploaderId: uploaderId ?? this.uploaderId,
      uploaderName: uploaderName ?? this.uploaderName,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      downloadCount: downloadCount ?? this.downloadCount,
      rating: rating ?? this.rating,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  /// Format file size for display
  String get formattedSize {
    if (fileSizeBytes >= 1048576) {
      return '${(fileSizeBytes / 1048576).toStringAsFixed(2)} MB';
    } else if (fileSizeBytes >= 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(2)} KB';
    }
    return '$fileSizeBytes B';
  }

  /// Get file extension
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : 'FILE';
  }

  /// Test vault items
  static List<VaultItem> get testItems => [
    VaultItem(
      id: 'vault_001',
      uploaderId: 'test_student_001',
      uploaderName: 'Test Student',
      title: 'Data Structures Complete Notes',
      description: 'Comprehensive notes covering all DSA topics for 2nd year CSE',
      fileUrl: 'https://example.com/file1.pdf',
      fileName: 'dsa_notes.pdf',
      fileSizeBytes: 5242880,
      type: VaultItemType.notes,
      subject: 'Data Structures',
      branch: 'CSE',
      year: 2,
      semester: 1,
      downloadCount: 156,
      rating: 4.5,
      isApproved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      tags: ['dsa', 'algorithms', 'trees', 'graphs'],
    ),
    VaultItem(
      id: 'vault_002',
      uploaderId: 'user_002',
      uploaderName: 'John Doe',
      title: 'DBMS PYQ 2020-2024',
      description: 'Previous year question papers with solutions',
      fileUrl: 'https://example.com/file2.pdf',
      fileName: 'dbms_pyq.pdf',
      fileSizeBytes: 3145728,
      type: VaultItemType.pyq,
      subject: 'Database Management',
      branch: 'CSE',
      year: 3,
      semester: 1,
      downloadCount: 89,
      rating: 4.8,
      isApproved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];
}

/// Branches available (customize for your college)
class Branches {
  static const List<String> all = [
    'CSE',
    'ECE',
    'EEE',
    'ME',
    'CE',
    'IT',
    'CSE-AI',
    'CSE-DS',
  ];
  
  static const Map<String, String> fullNames = {
    'CSE': 'Computer Science & Engineering',
    'ECE': 'Electronics & Communication',
    'EEE': 'Electrical & Electronics',
    'ME': 'Mechanical Engineering',
    'CE': 'Civil Engineering',
    'IT': 'Information Technology',
    'CSE-AI': 'CSE (AI & ML)',
    'CSE-DS': 'CSE (Data Science)',
  };
}
