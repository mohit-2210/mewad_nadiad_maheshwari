import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/models/announcement.dart';
import 'package:mmsn/pages/announcement/pdf_viewer.dart';
import 'package:mmsn/pages/announcement/services/announcement_api_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class AnnouncementDetailsScreen extends StatefulWidget {
  const AnnouncementDetailsScreen({
    required this.announcement,
    this.isAdmin = false,
    super.key,
  });

  final Announcement announcement;
  final bool isAdmin;

  @override
  State<AnnouncementDetailsScreen> createState() {
    return _AnnouncementDetailsScreenState();
  }
}

class _AnnouncementDetailsScreenState extends State<AnnouncementDetailsScreen> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference =
      date.difference(DateTime(now.year, now.month, now.day)).inDays;

  if (difference == 0) {
    return 'Today';
  } else {
    if (difference == 1) {
      return 'Tomorrow';
    } else {
      // FUTURE DATES -----------------------------------------------------
      if (difference > 1 && difference <= 7) {
        return 'In $difference days';
      }

      // PAST DATES -------------------------------------------------------
      if (difference == -1) {
        return 'Yesterday';
      }

      if (difference < -1 && difference >= -7) {
        return '${difference.abs()} days ago';
      }

      // DEFAULT ----------------------------------------------------------
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}


  Future<void> openExternally(String url) async {
    try {
      final dir = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${url.split('/').last}';
      final file = File(filePath);

      if (!await file.exists()) {
        final dio = Dio();
        await dio.download(url, filePath);
      }

      await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint('Error opening file externally: $e');
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Announcement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this announcement? '
          'This action cannot be undone.',
          style: TextStyle(fontSize: 16),
          softWrap: true,
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                await AnnouncementApiService.instance.deleteAnnouncement(
                  widget.announcement.id,
                );

                if (!mounted) return;

                Navigator.pop(context); // close loader
                Navigator.pop(context, true); // close detail screen

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Announcement deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                Navigator.pop(context); // close loader

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red.shade400),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: widget.announcement.image != null ? 300 : 120,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.announcement.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              background: widget.announcement.image != null
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Image(
                        image: NetworkImage(widget.announcement.image!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
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
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
            ),
            actions: [
              // Show edit and delete buttons only for admins
              if (widget.isAdmin) ...[
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.black,
                  ),
                  tooltip: 'Edit Announcement',
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAnnouncementPage(
                          announcement: widget.announcement,
                        ),
                      ),
                    );

                    if (result == true) {
                      Navigator.pop(
                          context, true); // Return true to refresh list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Announcement updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  tooltip: 'Delete Announcement',
                  onPressed: _showDeleteConfirmation,
                ),
              ],
            ],
          ),
          SliverToBoxAdapter(
            child: AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              child: AnimatedScale(
                scale: _isVisible ? 1 : 0.95,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Admin mode indicator
                      if (widget.isAdmin)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) => Transform.scale(
                            scale: value,
                            child: child,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.purple.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                Gap.s12W(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Admin Mode',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6A11CB),
                                        ),
                                      ),
                                      Gap.s4H(),
                                      Text(
                                        'You can edit or delete this announcement',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.surface,
                                Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      )
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.notifications,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                  Gap.s16W(),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Announcement Details',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                        ),
                                        Gap.s8H(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.schedule,
                                                size: 16,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                              Gap.s4W(),
                                              Text(
                                                _formatDate(
                                                  widget.announcement.date,
                                                ),
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Gap.s24H(),
                              Text(
                                widget.announcement.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                              Gap.s16H(),
                              Text(
                                widget.announcement.fullContent ??
                                    widget.announcement.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.grey[700],
                                      height: 1.6,
                                    ),
                              ),
                              if (widget.announcement.pdfUrl != null) ...[
                                Gap.s24H(),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      final pdfUrl =
                                          widget.announcement.pdfUrl!;
                                            print("PDF URL => $pdfUrl");  // <-- DEBUG


                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PdfViewerScreen(
                                            pdfUrl: pdfUrl,
                                            title: widget.announcement.title,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.picture_as_pdf,
                                            color: Colors.red, size: 24),
                                        Gap.s12W(),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Attached Document',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              Gap.s4H(),
                                              Text(
                                                'Tap to view PDF document',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios,
                                            size: 16, color: Colors.red),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for EditAnnouncementPage
class EditAnnouncementPage extends StatelessWidget {
  const EditAnnouncementPage({
    required this.announcement,
    super.key,
  });

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement edit form similar to AddAnnouncementPage
    // but pre-filled with announcement data
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Announcement'),
        backgroundColor: const Color(0xFF6A11CB),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Announcement',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Editing: ${announcement.title}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'TODO: Implement edit form here\nSimilar to AddAnnouncementPage',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
