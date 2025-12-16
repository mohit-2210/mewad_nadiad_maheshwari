import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/components/family_card.dart';
import 'package:mmsn/models/family.dart';
import 'package:mmsn/pages/family/services/family_api_services.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/components/member_action_dialog.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SocietyTabScreen extends StatefulWidget {
  const SocietyTabScreen({super.key});

  @override
  State<SocietyTabScreen> createState() => _SocietyTabScreenState();
}

class _SocietyTabScreenState extends State<SocietyTabScreen> {
  Map<String, List<Family>> _societyGroups = {};
  bool _isLoading = true;
  final Map<String, bool> _expandedSections = {};

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // ✅ For scrollable index
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    _loadSocietyData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<String> get _filteredSocieties {
    if (_searchQuery.isEmpty) return _societyGroups.keys.toList();

    return _societyGroups.keys
        .where((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _loadSocietyData() async {
    try {
      final societyGroups =
          await FamilyApiService.instance.getFamiliesBySociety();
      setState(() {
        _societyGroups = societyGroups;
        _isLoading = false;
        for (final dynamic society in societyGroups.keys) {
          _expandedSections[society] = false;
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

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchQuery = '';
    });
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
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Stack(
            children: [
              _buildMainBody(),
              if (isKeyboardVisible)
                Positioned(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.deepPurple.shade300,
                    onPressed: () => FocusScope.of(context).unfocus(),
                    child: const Icon(Icons.keyboard_hide, color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainBody() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadSocietyData,
      child: Column(
        children: [
          // ✅ Enhanced Search Bar with Cancel Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search society...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                // ✅ Cancel Button
                if (_searchQuery.isNotEmpty || _searchFocusNode.hasFocus)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: _clearSearch,
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF6A11CB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: _filteredSocieties.isEmpty
                ? _buildEmptyState(theme)
                : _buildSocietyList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSocietyList(ThemeData theme) {
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSocieties.length,
      itemBuilder: (context, index) {
        final society = _filteredSocieties[index];
        final families = _societyGroups[society];
        final isExpanded = _expandedSections[society] ?? false;

        return _buildSocietyCard(society, families, isExpanded, theme);
      },
    );
  }

  Widget _buildSocietyCard(String society, List<Family>? families,
      bool isExpanded, ThemeData theme) {
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
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: isExpanded
                      ? const BorderRadius.vertical(top: Radius.circular(14))
                      : BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.apartment, color: theme.colorScheme.primary),
                    Gap.s12W(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            society,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Gap.s4H(),
                          Text(
                            '${families?.length ?? 0} families',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.expand_more,
                          color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: families
                        ?.map(
                          (family) => Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: FamilyCard(
                              family: family,
                              heroTagPrefix: 'society_family',
                              onTap: () {
                                final headUser =
                                    User.fromJson(family.head.toUserJson());
                                _showMemberActionDialog(headUser);
                              },
                            ),
                          ),
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
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apartment, size: 80, color: Colors.grey[400]),
          Gap.s16H(),
          Text(
            'No societies found',
            style:
                theme.textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          if (_searchQuery.isNotEmpty) ...[
            Gap.s8H(),
            Text(
              'Try a different search term',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
}
