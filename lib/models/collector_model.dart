/// Model for vehicle details
class VehicleDetails {
  final String id;
  final String vehicleType;
  final String vehicleNumber;
  final String registrationDocUrl;

  VehicleDetails({
    required this.id,
    required this.vehicleType,
    required this.vehicleNumber,
    this.registrationDocUrl = '',
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      id: json['id'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      registrationDocUrl: json['registration_doc_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'registration_doc_url': registrationDocUrl,
    };
  }
}

/// Model for bank details
class BankDetails {
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String accountHolderName;

  BankDetails({
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.accountHolderName,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      bankName: json['bank_name'] ?? '',
      accountHolderName: json['account_holder_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'bank_name': bankName,
      'account_holder_name': accountHolderName,
    };
  }
}

/// Model for waste collector
class Collector {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final double rating;
  final int totalPickups;
  final double totalHoursToday;
  final bool isOnline;
  final VehicleDetails? vehicle;
  final BankDetails? bankDetails;
  final String idProofUrl;

  Collector({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl = '',
    this.rating = 0.0,
    this.totalPickups = 0,
    this.totalHoursToday = 0.0,
    this.isOnline = false,
    this.vehicle,
    this.bankDetails,
    this.idProofUrl = '',
  });

  factory Collector.fromJson(Map<String, dynamic> json) {
    return Collector(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalPickups: json['total_pickups'] ?? 0,
      totalHoursToday: (json['total_hours_today'] ?? 0.0).toDouble(),
      isOnline: json['is_online'] ?? false,
      vehicle: json['vehicle'] != null
          ? VehicleDetails.fromJson(json['vehicle'])
          : null,
      bankDetails: json['bank_details'] != null
          ? BankDetails.fromJson(json['bank_details'])
          : null,
      idProofUrl: json['id_proof_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo_url': photoUrl,
      'rating': rating,
      'total_pickups': totalPickups,
      'total_hours_today': totalHoursToday,
      'is_online': isOnline,
      'vehicle': vehicle?.toJson(),
      'bank_details': bankDetails?.toJson(),
      'id_proof_url': idProofUrl,
    };
  }

  Collector copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    double? rating,
    int? totalPickups,
    double? totalHoursToday,
    bool? isOnline,
    VehicleDetails? vehicle,
    BankDetails? bankDetails,
    String? idProofUrl,
  }) {
    return Collector(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      totalPickups: totalPickups ?? this.totalPickups,
      totalHoursToday: totalHoursToday ?? this.totalHoursToday,
      isOnline: isOnline ?? this.isOnline,
      vehicle: vehicle ?? this.vehicle,
      bankDetails: bankDetails ?? this.bankDetails,
      idProofUrl: idProofUrl ?? this.idProofUrl,
    );
  }
}
