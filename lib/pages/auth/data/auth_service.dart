// import 'package:mmsn/models/user.dart';
// import 'package:nowa_runtime/nowa_runtime.dart';
// import 'package:mmsn/main.dart';

// @NowaGenerated()
// class AuthApiService {
//   AuthApiService._();

//   final List<User> _mockUsers = [
//     User(
//       id: '1',
//       fullName: 'John Smith',
//       phoneNumber: '1234567890',
//       pin: '1234',
//       profileImage:
//           'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
//       isHeadOfFamily: true,
//       society: 'Green Valley Society',
//       area: 'Block A',
//       address: 'Flat 401, Green Valley Apartments, Sector 12',
//       nativePlace: 'Mumbai, Maharashtra',
//       occupation: 'Software Engineer',
//       email: 'john.smith@email.com',
//       dateOfBirth: DateTime(1985, 5, 15),
//     ),
//     User(
//       id: '2',
//       fullName: 'Sarah Johnson',
//       phoneNumber: '9876543210',
//       pin: '5678',
//       profileImage:
//           'https://images.unsplash.com/photo-1494790108755-2616b842ca5e?w=400',
//       isHeadOfFamily: true,
//       society: 'Sunset Heights',
//       area: 'Block B',
//       address: 'Villa 15, Sunset Heights, Garden City',
//       nativePlace: 'Delhi, India',
//       occupation: 'Doctor',
//       email: 'sarah.johnson@email.com',
//       dateOfBirth: DateTime(1982, 11, 30),
//     ),
//   ];

//   User? _currentUser;

//   User? get currentUser {
//     return _currentUser;
//   }

//   static AuthApiService? _instance;

//   static AuthApiService get instance {
//     return _instance ??= AuthApiService._();
//   }

//   Future<bool> verifyOTP(String otp) async {
//     await Future.delayed(const Duration(milliseconds: 800));
//     return otp == '123456';
//   }

//   Future<bool> login(String phoneNumber, String pin) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     final user = _mockUsers.firstWhere(
//       (u) => u.phoneNumber == phoneNumber && u.pin == pin,
//       orElse: () => throw Exception('Invalid credentials'),
//     );
//     _currentUser = user;
//     try {
//       await sharedPrefs.setString('currentUserId', user.id);
//     } catch (e) {
//       print('SharedPreferences not available: ${e}');
//     }
//     return true;
//   }

//   Future<bool> register(String fullName, String phoneNumber, String pin) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     final newUser = User(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       fullName: fullName,
//       phoneNumber: phoneNumber,
//       pin: pin,
//       profileImage:
//           'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
//       isHeadOfFamily: true,
//       society: 'New Residents',
//       area: 'Block C',
//       address: 'New Resident Address',
//       nativePlace: 'To be updated',
//       occupation: 'To be updated',
//       email: 'user@email.com',
//       dateOfBirth: DateTime.now().subtract(const Duration(days: 10000)),
//     );
//     _mockUsers.add(newUser);
//     _currentUser = newUser;
//     try {
//       await sharedPrefs.setString('currentUserId', newUser.id);
//     } catch (e) {
//       print('SharedPreferences not available: ${e}');
//     }
//     return true;
//   }

//   Future<void> logout() async {
//     _currentUser = null;
//     try {
//       await sharedPrefs.remove('currentUserId');
//     } catch (e) {
//       print('SharedPreferences not available: ${e}');
//     }
//   }

//   Future<void> loadCurrentUser() async {
//     try {
//       final userId = sharedPrefs.getString('currentUserId');
//       if (userId != null) {
//         _currentUser = _mockUsers.firstWhere(
//           (u) => u.id == userId,
//           orElse: () => _mockUsers.first,
//         );
//       }
//     } catch (e) {
//       print('SharedPreferences not available: ${e}');
//       _currentUser = null;
//     }
//   }

//   Future<void> updateCurrentUser(User updatedUser) async {
//     _currentUser = updatedUser;
//     try {
//       await sharedPrefs.setString('currentUserId', updatedUser.id);
//     } catch (e) {
//       print('SharedPreferences not available: ${e}');
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:mmsn/app/Dio/dio_client.dart';
import 'package:mmsn/app/globals/api_endpoint.dart';

class AuthApiService {
  final Dio _dio = DioClient.instance;

  Future<Response> login(String mobile, String password) async {
    return await _dio.post(loginEndpoint, data: {
      "mobile": mobile,
      "password": password,
    });
  }

  Future<Response> sendOtp(String mobile) async {
    return await _dio.post(
      sendOtpEndpoint,
      data: {
        "mobile": mobile,
      },
    );
  }

  Future<Response> verifyOtp(String mobile, String otp) async {
    return await _dio.post("/auth/verify-otp", data: {
      "mobile": mobile,
      "otp": otp,
    });
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post(registerEndpoint, data: data,);
  }

  Future<Response> forgotPassword(String mobile) async {
    return await _dio.post("/auth/forgot-password", data: {"mobile": mobile,},);
  }
}
