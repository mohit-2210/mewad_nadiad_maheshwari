import 'package:dio/dio.dart';
import 'package:mmsn/app/Dio/dio_client.dart';
import 'package:mmsn/models/family.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/app/globals/api_endpoint.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';

class FamilyApiService {
  static final FamilyApiService instance = FamilyApiService._internal();
  final Dio _dio = DioClient.instance;

  FamilyApiService._internal();

  // ==================== FAMILY METHODS ====================

  /// Get all families
  Future<List<Family>> getFamilies() async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();

      final response = await _dio.get(
        familyWiseEndpoint,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;

        if (jsonData['status'] == true && jsonData['data'] != null) {
          final List<dynamic> familiesData = jsonData['data'];

          // Filter out entries without familyId (standalone users) or without head
          final validFamilies = familiesData
              .where((item) =>
                  item['familyId'] != null &&
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

  /// Get family by ID
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

  /// Get family by head ID
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

  /// Get family by member ID
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

  /// Get families grouped by society
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

  // ==================== USER EXTRACTION METHODS ====================

  /// Get all heads (family heads only)
  Future<List<User>> getAllHeads() async {
    try {
      print('📋 Fetching all family heads...');
      final families = await getFamilies();

      final heads = families.map((family) {
        // Convert FamilyHead to User using the toUserJson method
        return User.fromJson(family.head.toUserJson());
      }).toList();

      print('✅ Found ${heads.length} family heads');
      return heads;
    } catch (e) {
      print('❌ Error fetching all heads: $e');
      rethrow;
    }
  }

  /// Get all members (including heads)
  /// This returns every person in the system
  Future<List<User>> getAllMembers() async {
    try {
      print('📋 Fetching all members (including heads)...');
      final families = await getFamilies();
      final List<User> allMembers = [];

      for (final family in families) {
        // Add head
        allMembers.add(User.fromJson(family.head.toUserJson()));

        // Add all family members
        for (final member in family.members) {
          allMembers.add(User.fromJson(member.toUserJson()));
        }
      }

      // Remove duplicates based on user ID
      final uniqueMembers = <String, User>{};
      for (final member in allMembers) {
        if (member.id.isNotEmpty) {
          uniqueMembers[member.id] = member;
        }
      }

      final result = uniqueMembers.values.toList();
      print('✅ Found ${result.length} total members (including heads)');
      return result;
    } catch (e) {
      print('❌ Error fetching all members: $e');
      rethrow;
    }
  }

  /// Get all members from specific societies
  /// Returns all people (heads + members) who live in the specified societies
  Future<List<User>> getMembersBySocieties(List<String> societyNames) async {
    try {
      if (societyNames.isEmpty) {
        print('⚠️ No societies specified');
        return [];
      }

      print('📋 Fetching members from societies: $societyNames');
      final families = await getFamilies();
      final List<User> societyMembers = [];

      // Filter families by society
      final filteredFamilies = families.where((family) {
        return societyNames.contains(family.society);
      }).toList();

      print(
          '📊 Found ${filteredFamilies.length} families in selected societies');

      // Extract all members from filtered families
      for (final family in filteredFamilies) {
        // Add head
        societyMembers.add(User.fromJson(family.head.toUserJson()));

        // Add all family members
        for (final member in family.members) {
          societyMembers.add(User.fromJson(member.toUserJson()));
        }
      }

      // Remove duplicates
      final uniqueMembers = <String, User>{};
      for (final member in societyMembers) {
        if (member.id.isNotEmpty) {
          uniqueMembers[member.id] = member;
        }
      }

      final result = uniqueMembers.values.toList();
      print('✅ Found ${result.length} members in selected societies');
      return result;
    } catch (e) {
      print('❌ Error fetching members by societies: $e');
      rethrow;
    }
  }

  /// Get only heads from specific societies
  Future<List<User>> getHeadsBySocieties(List<String> societyNames) async {
    try {
      if (societyNames.isEmpty) {
        print('⚠️ No societies specified');
        return [];
      }

      print('📋 Fetching heads from societies: $societyNames');
      final families = await getFamilies();

      // Filter families by society and extract heads
      final heads = families
          .where((family) => societyNames.contains(family.society))
          .map((family) => User.fromJson(family.head.toUserJson()))
          .toList();

      print('✅ Found ${heads.length} heads in selected societies');
      return heads;
    } catch (e) {
      print('❌ Error fetching heads by societies: $e');
      rethrow;
    }
  }

  /// Get non-head members from specific societies
  /// Returns only family members (excluding heads) from specified societies
  Future<List<User>> getNonHeadMembersBySocieties(
      List<String> societyNames) async {
    try {
      if (societyNames.isEmpty) {
        print('⚠️ No societies specified');
        return [];
      }

      print('📋 Fetching non-head members from societies: $societyNames');
      final families = await getFamilies();
      final List<User> nonHeadMembers = [];

      // Filter families by society
      final filteredFamilies = families.where((family) {
        return societyNames.contains(family.society);
      }).toList();

      // Extract only non-head members
      for (final family in filteredFamilies) {
        for (final member in family.members) {
          nonHeadMembers.add(User.fromJson(member.toUserJson()));
        }
      }

      // Remove duplicates
      final uniqueMembers = <String, User>{};
      for (final member in nonHeadMembers) {
        if (member.id.isNotEmpty) {
          uniqueMembers[member.id] = member;
        }
      }

      final result = uniqueMembers.values.toList();
      print('✅ Found ${result.length} non-head members in selected societies');
      return result;
    } catch (e) {
      print('❌ Error fetching non-head members by societies: $e');
      rethrow;
    }
  }

  // ==================== STATISTICS METHODS ====================

  /// Get total count of families
  Future<int> getFamilyCount() async {
    try {
      final families = await getFamilies();
      return families.length;
    } catch (e) {
      print('Error getting family count: $e');
      return 0;
    }
  }

  /// Get total count of all members (including heads)
  Future<int> getTotalMemberCount() async {
    try {
      final members = await getAllMembers();
      return members.length;
    } catch (e) {
      print('Error getting total member count: $e');
      return 0;
    }
  }

  /// Get member count by society
  Future<Map<String, int>> getMemberCountBySociety() async {
    try {
      final families = await getFamilies();
      final Map<String, int> counts = {};

      for (final family in families) {
        final society = family.society;
        final memberCount = 1 + family.members.length; // 1 for head + members
        counts[society] = (counts[society] ?? 0) + memberCount;
      }

      return counts;
    } catch (e) {
      print('Error getting member count by society: $e');
      return {};
    }
  }

  /// Get family count by society
  Future<Map<String, int>> getFamilyCountBySociety() async {
    try {
      final families = await getFamilies();
      final Map<String, int> counts = {};

      for (final family in families) {
        final society = family.society;
        counts[society] = (counts[society] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Error getting family count by society: $e');
      return {};
    }
  }
}
