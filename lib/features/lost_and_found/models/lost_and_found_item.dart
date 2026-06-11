import 'package:flutter/material.dart';

/// Status lifecycle sebuah laporan Lost & Found
class ReportStatus {
  static const String diproses = 'DIPROSES';
  static const String dalamKlaim = 'DALAM KLAIM';
  static const String selesai = 'SELESAI';
  static const String batal = 'BATAL';

  static Color color(String status) {
    switch (status) {
      case diproses:
        return const Color(0xFFF59E0B); // Amber
      case dalamKlaim:
        return const Color(0xFF3B82F6); // Blue
      case selesai:
        return const Color(0xFF10B981); // Green
      case batal:
        return const Color(0xFF6B7280); // Grey
      default:
        return const Color(0xFFF59E0B);
    }
  }
}

class LostAndFoundItem {
  final String id;
  final String status;
  final String itemName;
  final String location;
  final String imageUrl;
  final String category;
  final String date;
  final String description;
  final String reporterName;
  final String reporterAvatar;
  final double reporterRating;
  final bool isLostReport;
  String reportStatus; // DIPROSES, DALAM KLAIM, SELESAI, BATAL
  final bool isCancelled;
  final bool isFoundCompleted;
  final Color backgroundColor;
  final Color statusColor;
  final String campusName;

  LostAndFoundItem({
    String? id,
    required this.status,
    required this.itemName,
    required this.location,
    required this.imageUrl,
    required this.category,
    required this.date,
    required this.description,
    required this.reporterName,
    required this.reporterAvatar,
    required this.reporterRating,
    required this.isLostReport,
    this.reportStatus = 'DIPROSES',
    this.isCancelled = false,
    this.isFoundCompleted = false,
    this.backgroundColor = Colors.white,
    required this.statusColor,
    this.campusName = 'Bandung',
  }) : id = id ?? UniqueKey().toString();

  /// Warna dari reportStatus
  Color get reportStatusColor => ReportStatus.color(reportStatus);

  /// Apakah laporan masih aktif (belum selesai/batal)
  bool get isActive =>
      reportStatus != ReportStatus.selesai &&
      reportStatus != ReportStatus.batal;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'itemName': itemName,
      'location': location,
      'imageUrl': imageUrl,
      'category': category,
      'date': date,
      'description': description,
      'reporterName': reporterName,
      'reporterAvatar': reporterAvatar,
      'reporterRating': reporterRating,
      'isLostReport': isLostReport,
      'reportStatus': reportStatus,
      'isCancelled': isCancelled,
      'isFoundCompleted': isFoundCompleted,
      'backgroundColor': backgroundColor,
      'statusColor': statusColor,
      'campusName': campusName,
    };
  }

  factory LostAndFoundItem.fromMap(Map<String, dynamic> map) {
    return LostAndFoundItem(
      id: map['id'],
      status: map['status'] ?? '',
      itemName: map['itemName'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      reporterName: map['reporterName'] ?? 'Anonim',
      reporterAvatar: map['reporterAvatar'] ?? '',
      reporterRating: (map['reporterRating'] as num?)?.toDouble() ?? 0.0,
      isLostReport: map['isLostReport'] ?? true,
      reportStatus: map['reportStatus'] ?? 'DIPROSES',
      isCancelled: map['isCancelled'] ?? false,
      isFoundCompleted: map['isFoundCompleted'] ?? false,
      backgroundColor: map['backgroundColor'] ?? Colors.white,
      statusColor: map['statusColor'] ?? Colors.red,
      campusName: map['campusName'] ?? 'Bandung',
    );
  }
}
