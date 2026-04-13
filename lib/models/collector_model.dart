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
      vehicleType: json['vehicleType'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      registrationDocUrl: json['registrationDocUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'registrationDocUrl': registrationDocUrl,
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
      accountNumber: json['accountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      bankName: json['bankName'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'accountHolderName': accountHolderName,
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
  final double totalEarnings;
  final String address;
  final String city;
  final String experience;
  final bool hasLicense;

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
    this.totalEarnings = 0.0,
    this.address = '',
    this.city = '',
    this.experience = '',
    this.hasLicense = false,
  });

  factory Collector.fromJson(Map<String, dynamic> json) {
    return Collector(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalPickups: json['jobsCompleted'] ?? 0, // Mapped to jobsCompleted
      totalHoursToday: (json['totalHoursToday'] ?? 0.0).toDouble(),
      isOnline: json['isOnline'] ?? false,
      vehicle: json['vehicle'] != null
          ? VehicleDetails.fromJson(json['vehicle'])
          : null,
      bankDetails: json['bankDetails'] != null
          ? BankDetails.fromJson(json['bankDetails'])
          : null,
      idProofUrl: json['idProofUrl'] ?? '',
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      experience: json['experience'] ?? '',
      hasLicense: json['has_license'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'rating': rating,
      'jobsCompleted': totalPickups, // Mapped to jobsCompleted
      'totalHoursToday': totalHoursToday,
      'isOnline': isOnline,
      'vehicle': vehicle?.toJson(),
      'bankDetails': bankDetails?.toJson(),
      'idProofUrl': idProofUrl,
      'totalEarnings': totalEarnings,
      'address': address,
      'city': city,
      'experience': experience,
      'has_license': hasLicense,
      'role': 'collector',
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
    double? totalEarnings,
    String? address,
    String? city,
    String? experience,
    bool? hasLicense,
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
      totalEarnings: totalEarnings ?? this.totalEarnings,
      address: address ?? this.address,
      city: city ?? this.city,
      experience: experience ?? this.experience,
      hasLicense: hasLicense ?? this.hasLicense,
    );
  }
}
