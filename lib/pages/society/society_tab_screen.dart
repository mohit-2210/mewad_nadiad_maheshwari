import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/models/family.dart';
import 'package:mmsn/data_service.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/components/member_action_dialog.dart';
import 'package:mmsn/components/family_card.dart';

class SocietyTabScreen extends StatefulWidget {
  const SocietyTabScreen({super.key});

  @override
  State<SocietyTabScreen> createState() => _SocietyTabScreenState();
}

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
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Purple → Blue
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
                children: const [
                  Text(
                    '🏘️ Societies',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
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
              onRefresh: _loadSocietyData,
              child: _societyGroups.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.apartment,
                              size: 80, color: Colors.grey[400]),
                          Gap.s16H(),
                          Text(
                            'No societies found',
                            style: theme.textTheme.titleLarge
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
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _expandedSections[society] = !isExpanded;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.08),
                                      borderRadius: isExpanded
                                          ? const BorderRadius.vertical(
                                              top: Radius.circular(14),
                                            )
                                          : BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.apartment,
                                            color: theme.colorScheme.primary),
                                        Gap.s12W(),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                society,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .colorScheme.primary,
                                                ),
                                              ),
                                              Gap.s4H(),
                                              Text(
                                                '${families?.length ?? 0} families',
                                                style: theme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        AnimatedRotation(
                                          turns: isExpanded ? 0.5 : 0,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: Icon(Icons.expand_more,
                                              color:
                                                  theme.colorScheme.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AnimatedCrossFade(
                                  firstChild: const SizedBox.shrink(),
                                  secondChild: Column(
                                    children: families
                                            ?.expand<Widget>(
                                              (family) => [
                                                Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                                  child: FamilyCard(
                                                    family: family,
                                                    heroTagPrefix:
                                                        'society_family',
                                                    onTap: () {
                                                      _showMemberActionDialog(
                                                          family.head);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                            .toList() ??
                                        [],
                                  ),
                                  crossFadeState: isExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 300),
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
