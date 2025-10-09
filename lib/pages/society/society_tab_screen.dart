import 'package:flutter/material.dart';
import 'package:mmsn/models/family.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:mmsn/data_service.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/components/member_action_dialog.dart';
import 'package:mmsn/components/family_card.dart';
import 'package:mmsn/pages/family/family_details_screen.dart';

@NowaGenerated()
class SocietyTabScreen extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const SocietyTabScreen({super.key});

  @override
  State<SocietyTabScreen> createState() {
    return _SocietyTabScreenState();
  }
}

@NowaGenerated()
class _SocietyTabScreenState extends State<SocietyTabScreen> {
  Map<String, List<Family>> _societyGroups = {};

  bool _isLoading = true;

  final Map<String, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _loadSocietyData();
  }

  Future<void> _loadSocietyData() async {
    try {
      final societyGroups = await DataService.instance.getFamiliesBySociety();
      setState(() {
        _societyGroups = societyGroups;
        _isLoading = false;
        for (final dynamic society in societyGroups.keys) {
          _expandedSections[society] = true;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMemberActionDialog(User member) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MemberActionDialog(member: member),
    );
  }

  Widget _buildMemberCard(User member) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showMemberActionDialog(member),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'member_action_${member.id}',
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: member.profileImage != null
                        ? NetworkImage(member.profileImage!)
                        : null,
                    child: member.profileImage == null
                        ? const Icon(Icons.person, size: 25)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: member.isHeadOfFamily
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member.isHeadOfFamily
                              ? 'Head'
                              : (member.relation ?? 'Member'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: member.isHeadOfFamily
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.touch_app,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Society'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSocietyData,
              child: _societyGroups.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apartment,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No societies found',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _societyGroups.keys.length,
                      itemBuilder: (context, index) {
                        final society = _societyGroups.keys.elementAt(index);
                        final families = _societyGroups[society];
                        final isExpanded = _expandedSections[society] ?? false;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _expandedSections[society] = !isExpanded;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: isExpanded
                                          ? const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            )
                                          : BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.apartment,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                society,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${families?.length} families',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.grey[600],
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        AnimatedScale(
                                          scale: isExpanded ? 1 : 0.8,
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          child: Transform.rotate(
                                            angle: isExpanded ? 3.14159 : 0,
                                            child: Icon(
                                              Icons.expand_more,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AnimatedOpacity(
                                  opacity: isExpanded ? 1 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: AnimatedScale(
                                    scale: isExpanded ? 1 : 0.95,
                                    duration: const Duration(milliseconds: 300),
                                    child: isExpanded
                                        ? Column(
                                            children:
                                                families
                                                          ?.expand<Widget>(
                                                            (family) => [
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          8,
                                                                    ),
                                                                child: FamilyCard(
                                                                  family:
                                                                      family,
                                                                  heroTagPrefix: 'society_family',
                                                                  onTap: () {
                                                                    _showMemberActionDialog(
                                                                      family.head,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              // Show only heads in society tab; members removed for clarity and performance
                                                            ],
                                                          )
                                                          .toList() ??
                                                      []
                                                  ..add(
                                                    const SizedBox(height: 8),
                                                  ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
