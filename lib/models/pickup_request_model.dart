import 'waste_category_model.dart';

/// Enum representing pickup status
enum PickupStatus {
  pending,
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
    return this == PickupStatus.accepted ||
        this == PickupStatus.onTheWay ||
        this == PickupStatus.reached ||
        this == PickupStatus.pickedUp;
  }

  /// UPPER_SNAKE_CASE value used by the backend / Firestore
  String get firestoreValue {
    switch (this) {
      case PickupStatus.pending:
        return 'PENDING';
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
      userName: json['userName'] ?? '',
      userAddress: json['userAddress'] ?? '',
      userPhone: json['userPhone'] ?? '',
      userLatitude: (json['userLatitude'] ?? 0.0).toDouble(),
      userLongitude: (json['userLongitude'] ?? 0.0).toDouble(),
      category: WasteCategory.values[json['category'] ?? 0],
      estimatedWeight: (json['estimatedWeight'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      paymentAmount: (json['paymentAmount'] ?? 0.0).toDouble(),
      pickupTimeStart: DateTime.parse(
        json['pickupTimeStart'] ?? DateTime.now().toIso8601String(),
      ),
      pickupTimeEnd: DateTime.parse(
        json['pickupTimeEnd'] ?? DateTime.now().toIso8601String(),
      ),
      status: _statusFromString(json['status']),
      proofPhotoUrl: json['proofPhotoUrl'],
      userRating: json['userRating']?.toDouble(),
      userReview: json['userReview'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
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
      'category': category.index,
      'estimatedWeight': estimatedWeight,
      'distance': distance,
      'paymentAmount': paymentAmount,
      'pickupTimeStart': pickupTimeStart.toIso8601String(),
      'pickupTimeEnd': pickupTimeEnd.toIso8601String(),
      'status': _statusToString(status),
      'proofPhotoUrl': proofPhotoUrl,
      'userRating': userRating,
      'userReview': userReview,
      'createdAt': createdAt.toIso8601String(),
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
    );
  }
}
