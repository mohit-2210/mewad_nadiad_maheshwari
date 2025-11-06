// lib/models/user.dart
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
  final String userType; // 'admin', 'editor', 'member'
  final String status; // 'active', 'inactive', 'pending'

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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['_id'] as String,
      fullName: json['fullName'] as String? ?? json['firstName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? json['mobile'] as String? ?? '',
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
      pin: json['pin'] as String?,
      isHeadOfFamily: json['isHeadOfFamily'] as bool? ?? false,
      relation: json['relation'] as String?,
      society: json['society'] as String?,
      area: json['area'] as String?,
      address: json['address'] as String?,
      nativePlace: json['nativePlace'] as String?,
      occupation: json['occupation'] as String?,
      occupationAddress: json['occupationAddress'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      userType: json['userType'] as String? ?? 'member',
      status: json['status'] as String? ?? 'active',
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
    );
  }
}

// Keep TokenModel separate
class TokenModel {
  final String accessToken;
  final String refreshToken;

  TokenModel({required this.accessToken, required this.refreshToken});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json["tokens"]["accessToken"]["token"],
      refreshToken: json["tokens"]["refreshToken"]["token"],
    );
  }
}