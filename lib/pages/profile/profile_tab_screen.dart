import 'package:flutter/material.dart';
import 'package:mmsn/admin_screens/adding_family.dart';
import 'package:mmsn/app/globals/app_localizations.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/app/services/launchCall.dart';
import 'package:mmsn/app/services/launchEmail.dart';
import 'package:mmsn/components/cached_avatar.dart';
import 'package:mmsn/models/family.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/pages/auth/services/auth_service.dart';
import 'package:mmsn/pages/auth/data/user_service.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';
import 'package:mmsn/pages/family/member_details_screen.dart';
import 'package:mmsn/pages/profile/update/edit_member_screen.dart';
import 'package:mmsn/pages/auth/login_screen.dart';
import 'package:mmsn/pages/family/services/family_api_services.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() {
    return _ProfileTabScreenState();
  }
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final ScrollController _scrollController = ScrollController();

  Family? _userFamily;
  List<User> _familyMembersFromLogin = []; // ✅ Store login API data

  bool _isLoading = true;

  // Cache the current user to prevent re-fetching on every rebuild
  User? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    // Load user and family data once in initState
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTap(String value, {bool? isEmail, bool? isPhone}) async {
    if (isPhone == true) {
      launchPhone(value);
    }
    if (isEmail == true) {
      launchEmail(value);
    }
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _isLoadingUser = true;
    });

    try {
      // Try storage first
      User? user = await AuthLocalStorage.getUser();

      // Try AuthApiService
      user ??= AuthApiService.instance.currentUser;

      // Always try to fetch from API to get latest/complete user data
      try {
        final apiUser = await UserService.instance.getCurrentUser();
        // Update storage with fresh data from API
        await AuthLocalStorage.saveUser(apiUser);
        AuthApiService.instance.updateCurrentUser(apiUser);
        user = apiUser; // Use the fresh data from API
      } catch (e) {
        print('Error fetching user from API: $e');
        // If API fails, use stored user if available
        if (user == null) {
          print('No user data available from storage or API');
        }
      }

      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });

      // Load family data after user is loaded
      if (user != null) {
        _loadUserFamily();
      }
    } catch (e) {
      print('Error loading current user: $e');
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _loadUserFamily() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<User> familyMembers = [];

      // 1. Try to fetch fresh data from API
      try {
        print('🌐 Fetching fresh family data from API...');
        Family? family;
        
        if (_currentUser!.familyId != null && _currentUser!.familyId!.isNotEmpty) {
           family = await FamilyApiService.instance.getFamilyById(_currentUser!.familyId!);
        } else {
           family = await FamilyApiService.instance.getFamilyByMemberId(_currentUser!.id);
        }

        if (family != null) {
          // Convert Family to List<User>
          familyMembers = [
            User.fromJson(family.head.toUserJson()),
            ...family.members.map((m) => User.fromJson(m.toUserJson()))
          ];
          
          // Update local storage with fresh data
          await AuthLocalStorage.saveFamilyMembers(
            familyMembers.map((u) => u.toJson()).toList()
          );
          
          print('✅ Fetched & saved ${familyMembers.length} family members from API');
        }
      } catch (e) {
        print('⚠️ Failed to fetch family from API: $e. Falling back to local storage.');
      }

      // 2. If API failed or returned empty, fallback to local storage
      if (familyMembers.isEmpty) {
        familyMembers = await AuthLocalStorage.getFamilyMembers();
        print('📂 Loaded ${familyMembers.length} family members from local storage');
      }

      if (familyMembers.isEmpty) {
        print('⚠️ No family members found in API or storage.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create a mock Family object for internal use if needed
      // Find the head (userType == "HEAD")
      final head = familyMembers.firstWhere(
        (m) => m.userType.toUpperCase() == 'HEAD',
        orElse: () => familyMembers.first,
      );

      setState(() {
        // Store the complete family members list
        _familyMembersFromLogin = familyMembers;
        _isLoading = false;
      });

      print('✅ Family data interaction complete');
    } catch (e) {
      print('❌ Error loading family data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Determine the role tags for a member
  /// Returns a list of role tags like ["Head", "Editor"] or ["Head & Editor"]
  List<String> _getMemberRoleTags(User member, List<User> allMembers) {
    List<String> tags = [];

    final userType = member.userType.toUpperCase();
    final isHead = userType == 'HEAD';
    final isEditor = userType == 'EDITOR';

    print('🔍 Checking role for: ${member.fullName}');
    print('   - userType: $userType');
    print('   - isHead: $isHead, isEditor: $isEditor');

    // If member is HEAD
    if (isHead) {
      // Check if there are other editors in the family (excluding this member)
      final otherEditors = allMembers
          .where(
              (m) => m.id != member.id && m.userType.toUpperCase() == 'EDITOR')
          .toList();

      print('   - Checking for other editors (excluding ${member.fullName}):');
      print('   - Total family members: ${allMembers.length}');
      allMembers.forEach((m) {
        print('     * ${m.fullName}: userType=${m.userType}, id=${m.id}');
      });
      print('   - Other editors found: ${otherEditors.length}');
      otherEditors.forEach((e) => print('     * ${e.fullName}'));

      if (otherEditors.isEmpty) {
        // Head is the only editor (implicit editor role)
        tags.add('Head & Editor');
        print('   ✅ Result: Head & Editor (no other editors)');
      } else {
        // There are other editors, so just show Head
        tags.add('Head');
        print('   ✅ Result: Head (other editors exist)');
      }
    }
    // If member is EDITOR (but not HEAD)
    else if (isEditor) {
      tags.add('Editor');
      print('   ✅ Result: Editor');
    }

    return tags;
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while user is being fetched
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state if user is not found
    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('User not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    // Build the profile content with the cached user
    return _buildProfileContent(_currentUser!);
  }

  Widget _buildProfileContent(User currentUser) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: _isLoadingUser ? null : _loadCurrentUser,
                icon: _isLoadingUser
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.sync, color: Colors.white),
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double maxHeight = 200.0;
                final double minHeight =
                kToolbarHeight + MediaQuery.of(context).padding.top;
                final double currentHeight = constraints.biggest.height;

                // 0.0 = expanded, 1.0 = collapsed
                final double collapsePercent =
                (1 - (currentHeight - minHeight) / (maxHeight - minHeight))
                    .clamp(0.0, 1.0);

                return FlexibleSpaceBar(
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    // Show title only when almost fully collapsed (prevent collision)
                    opacity: collapsePercent > 0.85 ? 1.0 : 0.0,
                    child: Text(
                      currentUser.fullName,
                      style: const TextStyle(
                         // Consider adjusting font size or padding if still tight
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  background: Opacity(
                    // Fade out earlier to avoid collision with incoming title
                    // e.g. at 0.6 progress it starts fading, by 0.8 it's gone
                    opacity: (1 - collapsePercent * 1.5).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: 1.0 - (collapsePercent * 0.2), // Slight shrink effect
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Gap.s40H(),
                              Hero(
                                tag: 'profile_image_${currentUser.id}',
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: CachedAvatar(
                                    radius: 50,
                                    imageUrl: currentUser.profileImage,
                                  ),
                                ),
                              ),
                              Gap.s12H(),
                              Column(
                                children: [
                                  Text(
                                    currentUser.fullName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Gap.s4H(),
                                  Text(
                                    currentUser.phoneNumber,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedSection(
                          title: 'Personal Information',
                          child: _buildPersonalInfoCard(currentUser),
                          delay: 100,
                        ),
                        Gap.s24H(),
                        if (_familyMembersFromLogin.isNotEmpty) ...[
                          _buildAnimatedSection(
                            title: 'Family Members',
                            child: _buildFamilyMembersSection(
                                _userFamily, currentUser),
                            delay: 200,
                          ),
                          Gap.s24H(),
                        ],
                        if (_currentUser!.userType == 'ADMIN' ||
                            _currentUser!.userType == 'HEAD' ||
                            _currentUser!.userType == 'EDITOR'||
                            _currentUser!.userType == 'HeadAndAdmin') ...[
                          _buildAnimatedSection(
                            title: 'Actions',
                            child: _buildActionsSection(currentUser),
                            delay: 300,
                          ),
                          Gap.s30H(),
                        ],
                        if (_currentUser!.userType == 'ADMIN' ||
                            _currentUser!.userType == 'HeadAndAdmin') ...[
                          _buildAnimatedSection(
                            title: 'Super Admin Actions',
                            child: _buildSuperAdminActionsSection(currentUser),
                            delay: 300,
                          ),
                          Gap.s30H(),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({
    required String title,
    required Widget child,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 30 * (1 - value)),
        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Gap.s16H(),
          child,
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(User user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildAnimatedInfoRow(
              Icons.phone,
              'Phone',
              user.phoneNumber,
              0,
              isPhone: true,
            ),
            _buildAnimatedInfoRow(
              Icons.email,
              'Email',
              user.email ?? 'Not provided',
              100,
              isEmail: true,
            ),
            _buildAnimatedInfoRow(
              Icons.work,
              'Occupation',
              user.occupation ?? 'Not specified',
              200,
            ),
            _buildAnimatedInfoRow(
              Icons.apartment,
              'Society',
              user.society ?? 'Not specified',
              300,
            ),
            _buildAnimatedInfoRow(
              Icons.location_on,
              'Area',
              user.area ?? 'Not specified',
              400,
            ),
            _buildAnimatedInfoRow(
              Icons.home,
              'Address',
              user.address ?? 'Not provided',
              500,
            ),
            _buildAnimatedInfoRow(
              Icons.place,
              // 'Native Place',
              AppLocalizations.text(context, 'nativePlace'),
              user.nativePlace ?? 'Not specified',
              600,
            ),
            if (user.dateOfBirth != null)
              _buildAnimatedInfoRow(
                Icons.cake,
                'Date of Birth',
                '${user.dateOfBirth?.day}/${user.dateOfBirth?.month}/${user.dateOfBirth?.year}',
                700,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedInfoRow(
    IconData icon,
    String label,
    String value,
    int delay, {
    bool? isEmail,
    bool? isPhone,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, animation, child) => Transform.translate(
        offset: Offset(50 * (1 - animation), 0),
        child: Opacity(opacity: animation, child: child),
      ),
      child: GestureDetector(
        onTap: () => _handleTap(
          value,
          isEmail: isEmail,
          isPhone: isPhone,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              Gap.s16W(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Gap.s4H(),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyMembersSection(Family? family, User currentUser) {
    // ✅ USE LOGIN API DATA (has userType)
    final allMembers = <User>[
      ..._familyMembersFromLogin.isNotEmpty
          ? _familyMembersFromLogin
          : (family != null
              ? [
                  User.fromJson(family.head.toUserJson()),
                  ...family.members.map((m) => User.fromJson(m.toUserJson()))
                ]
              : [])
    ];

    if (allMembers.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('No family members found'),
        ),
      );
    }

    print('🔍 Building family section with ${allMembers.length} members:');
    allMembers.forEach((m) {
      print('   - ${m.fullName}: userType=${m.userType}');
    });

    return Column(
      children: allMembers.asMap().entries.map((entry) {
        final index = entry.key;
        final member = entry.value;
        final isCurrentUser = member.id == currentUser.id;

        // ✅ Pass complete member list for accurate role checking
        final roleTags = _getMemberRoleTags(member, allMembers);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          builder: (context, animation, child) => Transform.scale(
            scale: animation,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - animation)),
              child: child,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: isCurrentUser ? 6 : 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: isCurrentUser
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                  gradient: isCurrentUser
                      ? LinearGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showMemberDetails(member),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'member_${member.id}',
                          child: CachedAvatar(
                            radius: 30,
                            imageUrl: member.profileImage,
                          ),
                        ),
                        Gap.s16W(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      member.fullName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isCurrentUser
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : null,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCurrentUser) ...[
                                    Gap.s8W(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'You',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Gap.s4H(),
                              // Role tags
                              if (roleTags.isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: roleTags.map((tag) {
                                    final isHeadTag = tag.contains('Head');
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isHeadTag
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.2)
                                            : Colors.orange
                                                .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isHeadTag
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.orange[800],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              else if (member.relation != null &&
                                  member.relation!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    member.relation!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              Gap.s4H(),
                              Text(
                                member.phoneNumber,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (currentUser.userType == "HEAD" ||
                                currentUser.userType == "EDITOR" ||
                                currentUser.userType == "ADMIN" ||
                                _currentUser?.userType == 'HeadAndAdmin')
                              IconButton(
                                onPressed: () => _editMember(member),
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                tooltip: 'Edit Details',
                              ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionsSection(User currentUser) {
    return Column(
      children: [
        if (currentUser.userType == 'HEAD' ||
            currentUser.userType == 'EDITOR') ...[
          _buildAnimatedActionButton(
            icon: Icons.person_add,
            title: 'Add Family Member',
            subtitle: 'Add new family member to your profile',
            onTap: () => _addFamilyMember(),
            delay: 0,
          ),
        ],
      ],
    );
  }

  Widget _buildSuperAdminActionsSection(User currentUser) {
    return Column(
      children: [
        if (currentUser.userType == 'ADMIN' ||
            currentUser.userType == 'HeadAndAdmin') ...[
          _buildAnimatedActionButton(
            icon: Icons.group_add,
            title: 'Add Family',
            subtitle: 'Add new family in Samaj',
            onTap: () => _addFamily(),
            delay: 0,
          ),
        ],
      ],
    );
  }

  Widget _buildAnimatedActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required void Function() onTap,
    bool isDestructive = false,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutBack,
      builder: (context, animation, child) =>
          Transform.scale(scale: animation, child: child),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isDestructive
                  ? Border.all(color: Colors.red.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withValues(alpha: 0.1)
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                Gap.s16W(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDestructive ? Colors.red : null,
                                ),
                      ),
                      Gap.s4H(),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMemberDetails(User member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailsScreen(member: member),
      ),
    );
  }

  void _editMember(User member) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditMemberScreen(member: member)),
    ).then((updated) {
      if (updated == true) {
        // Reload both user and family data
        _loadCurrentUser();
      }
    });
  }

  void _addFamilyMember() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add family member functionality coming soon'),
      ),
    );
  }

  void _addFamily() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FamilyFormPage(),
      ),
    );

    // If the FamilyFormPage returns true, refresh the list
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New family added successfully!')),
      );
    }
  }
}
