class User {
  final int id;
  final String phone;
  final String? email;
  final String firstName;
  final String lastName;
  final String? profilePic;
  final String language;
  final String status;
  final int totalRides;
  final double totalSpent;
  final double ratingAvg;
  final double walletBalance;
  final String? homeAddress;
  final String? workAddress;

  User({
    required this.id,
    required this.phone,
    this.email,
    required this.firstName,
    required this.lastName,
    this.profilePic,
    this.language = 'en',
    this.status = 'active',
    this.totalRides = 0,
    this.totalSpent = 0.0,
    this.ratingAvg = 5.0,
    this.walletBalance = 0.0,
    this.homeAddress,
    this.workAddress,
  });

  String get fullName => '$firstName $lastName';

  String get formattedBalance => 'KES ${walletBalance.toStringAsFixed(2)}';

  String get formattedTotalSpent => 'KES ${totalSpent.toStringAsFixed(2)}';

  String get displayName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName ${lastName[0]}.'; // Returns "John D."
    }
    return fullName;
  }

  String get initials {
    String first = firstName.isNotEmpty ? firstName[0] : '';
    String last = lastName.isNotEmpty ? lastName[0] : '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '$first$last';
    }
    return first.isNotEmpty ? first : 'U';
  }

  bool get isActive => status == 'active';

  bool get hasHomeAddress => homeAddress != null && homeAddress!.isNotEmpty;

  bool get hasWorkAddress => workAddress != null && workAddress!.isNotEmpty;

  User copyWith({
    int? id,
    String? phone,
    String? email,
    String? firstName,
    String? lastName,
    String? profilePic,
    String? language,
    String? status,
    int? totalRides,
    double? totalSpent,
    double? ratingAvg,
    double? walletBalance,
    String? homeAddress,
    String? workAddress,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePic: profilePic ?? this.profilePic,
      language: language ?? this.language,
      status: status ?? this.status,
      totalRides: totalRides ?? this.totalRides,
      totalSpent: totalSpent ?? this.totalSpent,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      walletBalance: walletBalance ?? this.walletBalance,
      homeAddress: homeAddress ?? this.homeAddress,
      workAddress: workAddress ?? this.workAddress,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper function for safe double conversion
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Helper function for safe int conversion
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    return User(
      id: _toInt(json['id']),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      profilePic: json['profile_pic']?.toString(),
      language: json['language']?.toString() ?? 'en',
      status: json['status']?.toString() ?? 'active',
      totalRides: _toInt(json['total_rides']),
      totalSpent: _toDouble(json['total_spent']),
      ratingAvg: _toDouble(json['rating_avg']),
      walletBalance: _toDouble(json['wallet_balance']),
      homeAddress: json['home_address']?.toString(),
      workAddress: json['work_address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_pic': profilePic,
      'language': language,
      'status': status,
      'total_rides': totalRides,
      'total_spent': totalSpent,
      'rating_avg': ratingAvg,
      'wallet_balance': walletBalance,
      'home_address': homeAddress,
      'work_address': workAddress,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, phone: $phone, email: $email)';
  }
}