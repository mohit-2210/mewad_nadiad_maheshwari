class Family {
  final String id;
  final FamilyHead head;
  final List<FamilyMember> members;
  final String society;
  final String area;

  Family({
    required this.id,
    required this.head,
    required this.members,
    required this.society,
    required this.area,
  });

  // Getter for total members count (head + members)
  int get totalMembers => 1 + members.length;

  factory Family.fromJson(Map<String, dynamic> json) {
    // Parse head - handle null case for standalone users
    final headData = json['head'] as Map<String, dynamic>?;
    if (headData == null) {
      throw Exception('Family head cannot be null');
    }

    // Helper function to get full name from API response
    String getFullName(Map<String, dynamic> data) {
      final firstName = data['firstName']?.toString() ?? '';
      final lastName = data['lastName']?.toString() ?? '';
      final name = data['name']?.toString() ?? '';
      
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      } else if (firstName.isNotEmpty) {
        return firstName;
      } else if (name.isNotEmpty) {
        return name;
      }
      return '';
    }

    final head = FamilyHead(
      id: headData['id']?.toString() ?? '',
      fullName: getFullName(headData),
      phoneNumber: headData['mobile']?.toString() ?? '',
      nativePlace: headData['nativePlace']?.toString() ?? '',
      address: headData['address']?.toString() ?? '',
      profileImage: headData['profile']?.toString(),
      education: headData['education']?.toString(),
      dob: headData['dob']?.toString(),
    );

    // Parse family members - filter out the head from members list
    final membersData = json['familyMembers'] as List<dynamic>? ?? [];
    final headId = head.id;
    final members = membersData
        .where((memberJson) => memberJson['id']?.toString() != headId)
        .map((memberJson) {
      return FamilyMember(
        id: memberJson['id']?.toString() ?? '',
        name: getFullName(memberJson),
        relation: memberJson['relation']?.toString() ?? 'Member',
        phoneNumber: memberJson['mobile']?.toString() ?? '',
        education: memberJson['education']?.toString(),
        occupation: memberJson['occupation']?.toString(),
        dob: memberJson['dob']?.toString(),
        profileImage: memberJson['profile']?.toString(),
        nativePlace: memberJson['nativePlace']?.toString(),
        address: memberJson['address']?.toString(),
      );
    }).toList();

    // Get society name from head or first available member
    final society = headData['societyName']?.toString() ?? 'N/A';
    final area = headData['nativePlace']?.toString() ?? '';

    return Family(
      id: json['familyId']?.toString() ?? '',
      head: head,
      members: members,
      society: society,
      area: area,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'familyId': id,
      'head': head.toJson(),
      'familyMembers': members.map((m) => m.toJson()).toList(),
    };
  }
}

class FamilyHead {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String nativePlace;
  final String address;
  final String? profileImage;
  final String? education;
  final String? dob;

  FamilyHead({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.nativePlace,
    required this.address,
    this.profileImage,
    this.education,
    this.dob,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': fullName,
      'mobile': phoneNumber,
      'nativePlace': nativePlace,
      'address': address,
      'profile': profileImage,
      'education': education,
      'dob': dob,
    };
  }

  // Convert to User object
  Map<String, dynamic> toUserJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'nativePlace': nativePlace,
      'address': address,
      'isHeadOfFamily': true,
      'relation': 'Head',
      'education': education,
      'dob': dob,
    };
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final String phoneNumber;
  final String? education;
  final String? occupation;
  final String? dob;
  final String? profileImage;
  final String? nativePlace;
  final String? address;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.phoneNumber,
    this.education,
    this.occupation,
    this.dob,
    this.profileImage,
    this.nativePlace,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'mobile': phoneNumber,
      'education': education,
      'occupation': occupation,
      'dob': dob,
      'profile': profileImage,
      'nativePlace': nativePlace,
      'address': address,
    };
  }

  // Convert to User object
  Map<String, dynamic> toUserJson() {
    return {
      'id': id,
      'fullName': name,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'nativePlace': nativePlace,
      'address': address,
      'isHeadOfFamily': false,
      'relation': relation,
      'education': education,
      'occupation': occupation,
      'dob': dob,
    };
  }
}