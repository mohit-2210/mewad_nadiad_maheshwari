import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mmsn/models/family.dart';
import 'package:mmsn/app/globals/api_endpoint.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';

class FamilyApiService {
  static final FamilyApiService instance = FamilyApiService._internal();
  
  FamilyApiService._internal();

  Future<List<Family>> getFamilies() async {
    try {
      // Get auth token
      final token = await AuthLocalStorage.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl$familyWiseEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == true && jsonData['data'] != null) {
          final List<dynamic> familiesData = jsonData['data'];
          
          // Filter out entries without familyId (standalone users) or without head
          final validFamilies = familiesData
              .where((item) => item['familyId'] != null && 
                             item['familyId'].toString().isNotEmpty &&
                             item['head'] != null)
              .toList();
          
          return validFamilies.map((familyJson) {
            return Family.fromJson(familyJson);
          }).toList();
        }
        
        return [];
      } else {
        throw Exception('Failed to load families: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching families: $e');
      rethrow;
    }
  }

  Future<Family?> getFamilyById(String familyId) async {
    try {
      final families = await getFamilies();
      return families.firstWhere(
        (family) => family.id == familyId,
        orElse: () => throw Exception('Family not found'),
      );
    } catch (e) {
      print('Error fetching family by ID: $e');
      return null;
    }
  }

  Future<Family?> getFamilyByHeadId(String headId) async {
    try {
      final families = await getFamilies();
      return families.firstWhere(
        (family) => family.head.id == headId,
        orElse: () => throw Exception('Family not found'),
      );
    } catch (e) {
      print('Error fetching family by head ID: $e');
      return null;
    }
  }

  Future<Family?> getFamilyByMemberId(String memberId) async {
    try {
      final families = await getFamilies();
      for (final family in families) {
        if (family.head.id == memberId) {
          return family;
        }
        if (family.members.any((member) => member.id == memberId)) {
          return family;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching family by member ID: $e');
      return null;
    }
  }

  Future<Map<String, List<Family>>> getFamiliesBySociety() async {
    try {
      final families = await getFamilies();
      final Map<String, List<Family>> societyGroups = {};
      
      for (final family in families) {
        final society = family.society;
        if (!societyGroups.containsKey(society)) {
          societyGroups[society] = [];
        }
        societyGroups[society]!.add(family);
      }
      
      return societyGroups;
    } catch (e) {
      print('Error grouping families by society: $e');
      return {};
    }
  }
}