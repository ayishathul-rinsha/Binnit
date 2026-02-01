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

  factory PickupRequest.fromJson(Map<String, dynamic> json) {
    return PickupRequest(
      id: json['id'] ?? '',
      userName: json['user_name'] ?? '',
      userAddress: json['user_address'] ?? '',
      userPhone: json['user_phone'] ?? '',
      userLatitude: (json['user_latitude'] ?? 0.0).toDouble(),
      userLongitude: (json['user_longitude'] ?? 0.0).toDouble(),
      category: WasteCategory.values[json['category'] ?? 0],
      estimatedWeight: (json['estimated_weight'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      paymentAmount: (json['payment_amount'] ?? 0.0).toDouble(),
      pickupTimeStart: DateTime.parse(
        json['pickup_time_start'] ?? DateTime.now().toIso8601String(),
      ),
      pickupTimeEnd: DateTime.parse(
        json['pickup_time_end'] ?? DateTime.now().toIso8601String(),
      ),
      status: PickupStatus.values[json['status'] ?? 0],
      proofPhotoUrl: json['proof_photo_url'],
      userRating: json['user_rating']?.toDouble(),
      userReview: json['user_review'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_address': userAddress,
      'user_phone': userPhone,
      'user_latitude': userLatitude,
      'user_longitude': userLongitude,
      'category': category.index,
      'estimated_weight': estimatedWeight,
      'distance': distance,
      'payment_amount': paymentAmount,
      'pickup_time_start': pickupTimeStart.toIso8601String(),
      'pickup_time_end': pickupTimeEnd.toIso8601String(),
      'status': status.index,
      'proof_photo_url': proofPhotoUrl,
      'user_rating': userRating,
      'user_review': userReview,
      'created_at': createdAt.toIso8601String(),
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
