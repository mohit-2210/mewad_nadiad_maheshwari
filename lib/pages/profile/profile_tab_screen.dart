import 'package:flutter/material.dart';
import 'package:mmsn/admin_screens/adding_family.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/models/family.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/pages/auth/services/auth_service.dart';
import 'package:mmsn/pages/auth/data/user_service.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';
import 'package:mmsn/pages/family/services/family_api_services.dart';
import 'package:mmsn/pages/family/member_details_screen.dart';
import 'package:mmsn/pages/profile/update/edit_member_screen.dart';
import 'package:mmsn/pages/auth/login_screen.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() {
    return _ProfileTabScreenState();
  }
}

class _ProfileTabScreenState extends State<ProfileTabScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late AnimationController _headerAnimationController;

  late Animation<double> _headerScaleAnimation;

  late Animation<double> _headerOpacityAnimation;

  Family? _userFamily;

  bool _isLoading = true;

  double _scrollOffset = 0;
  
  // Cache the current user to prevent re-fetching on every rebuild
  User? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _headerScaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _headerOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _scrollController.addListener(_handleScroll);
    
    // Load user and family data once in initState
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

void _handleScroll() {
  final offset = _scrollController.offset;
  if (offset != _scrollOffset) {
    setState(() {
      _scrollOffset = offset;
      const maxOffset = 200;
      final value = (_scrollOffset / maxOffset).clamp(0, 1).toDouble();
      _headerAnimationController.value = value;
    });
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
      if (user == null) {
        user = AuthApiService.instance.currentUser;
      }
      
      // Always try to fetch from API to get latest/complete user data
      try {
        final apiUser = await UserService.instance.getCurrentUser();
        if (apiUser != null) {
          // Update storage with fresh data from API
          await AuthLocalStorage.saveUser(apiUser);
          await AuthApiService.instance.updateCurrentUser(apiUser);
          user = apiUser; // Use the fresh data from API
        }
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
      // Try to get family by head ID first
      Family? family = await FamilyApiService.instance.getFamilyByHeadId(
        _currentUser!.id,
      );
      
      // If not found, try by member ID
      if (family == null) {
        family = await FamilyApiService.instance.getFamilyByMemberId(
          _currentUser!.id,
        );
      }
      
      setState(() {
        _userFamily = family;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user family: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: AnimatedOpacity(
                opacity: _scrollOffset > 100 ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  currentUser.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              background: Container(
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
                  child: AnimatedBuilder(
                    animation: _headerScaleAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _headerScaleAnimation.value,
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
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: currentUser.profileImage != null
                                    ? NetworkImage(currentUser.profileImage!)
                                    : null,
                                child: currentUser.profileImage == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Gap.s12H(),
                          FadeTransition(
                            opacity: _headerOpacityAnimation,
                            child: Column(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                        if (_userFamily != null) ...[
                          _buildAnimatedSection(
                            title: 'Family Members',
                            child: _buildFamilyMembersSection(_userFamily!, currentUser),
                            delay: 200,
                          ),
                          Gap.s24H(),
                        ],
                        if(_currentUser!.userType == 'ADMIN' || _currentUser!.userType == 'HEAD') ...[
                        _buildAnimatedSection(
                          title: 'Actions',
                          child: _buildActionsSection(currentUser),
                          delay: 300,
                        ),
                        Gap.s30H(),
                        ],
                        if(_currentUser!.userType == 'ADMIN') ...[
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
            _buildAnimatedInfoRow(Icons.phone, 'Phone', user.phoneNumber, 0),
            _buildAnimatedInfoRow(
              Icons.email,
              'Email',
              user.email ?? 'Not provided',
              100,
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
              'Native Place',
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
    int delay,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, animation, child) => Transform.translate(
        offset: Offset(50 * (1 - animation), 0),
        child: Opacity(opacity: animation, child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
    );
  }

  Widget _buildFamilyMembersSection(Family family, User currentUser) {
    // Convert FamilyHead and FamilyMember to User objects
    final headUser = User.fromJson(family.head.toUserJson());
    final memberUsers = family.members.map((m) => User.fromJson(m.toUserJson())).toList();
    final allMembers = [headUser, ...memberUsers];
    
    return Column(
      children: allMembers.asMap().entries.map((entry) {
        final index = entry.key;
        final member = entry.value;
        final isCurrentUser = member.id == currentUser.id;
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
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: member.profileImage != null
                                ? NetworkImage(member.profileImage!)
                                : null,
                            child: member.profileImage == null
                                ? const Icon(Icons.person, size: 30)
                                : null,
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
                                    ),
                                  ),
                                  if (isCurrentUser)
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
                              ),
                              Gap.s4H(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: member.isHeadOfFamily
                                      ? Theme.of(
                                          context,
                                        )
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.2)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  member.isHeadOfFamily
                                      ? 'Head of Family'
                                      : (member.relation ?? 'Family Member'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: member.isHeadOfFamily
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey[700],
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
                            if (currentUser.isHeadOfFamily == true)
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
        if (currentUser.isHeadOfFamily) ...[
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
        if (currentUser.userType == 'ADMIN') ...[
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