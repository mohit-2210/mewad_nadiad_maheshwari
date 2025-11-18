import 'package:flutter/material.dart';
import 'package:mmsn/admin_screens/announcement_handling.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/models/announcement.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/pages/announcement/announcement_details_screen.dart';
import 'package:mmsn/pages/announcement/services/announcement_api_service.dart';
import 'package:mmsn/pages/auth/services/auth_service.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';

class AnnouncementsTabScreen extends StatefulWidget {
  const AnnouncementsTabScreen({super.key});

  @override
  State<AnnouncementsTabScreen> createState() => _AnnouncementsTabScreenState();
}

class _AnnouncementsTabScreenState extends State<AnnouncementsTabScreen> {
  List<Announcement> _announcements = [];
  bool _isLoading = true;
  User? _currentUser;
  bool _isLoadingUser = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadAnnouncements();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _isLoadingUser = true;
    });
    
    try {
      // Try to get user from storage first
      User? user = await AuthLocalStorage.getUser();
      
      // If not in storage, get from AuthApiService
      user ??= AuthApiService.instance.currentUser;
      
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      print('Error loading current user: $e');
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  bool get _isAdmin {
    return _currentUser?.userType == 'ADMIN';
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final announcements = await AnnouncementApiService.instance.getAnnouncements();
      
      // Sort announcements by date (newest first)
      announcements.sort((a, b) => b.date.compareTo(a.date));
      
      setState(() {
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading announcements: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load announcements: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadAnnouncements,
            ),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return 'In $difference days';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.lock, color: Colors.red),
            SizedBox(width: 8),
            Text('Access Denied'),
          ],
        ),
        content: const Text(
          'Only administrators can add or edit announcements.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📢 Announcements',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Show Add button only for Admin users
                  if (_isAdmin)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Color(0xFF6A11CB)),
                      label: const Text(
                        'Add',
                        style: TextStyle(
                          color: Color(0xFF6A11CB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddAnnouncementPage(),
                          ),
                        );

                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('New announcement added!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadAnnouncements();
                        }
                      },
                    )
                  else if (!_isLoadingUser)
                    // Show locked button for non-admin users
                    Tooltip(
                      message: 'Admin access required',
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.7),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.lock, 
                          color: Colors.grey, 
                          size: 18,
                        ),
                        label: const Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _showAccessDeniedDialog,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnnouncements,
              child: _announcements.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_off,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                Gap.s16H(),
                                Text(
                                  _errorMessage != null 
                                      ? 'Error loading announcements'
                                      : 'No announcements yet',
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                Gap.s8H(),
                                Text(
                                  _errorMessage != null
                                      ? 'Please try again later'
                                      : 'Check back later for updates',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[500]),
                                ),
                                if (_errorMessage != null) ...[
                                  Gap.s16H(),
                                  ElevatedButton.icon(
                                    onPressed: _loadAnnouncements,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _announcements.length,
                      itemBuilder: (context, index) {
                        final announcement = _announcements[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            elevation: 4,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AnnouncementDetailsScreen(
                                      announcement: announcement,
                                      isAdmin: _isAdmin,
                                    ),
                                  ),
                                ).then((shouldRefresh) {
                                  if (shouldRefresh == true) {
                                    _loadAnnouncements();
                                  }
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      if (announcement.image != null)
                                        Image.network(
                                          announcement.image!,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 180,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      if (_isAdmin && announcement.image != null)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                announcement.title,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                              ),
                                            ),
                                            if (announcement.pdfUrl != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: const [
                                                    Icon(
                                                      Icons.picture_as_pdf,
                                                      color: Colors.red,
                                                      size: 14,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'PDF',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        Gap.s8H(),
                                        Text(
                                          announcement.description,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                  color: Colors.grey[700]),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Gap.s12H(),
                                        Row(
                                          children: [
                                            Icon(Icons.schedule,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            Gap.s4W(),
                                            Text(
                                              _formatDate(announcement.date),
                                              style: theme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                      color: Colors.grey[600]),
                                            ),
                                            const Spacer(),
                                            TextButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AnnouncementDetailsScreen(
                                                      announcement:
                                                          announcement,
                                                      isAdmin: _isAdmin,
                                                    ),
                                                  ),
                                                ).then((shouldRefresh) {
                                                  if (shouldRefresh == true) {
                                                    _loadAnnouncements();
                                                  }
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.arrow_forward,
                                                size: 14,
                                              ),
                                              label: const Text('Read More'),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    const Color(0xFF6A11CB),
                                                textStyle: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}