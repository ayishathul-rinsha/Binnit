import 'package:cloud_firestore/cloud_firestore.dart';
import 'waste_category_model.dart';

/// Enum representing pickup status
enum PickupStatus {
  pending,
  assigned,
  accepted,
  onTheWay,
  reached,
  pickedUp,
  completed,
  cancelled,
}

extension PickupStatusExtension on PickupStatus {
  String get displayName {
    switch (this) {
      case PickupStatus.pending:
        return 'Pending';
      case PickupStatus.assigned:
        return 'Assigned';
      case PickupStatus.accepted:
        return 'Accepted';
      case PickupStatus.onTheWay:
        return 'On the Way';
      case PickupStatus.reached:
        return 'Reached';
      case PickupStatus.pickedUp:
        return 'Picked Up';
      case PickupStatus.completed:
        return 'Completed';
      case PickupStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive {
    return this == PickupStatus.assigned ||
        this == PickupStatus.accepted ||
        this == PickupStatus.onTheWay ||
        this == PickupStatus.reached ||
        this == PickupStatus.pickedUp;
  }

  /// UPPER_SNAKE_CASE value used by the backend / Firestore
  String get firestoreValue {
    switch (this) {
      case PickupStatus.pending:
        return 'PENDING';
      case PickupStatus.assigned:
        return 'ASSIGNED';
      case PickupStatus.accepted:
        return 'ACCEPTED';
      case PickupStatus.onTheWay:
        return 'ON_THE_WAY';
      case PickupStatus.reached:
        return 'REACHED';
      case PickupStatus.pickedUp:
        return 'PICKED_UP';
      case PickupStatus.completed:
        return 'COMPLETED';
      case PickupStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// Model for pickup request
class PickupRequest {
  final String id;
  final String userName;
  final String userAddress;
  final String userPhone;
  final double userLatitude;
  final double userLongitude;
  final WasteCategory category;
  final double estimatedWeight;
  final double distance;
  final double paymentAmount;
  final DateTime pickupTimeStart;
  final DateTime pickupTimeEnd;
  final PickupStatus status;
  final String? proofPhotoUrl;
  final double? userRating;
  final String? userReview;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? userId;
  final String? collectorId;
  final DateTime? assignedAt;

  PickupRequest({
    required this.id,
    required this.userName,
    required this.userAddress,
    required this.userPhone,
    required this.userLatitude,
    required this.userLongitude,
    required this.category,
    required this.estimatedWeight,
    required this.distance,
    required this.paymentAmount,
    required this.pickupTimeStart,
    required this.pickupTimeEnd,
    this.status = PickupStatus.pending,
    this.proofPhotoUrl,
    this.userRating,
    this.userReview,
    DateTime? createdAt,
    this.completedAt,
    this.userId,
    this.collectorId,
    this.assignedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert a backend status string to PickupStatus enum
  static PickupStatus _statusFromString(dynamic value) {
    if (value is int) {
      // Fallback for legacy integer status
      return PickupStatus.values[value];
    }
    final str = (value ?? 'PENDING').toString().toUpperCase();
    switch (str) {
      case 'PENDING':
        return PickupStatus.pending;
      case 'ASSIGNED':
        return PickupStatus.assigned;
      case 'ACCEPTED':
        return PickupStatus.accepted;
      case 'ON_THE_WAY':
        return PickupStatus.onTheWay;
      case 'REACHED':
        return PickupStatus.reached;
      case 'PICKED_UP':
        return PickupStatus.pickedUp;
      case 'COMPLETED':
        return PickupStatus.completed;
      case 'CANCELLED':
        return PickupStatus.cancelled;
      default:
        return PickupStatus.pending;
    }
  }

  /// Convert PickupStatus enum to UPPER_SNAKE_CASE string for Firestore
  static String _statusToString(PickupStatus status) {
    return status.firestoreValue;
  }

  factory PickupRequest.fromJson(Map<String, dynamic> json) {
    return PickupRequest(
      id: json['id'] ?? '',
      userName: json['userName'] ?? json['user_name'] ?? json['name'] ?? 'User',
      userAddress: json['userAddress'] ?? json['address'] ?? json['location'] ?? 'No Address Provided',
      userPhone: json['userPhone'] ?? json['phone'] ?? json['user_phone'] ?? '',
      userLatitude: (json['userLatitude'] ?? json['latitude'] ?? 0.0).toDouble(),
      userLongitude: (json['userLongitude'] ?? json['longitude'] ?? 0.0).toDouble(),
      category: json['type'] != null 
          ? WasteCategoryExtension.fromString(json['type'].toString())
          : (json['wasteTypes'] != null && (json['wasteTypes'] as List).isNotEmpty 
              ? WasteCategoryExtension.fromString((json['wasteTypes'] as List).first.toString()) 
              : WasteCategory.plastic),
      estimatedWeight: (json['weight'] ?? json['weightKg'] ?? json['estimatedWeight'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      paymentAmount: (json['earnings'] ?? json['amount'] ?? json['totalPrice'] ?? 0.0).toDouble(),
      pickupTimeStart: DateTime.tryParse(json['pickupTimeStart']?.toString() ?? '') ?? DateTime.now(),
      pickupTimeEnd: DateTime.tryParse(json['pickupTimeEnd']?.toString() ?? '') ?? DateTime.now(),
      status: _statusFromString(json['status']),
      proofPhotoUrl: json['proofPhotoUrl'],
      userRating: json['userRating']?.toDouble(),
      userReview: json['userReview'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : (DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now()),
      completedAt: json['completedAt'] is Timestamp
          ? (json['completedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['completedAt']?.toString() ?? ''),
      userId: json['userId'],
      collectorId: json['collectorId'],
      assignedAt: json['assignedAt'] is Timestamp
          ? (json['assignedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['assignedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userAddress': userAddress,
      'userPhone': userPhone,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'type': category.backendValue, // Mapped category -> type
      'weight': estimatedWeight,     // Mapped estimatedWeight -> weight
      'distance': distance,
      'earnings': paymentAmount,     // Mapped paymentAmount -> earnings
      'pickupTimeStart': pickupTimeStart.toIso8601String(),
      'pickupTimeEnd': pickupTimeEnd.toIso8601String(),
      'status': _statusToString(status),
      'proofPhotoUrl': proofPhotoUrl,
      'userRating': userRating,
      'userReview': userReview,
      'location': userAddress,       // Mapped userAddress -> location
      'createdAt': Timestamp.fromDate(createdAt),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  PickupRequest copyWith({
    String? id,
    String? userName,
    String? userAddress,
    String? userPhone,
    double? userLatitude,
    double? userLongitude,
    WasteCategory? category,
    double? estimatedWeight,
    double? distance,
    double? paymentAmount,
    DateTime? pickupTimeStart,
    DateTime? pickupTimeEnd,
    PickupStatus? status,
    String? proofPhotoUrl,
    double? userRating,
    String? userReview,
    DateTime? createdAt,
    DateTime? completedAt,
    String? userId,
    String? collectorId,
    DateTime? assignedAt,
  }) {
    return PickupRequest(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAddress: userAddress ?? this.userAddress,
      userPhone: userPhone ?? this.userPhone,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      category: category ?? this.category,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      distance: distance ?? this.distance,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      pickupTimeStart: pickupTimeStart ?? this.pickupTimeStart,
      pickupTimeEnd: pickupTimeEnd ?? this.pickupTimeEnd,
      status: status ?? this.status,
      proofPhotoUrl: proofPhotoUrl ?? this.proofPhotoUrl,
      userRating: userRating ?? this.userRating,
      userReview: userReview ?? this.userReview,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      userId: userId ?? this.userId,
      collectorId: collectorId ?? this.collectorId,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }
}
