import 'dart:convert';

class User {
  final String id;
  final String fullName; // Internal field name, but maps to 'name' in API
  final String phoneNumber;
  final String? email;
  final String? profileImage;
  final String? pin;
  final bool isHeadOfFamily;
  final String? relation;
  final String? society;
  final String? area;
  final String? address;
  final String? nativePlace;
  final String? occupation;
  final String? occupationAddress;
  final DateTime? dateOfBirth;
  final String userType;
  final String status;
  final String? mobileVerification;
  final String? emailVerification;
  final String? familyId;
  final String? refId;
  final String? education;

  const User({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.profileImage,
    this.pin,
    this.isHeadOfFamily = false,
    this.relation,
    this.society,
    this.area,
    this.address,
    this.nativePlace,
    this.occupation,
    this.occupationAddress,
    this.dateOfBirth,
    this.userType = 'MEMBER',
    this.status = 'ACTIVE',
    this.mobileVerification,
    this.emailVerification,
    this.familyId,
    this.refId,
    this.education,
  });

  bool get isPhoneVerified => mobileVerification?.toUpperCase() == 'ACCEPTED';
  bool get isEmailVerified => emailVerification?.toUpperCase() == 'ACCEPTED';

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      try {
        if (dateValue is String) {
          if (dateValue.contains('/')) {
            final parts = dateValue.split('/');
            if (parts.length == 3) {
              final day = int.tryParse(parts[0]);
              final month = int.tryParse(parts[1]);
              final year = int.tryParse(parts[2]);
              if (day != null && month != null && year != null) {
                return DateTime(year, month, day);
              }
            }
          }
          return DateTime.parse(dateValue);
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
      return null;
    }

    // Simply get the name - API uses 'name', that's it
    final name = json['name']?.toString() ?? '';
    
    if (name.isEmpty) {
      print('⚠ WARNING: Empty name in User.fromJson');
      print('Available keys: ${json.keys.toList()}');
      print('JSON data: $json');
    }

    bool getIsHeadOfFamily() {
      // Check if explicitly set (for local data)
      if (json['isHeadOfFamily'] != null) {
        return json['isHeadOfFamily'] == true;
      }
      // Check userType (for API data)
      final userType = json['userType']?.toString().toUpperCase() ?? '';
      return userType == 'HEAD' || userType == 'HEAD_ADMIN';
    }

    return User(
      id: json['id']?.toString() ?? '',
      fullName: name.isNotEmpty ? name : 'Unknown',
      phoneNumber:
          json['mobile']?.toString() ?? json['phoneNumber']?.toString() ?? '',
      email: json['email']?.toString(),
      profileImage:
          json['profile']?.toString() ?? json['profileImage']?.toString(),
      pin: json['password']?.toString(),
      isHeadOfFamily: getIsHeadOfFamily(),
      relation: json['relation']?.toString(),
      society: json['societyName']?.toString() ?? json['society']?.toString(),
      area: json['area']?.toString(),
      address: json['address']?.toString(),
      nativePlace: json['nativePlace']?.toString(),
      occupation: json['occupation']?.toString(),
      occupationAddress: json['occupationAddress']?.toString(),
      dateOfBirth: parseDate(json['dob'] ?? json['dateOfBirth']),
      userType: json['userType']?.toString() ?? 'MEMBER',
      status: json['status']?.toString() ?? 'ACTIVE',
      mobileVerification: json['mobileVerification']?.toString(),
      emailVerification: json['emailVerification']?.toString(),
      familyId: json['familyId']?.toString(),
      refId: json['refId']?.toString(),
      education: json['education']?.toString(),
    );
  }

  // IMPORTANT: Format for API updates (using API field names)
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': fullName,
      'mobile': phoneNumber,
      if (email != null) 'email': email,
      if (profileImage != null) 'profile': profileImage,
      if (relation != null && !isHeadOfFamily) 'relation': relation,
      if (address != null) 'address': address,
      if (nativePlace != null) 'nativePlace': nativePlace,
      if (occupation != null) 'occupation': occupation,
      if (occupationAddress != null) 'occupationAddress': occupationAddress,
      if (dateOfBirth != null)
        'dob': '${dateOfBirth!.day.toString().padLeft(2, '0')}/'
            '${dateOfBirth!.month.toString().padLeft(2, '0')}/'
            '${dateOfBirth!.year}',
      if (education != null) 'education': education,
    };
  }

  // For local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': fullName,  // API expects 'name'
      'mobile': phoneNumber,
      'email': email,
      'profile': profileImage,
      'password': pin,
      'isHeadOfFamily': isHeadOfFamily,
      'relation': relation,
      'societyName': society,
      'area': area,
      'address': address,
      'nativePlace': nativePlace,
      'occupation': occupation,
      'occupationAddress': occupationAddress,
      'dob': dateOfBirth != null
          ? '${dateOfBirth!.day.toString().padLeft(2, '0')}/'
              '${dateOfBirth!.month.toString().padLeft(2, '0')}/'
              '${dateOfBirth!.year}'
          : null,
      'userType': userType,
      'status': status,
      'mobileVerification': mobileVerification,
      'emailVerification': emailVerification,
      'familyId': familyId,
      'refId': refId,
      'education': education,
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? profileImage,
    String? pin,
    bool? isHeadOfFamily,
    String? relation,
    String? society,
    String? area,
    String? address,
    String? nativePlace,
    String? occupation,
    String? occupationAddress,
    DateTime? dateOfBirth,
    String? userType,
    String? status,
    String? mobileVerification,
    String? emailVerification,
    String? familyId,
    String? refId,
    String? education,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      pin: pin ?? this.pin,
      isHeadOfFamily: isHeadOfFamily ?? this.isHeadOfFamily,
      relation: relation ?? this.relation,
      society: society ?? this.society,
      area: area ?? this.area,
      address: address ?? this.address,
      nativePlace: nativePlace ?? this.nativePlace,
      occupation: occupation ?? this.occupation,
      occupationAddress: occupationAddress ?? this.occupationAddress,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      mobileVerification: mobileVerification ?? this.mobileVerification,
      emailVerification: emailVerification ?? this.emailVerification,
      familyId: familyId ?? this.familyId,
      refId: refId ?? this.refId,
      education: education ?? this.education,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  static User fromJsonString(String jsonString) =>
      User.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
} 