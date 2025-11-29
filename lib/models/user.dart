import 'dart:convert';

class User {
  final String id;
  final String fullName;
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
  final String userType; // 'admin', 'editor', 'member', 'HEAD'
  final String status; // 'active', 'inactive', 'pending', 'ACTIVE'
  final String? mobileVerification; // 'ACCEPTED', 'PENDING', 'REJECTED'
  final String? emailVerification; // 'ACCEPTED', 'PENDING', 'REJECTED'
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
    this.userType = 'member',
    this.status = 'active',
    this.mobileVerification,
    this.emailVerification,
    this.familyId,
    this.refId,
    this.education,
  });

  // Helper getter to check if phone is verified
  bool get isPhoneVerified {
    return mobileVerification?.toUpperCase() == 'ACCEPTED';
  }

  // Helper getter to check if email is verified
  bool get isEmailVerified {
    return emailVerification?.toUpperCase() == 'ACCEPTED';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle date parsing safely
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      try {
        if (dateValue is String) {
          // Handle DD/MM/YYYY format from API
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
          // Try ISO format
          return DateTime.parse(dateValue);
        } else if (dateValue is DateTime) {
          return dateValue;
        }
      } catch (e) {
        print('Error parsing date: $e');
        return null;
      }
      return null;
    }

    // Combine firstName and lastName if they exist
    String getFullName() {
      final firstName = json['firstName']?.toString() ?? '';
      final lastName = json['lastName']?.toString() ?? '';
      
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      } else if (firstName.isNotEmpty) {
        return firstName;
      } else if (lastName.isNotEmpty) {
        return lastName;
      }
      
      // Fallback to other field names
      return json['fullName']?.toString() ?? 
             json['name']?.toString() ?? 
             '';
    }

    // Determine if user is head of family
    bool getIsHeadOfFamily() {
      // Check explicit field first
      if (json['isHeadOfFamily'] != null) {
        return json['isHeadOfFamily'] as bool;
      }
      if (json['is_head_of_family'] != null) {
        return json['is_head_of_family'] as bool;
      }
      
      // Check if userType is HEAD
      final userType = json['userType']?.toString()?.toUpperCase() ?? 
                      json['user_type']?.toString()?.toUpperCase() ?? '';
      
      return userType == 'HEAD';
    }

    return User(
      id: json['id']?.toString() ?? 
          json['_id']?.toString() ?? 
          '',
      fullName: getFullName(),
      phoneNumber: json['phoneNumber']?.toString() ?? 
                   json['mobile']?.toString() ?? 
                   json['phone']?.toString() ?? 
                   '',
      email: json['email']?.toString(),
      profileImage: json['profileImage']?.toString() ?? 
                    json['profile_image']?.toString() ??
                    json['profile']?.toString() ??
                    json['avatar']?.toString(),
      pin: json['pin']?.toString() ?? json['password']?.toString(),
      isHeadOfFamily: getIsHeadOfFamily(),
      relation: json['relation']?.toString(),
      society: json['society']?.toString() ?? 
               json['societyName']?.toString(),
      area: json['area']?.toString(),
      address: json['address']?.toString(),
      nativePlace: json['nativePlace']?.toString() ?? 
                   json['native_place']?.toString(),
      occupation: json['occupation']?.toString(),
      occupationAddress: json['occupationAddress']?.toString() ?? 
                         json['occupation_address']?.toString(),
      dateOfBirth: parseDate(json['dateOfBirth'] ?? json['date_of_birth'] ?? json['dob']),
      userType: json['userType']?.toString() ?? 
                json['user_type']?.toString() ?? 
                'member',
      status: json['status']?.toString() ?? 'active',
      mobileVerification: json['mobileVerification']?.toString() ??
                         json['mobile_verification']?.toString(),
      emailVerification: json['emailVerification']?.toString() ??
                        json['email_verification']?.toString(),
      familyId: json['familyId']?.toString() ?? json['family_id']?.toString(),
      refId: json['refId']?.toString() ?? json['ref_id']?.toString(),
      education: json['education']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImage': profileImage,
      'pin': pin,
      'isHeadOfFamily': isHeadOfFamily,
      'relation': relation,
      'society': society,
      'area': area,
      'address': address,
      'nativePlace': nativePlace,
      'occupation': occupation,
      'occupationAddress': occupationAddress,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'userType': userType,
      'status': status,
      'mobileVerification': mobileVerification,
      'emailVerification': emailVerification,
      'familyId': familyId,
      'refId': refId,
      'education': education,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static User fromJsonString(String jsonString) =>
      User.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

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
}