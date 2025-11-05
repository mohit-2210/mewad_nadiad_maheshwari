// class User {
//   const User({
//     required this.id,
//     required this.fullName,
//     required this.phoneNumber,
//     required this.pin,
//     this.profileImage,
//     this.isHeadOfFamily = false,
//     this.relation,
//     this.society,
//     this.area,
//     this.address,
//     this.nativePlace,
//     this.occupation,
//     this.occupationAddress,
//     this.dateOfBirth,
//     this.email,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'] as String,
//       fullName: json['fullName'] as String,
//       phoneNumber: json['phoneNumber'] as String,
//       pin: json['pin'] as String,
//       profileImage: json['profileImage'] as String?,
//       isHeadOfFamily: json['isHeadOfFamily'] as bool? ?? false,
//       relation: json['relation'] as String?,
//       society: json['society'] as String?,
//       area: json['area'] as String?,
//       address: json['address'] as String?,
//       nativePlace: json['nativePlace'] as String?,
//       occupation: json['occupation'] as String?,
//       occupationAddress: json['occupationAddress'] as String?,
//       dateOfBirth: json['dateOfBirth'] != null
//           ? DateTime.parse(json['dateOfBirth'] as String)
//           : null,
//       email: json['email'] as String?,
//     );
//   }

//   final String id;

//   final String fullName;

//   final String phoneNumber;

//   final String pin;

//   final String? profileImage;

//   final bool isHeadOfFamily;

//   final String? relation;

//   final String? society;

//   final String? area;

//   final String? address;

//   final String? nativePlace;

//   final String? occupation;
//   final String? occupationAddress;

//   final DateTime? dateOfBirth;

//   final String? email;

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'fullName': fullName,
//       'phoneNumber': phoneNumber,
//       'pin': pin,
//       'profileImage': profileImage,
//       'isHeadOfFamily': isHeadOfFamily,
//       'relation': relation,
//       'society': society,
//       'area': area,
//       'address': address,
//       'nativePlace': nativePlace,
//       'occupation': occupation,
//       'occupationAddress':occupationAddress,
//       'dateOfBirth': dateOfBirth?.toIso8601String(),
//       'email': email,
//     };
//   }

//   User copyWith({
//     String? id,
//     String? fullName,
//     String? phoneNumber,
//     String? pin,
//     String? profileImage,
//     bool? isHeadOfFamily,
//     String? relation,
//     String? society,
//     String? area,
//     String? address,
//     String? nativePlace,
//     String? occupation,
//     String? occupationAddress,
//     DateTime? dateOfBirth,
//     String? email,
//   }) {
//     return User(
//       id: id ?? this.id,
//       fullName: fullName ?? this.fullName,
//       phoneNumber: phoneNumber ?? this.phoneNumber,
//       pin: pin ?? this.pin,
//       profileImage: profileImage ?? this.profileImage,
//       isHeadOfFamily: isHeadOfFamily ?? this.isHeadOfFamily,
//       relation: relation ?? this.relation,
//       society: society ?? this.society,
//       area: area ?? this.area,
//       address: address ?? this.address,
//       nativePlace: nativePlace ?? this.nativePlace,
//       occupation: occupation ?? this.occupation,
//       occupationAddress: occupationAddress ?? this.occupationAddress,
//       dateOfBirth: dateOfBirth ?? this.dateOfBirth,
//       email: email ?? this.email,
//     );
//   }
// }

import 'dart:convert';

class UserModel {
  final String id;
  final String? firstName;
  final String? email;
  final String? mobile;
  final String? userType;
  final String? status;
  // add other fields you need from backend

  UserModel({
    required this.id,
    this.firstName,
    this.email,
    this.mobile,
    this.userType,
    this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      userType: json['userType'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'email': email,
      'mobile': mobile,
      'userType': userType,
      'status': status,
    };
  }

  /// Optional helper if you prefer to store the JSON string directly
  String toJsonString() => jsonEncode(toJson());

  static UserModel fromJsonString(String jsonString) =>
      UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
