import 'package:mmsn/app/AppImages.dart';
import 'package:mmsn/models/family.dart';
import 'package:mmsn/models/user.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:mmsn/models/announcement.dart';

@NowaGenerated()
class DataService {
  DataService._();

  final List<String> carouselImages = [
    AppImages.carouselImages1,
    AppImages.carouselImages2,
    AppImages.carouselImages3, 
    AppImages.carouselImages4,
  ];

  final List<Family> _mockFamilies = [
    Family(
      id: '1',
      head: User(
        id: '1',
        fullName: 'John Smith',
        phoneNumber: '1234567890',
        pin: '1234',
        profileImage:
            AppImages.profileImageHead1,
        isHeadOfFamily: true,
        society: 'Green Valley Society',
        area: 'Block A',
        address: 'Flat 401, Green Valley Apartments, Sector 12',
        nativePlace: 'Mumbai, Maharashtra',
        occupation: 'Software Engineer',
        email: 'john.smith@email.com',
        dateOfBirth: DateTime(1985, 5, 15),
      ),
      members: [
        User(
          id: '1a',
          fullName: 'Jane Smith',
          phoneNumber: '1234567891',
          pin: '1235',
          profileImage:
              AppImages.profileImageHead1Wife,
          relation: 'Wife',
          occupation: 'Teacher',
          dateOfBirth: DateTime(1987, 8, 22),
          email: 'jane.smith@email.com',
        ),
        User(
          id: '1b',
          fullName: 'Mike Smith',
          phoneNumber: '1234567892',
          pin: '1236',
          profileImage:
              AppImages.profileImageHead1Son,
          relation: 'Son',
          occupation: 'Student',
          dateOfBirth: DateTime(2010, 12, 8),
        ),
        User(
          id: '1c',
          fullName: 'Emma Smith',
          phoneNumber: '1234567893',
          pin: '1237',
          profileImage:
              AppImages.profileImageHead1Daughter,
          relation: 'Daughter',
          occupation: 'Student',
          dateOfBirth: DateTime(2013, 3, 15),
        ),
      ],
      society: 'Green Valley Society',
      area: 'Block A',
    ),
    Family(
      id: '2',
      head: User(
        id: '2',
        fullName: 'Sarah Johnson',
        phoneNumber: '9876543210',
        pin: '5678',
        profileImage:
            'https://images.unsplash.com/photo-1582407947304-fd86f028f716?w=400',
        isHeadOfFamily: true,
        society: 'Sunset Heights',
        area: 'Block B',
        address: 'Villa 15, Sunset Heights, Garden City',
        nativePlace: 'Delhi, India',
        occupation: 'Doctor',
        email: 'sarah.johnson@email.com',
        dateOfBirth: DateTime(1982, 11, 30),
      ),
      members: [
        User(
          id: '2a',
          fullName: 'Robert Johnson',
          phoneNumber: '9876543211',
          pin: '5679',
          profileImage:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
          relation: 'Husband',
          occupation: 'Business Owner',
          dateOfBirth: DateTime(1980, 7, 18),
          email: 'robert.johnson@email.com',
        ),
        User(
          id: '2b',
          fullName: 'Lisa Johnson',
          phoneNumber: '9876543212',
          pin: '5680',
          profileImage:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
          relation: 'Daughter',
          occupation: 'Student',
          dateOfBirth: DateTime(2008, 4, 25),
        ),
      ],
      society: 'Sunset Heights',
      area: 'Block B',
    ),
    Family(
      id: '3',
      head: User(
        id: '3',
        fullName: 'John Jhon',
        phoneNumber: '1234567890',
        pin: '1234',
        profileImage:
            AppImages.profileImageHead1,
        isHeadOfFamily: true,
        society: 'Green Valley Society',
        area: 'Block A',
        address: 'Flat 401, Green Valley Apartments, Sector 12',
        nativePlace: 'Mumbai, Maharashtra',
        occupation: 'Software Engineer',
        email: 'john.smith@email.com',
        dateOfBirth: DateTime(1985, 5, 15),
      ),
      members: [
        User(
          id: '3a',
          fullName: 'Jane Jane',
          phoneNumber: '1234567891',
          pin: '1235',
          profileImage:
              AppImages.profileImageHead1Wife,
          relation: 'Wife',
          occupation: 'Teacher',
          dateOfBirth: DateTime(1987, 8, 22),
          email: 'jane.smith@email.com',
        ),
        User(
          id: '3b',
          fullName: 'Mike Mike',
          phoneNumber: '1234567892',
          pin: '1236',
          profileImage:
              AppImages.profileImageHead1Son,
          relation: 'Son',
          occupation: 'Student',
          dateOfBirth: DateTime(2010, 12, 8),
        ),
        User(
          id: '3c',
          fullName: 'Emma Emma',
          phoneNumber: '1234567893',
          pin: '1237',
          profileImage:
              AppImages.profileImageHead1Daughter,
          relation: 'Daughter',
          occupation: 'Student',
          dateOfBirth: DateTime(2013, 3, 15),
        ),
      ],
      society: 'Green Valley Society',
      area: 'Block Y',
    ),
    Family(
      id: '4',
      head: User(
        id: '4',
        fullName: 'SMith Smith',
        phoneNumber: '1234567890',
        pin: '1234',
        profileImage:
            AppImages.profileImageHead1,
        isHeadOfFamily: true,
        society: 'Green Valley Society',
        area: 'Block A',
        address: 'Flat 401, Green Valley Apartments, Sector 12',
        nativePlace: 'Mumbai, Maharashtra',
        occupation: 'Software Engineer',
        email: 'john.smith@email.com',
        dateOfBirth: DateTime(1985, 5, 15),
      ),
      members: [
        User(
          id: '4a',
          fullName: 'TEan Smith',
          phoneNumber: '1234567891',
          pin: '1235',
          profileImage:
              AppImages.profileImageHead1Wife,
          relation: 'Wife',
          occupation: 'Teacher',
          dateOfBirth: DateTime(1987, 8, 22),
          email: 'jane.smith@email.com',
        ),
        User(
          id: '4b',
          fullName: 'Mike Smith',
          phoneNumber: '1234567892',
          pin: '1236',
          profileImage:
              AppImages.profileImageHead1Son,
          relation: 'Son',
          occupation: 'Student',
          dateOfBirth: DateTime(2010, 12, 8),
        ),
        User(
          id: '4c',
          fullName: 'SMith SMith',
          phoneNumber: '1234567893',
          pin: '1237',
          profileImage:
              AppImages.profileImageHead1Daughter,
          relation: 'Daughter',
          occupation: 'Student',
          dateOfBirth: DateTime(2013, 3, 15),
        ),
      ],
      society: 'Green Valley Society',
      area: 'Block Z',
    ),
  ];

  final List<Announcement> _mockAnnouncements = [
    Announcement(
      id: '1',
      title: 'Society Annual Meeting 2024',
      description:
          'Join us for our annual society meeting to discuss important matters, budget approvals, and upcoming projects.',
      fullContent:
          'Dear Residents,\n\nWe cordially invite you to attend our Annual Society Meeting scheduled for next week. This meeting will cover:\n\n• Budget approval for the upcoming year\n• Maintenance and infrastructure projects\n• New security protocols\n• Community events planning\n• Q&A session with management\n\nYour participation is highly appreciated as we work together to improve our community.\n\nRefreshments will be provided.\n\nThank you,\nManagement Committee',
      date: DateTime.now().add(const Duration(days: 7)),
      image:
          'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=600',
    ),
    Announcement(
      id: '2',
      title: 'Water Maintenance Notice',
      description:
          'Important: Water supply will be temporarily disrupted for maintenance work.',
      fullContent:
          'Dear Residents,\n\nThis is to inform you that maintenance work will be conducted on our water supply system.\n\nSchedule Details:\n• Date: Tomorrow\n• Time: 10:00 AM to 2:00 PM\n• Duration: Approximately 4 hours\n\nAffected Areas:\n• All residential blocks\n• Common areas\n• Swimming pool\n\nWe apologize for any inconvenience caused. Please store adequate water for your needs during this period.\n\nEmergency contact: 9876543210\n\nRegards,\nMaintenance Department',
      date: DateTime.now().add(const Duration(days: 1)),
      image:
          'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=600',
    ),
    Announcement(
      id: '3',
      title: 'New Security Guidelines',
      description:
          'Updated security protocols and visitor guidelines now available.',
      fullContent:
          'Dear Residents,\n\nWe have updated our security protocols to ensure better safety for all residents.\n\nNew Guidelines:\n• All visitors must be registered at the gate\n• Valid ID required for entry\n• Visitor timing: 6 AM to 10 PM\n• Emergency contact verification\n• Vehicle registration mandatory\n\nFor detailed information, please refer to the attached PDF document which contains comprehensive guidelines, emergency procedures, and contact information.\n\nYour cooperation is essential for maintaining our community\'s security.\n\nBest regards,\nSecurity Committee',
      date: DateTime.now().add(const Duration(days: 3)),
      image: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=600',
      pdfUrl: 'https://example.com/security-guidelines.pdf',
    ),
    Announcement(
      id: '4',
      title: 'Festive Celebration - Diwali 2024',
      description:
          'Join us for a grand Diwali celebration with cultural programs and community dinner.',
      fullContent:
          'Dear Residents,\n\nWe are excited to invite you and your family to our grand Diwali celebration!\n\nEvent Details:\n• Date: October 31, 2024\n• Time: 6:00 PM onwards\n• Venue: Community Hall\n• Dress Code: Traditional attire preferred\n\nProgram Schedule:\n• 6:00 PM - Welcome and lighting ceremony\n• 6:30 PM - Cultural performances by residents\n• 7:30 PM - Traditional dinner\n• 8:30 PM - Prize distribution and games\n• 9:30 PM - DJ and dancing\n\nPlease confirm your attendance by October 25th.\n\nContact: events@community.com\n\nLet\'s celebrate together!\nEvents Committee',
      date: DateTime.now().add(const Duration(days: 14)),
      image:
          'https://images.unsplash.com/photo-1478391679764-b2d8b3cd1e94?w=600',
    ),
  ];

  static DataService? _instance;

  static DataService get instance {
    return _instance ??= DataService._();
  }

  Future<List<Family>> getFamilies() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockFamilies);
  }

  Future<List<Family>> searchFamilies(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (query.isEmpty) {
      return getFamilies();
    }
    return _mockFamilies
        .where(
          (family) =>
              family.head.fullName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              family.head.phoneNumber.contains(query),
        )
        .toList();
  }

  Future<Family?> getFamilyById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockFamilies.firstWhere((family) => family.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Family?> getFamilyByHeadId(String headId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockFamilies.firstWhere((family) => family.head.id == headId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Announcement>> getAnnouncements() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockAnnouncements);
  }

  Future<Map<String, List<Family>>> getFamiliesBySociety() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final Map<String, List<Family>> societyGroups = {};
    for (final dynamic family in _mockFamilies) {
      if (!societyGroups.containsKey(family.society)) {
        societyGroups[family.society] = [];
      }
      societyGroups[family.society]?.add(family);
    }
    return societyGroups;
  }

  Future<bool> updateUser(User updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int i = 0; i < _mockFamilies.length; i++) {
      final family = _mockFamilies[i];
      if (family.head.id == updatedUser.id) {
        _mockFamilies[i] = Family(
          id: family.id,
          head: updatedUser,
          members: family.members,
          society: family.society,
          area: family.area,
        );
        return true;
      }
      for (int j = 0; j < family.members.length; j++) {
        if (family.members[j].id == updatedUser.id) {
          final updatedMembers = List<User>.from(family.members);
          updatedMembers[j] = updatedUser;
          _mockFamilies[i] = Family(
            id: family.id,
            head: family.head,
            members: updatedMembers,
            society: family.society,
            area: family.area,
          );
          return true;
        }
      }
    }
    return false;
  }

  Future<Family?> getFamilyByMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (final dynamic family in _mockFamilies) {
      if (family.head.id == memberId ||
          family.members.any((member) => member.id == memberId)) {
        return family;
      }
    }
    return null;
  }
}
