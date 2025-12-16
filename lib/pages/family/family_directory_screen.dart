import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/models/family.dart';
import 'package:mmsn/components/cached_avatar.dart';
import 'package:mmsn/pages/family/family_details_screen.dart';
import 'package:mmsn/pages/family/services/family_api_services.dart';

class FamilyDirectoryScreen extends StatefulWidget {
  const FamilyDirectoryScreen({super.key});

  @override
  State<FamilyDirectoryScreen> createState() {
    return _FamilyDirectoryScreenState();
  }
}

class _FamilyDirectoryScreenState extends State<FamilyDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Family> _allFamilies = [];
  List<_FamilySearchResult> _searchResults = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFamilies();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadFamilies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final families = await FamilyApiService.instance.getFamilies();

      setState(() {
        _allFamilies = families;
        _searchResults = families
            .map((f) => _FamilySearchResult(
                  family: f,
                  matchType: _MatchType.none,
                  matchedMemberName: null,
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load families: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadFamilies,
            ),
          ),
        );
      }
    }
  }

  // ✅ Deep search function
  void _performSearch() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _searchQuery = query;

      if (query.isEmpty) {
        _searchResults = _allFamilies
            .map((f) => _FamilySearchResult(
                  family: f,
                  matchType: _MatchType.none,
                  matchedMemberName: null,
                ))
            .toList();
        return;
      }

      _searchResults = [];

      for (final family in _allFamilies) {
        // Check head name
        if (family.head.name.toLowerCase().contains(query)) {
          _searchResults.add(_FamilySearchResult(
            family: family,
            matchType: _MatchType.head,
            matchedMemberName: null,
          ));
          continue;
        }

        // Check head phone
        if (family.head.phoneNumber.contains(query)) {
          _searchResults.add(_FamilySearchResult(
            family: family,
            matchType: _MatchType.head,
            matchedMemberName: null,
          ));
          continue;
        }

        // Check society/area
        if (family.society.toLowerCase().contains(query) ||
            family.area.toLowerCase().contains(query)) {
          _searchResults.add(_FamilySearchResult(
            family: family,
            matchType: _MatchType.head,
            matchedMemberName: null,
          ));
          continue;
        }

        // ✅ Deep search: Check family members
        String? matchedMember;
        for (final member in family.members) {
          if (member.name.toLowerCase().contains(query) ||
              member.phoneNumber.contains(query)) {
            matchedMember = member.name;
            break;
          }
        }

        if (matchedMember != null) {
          _searchResults.add(_FamilySearchResult(
            family: family,
            matchType: _MatchType.member,
            matchedMemberName: matchedMember,
          ));
        }
      }
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Directory'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // ✅ Search bar with cancel button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search by name, phone, or society...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),

                // ✅ Cancel button
                if (_searchQuery.isNotEmpty || _searchFocusNode.hasFocus)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: _clearSearch,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: _loadFamilies,
                        child: _searchResults.isEmpty
                            ? _buildEmptyState()
                            : _buildFamilyList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildFamilyResultCard(result),
        );
      },
    );
  }

  // ✅ Enhanced family card with match indicators
  Widget _buildFamilyResultCard(_FamilySearchResult result) {
    final family = result.family;
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FamilyDetailsScreen(
                familyId: family.id,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CachedAvatar(
                      radius: 30,
                      imageUrl: family.head.profileImage,
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
                                family.head.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            // ✅ Match indicator
                            if (result.matchType == _MatchType.head &&
                                _searchQuery.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  'Head Match',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
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
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${family.society} • ${family.area}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),

              // ✅ Show matched member info
              if (result.matchType == _MatchType.member &&
                  result.matchedMemberName != null) ...[
                Gap.s12H(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'Member Match',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Gap.s8W(),
                      Icon(Icons.person, size: 16, color: Colors.blue[700]),
                      Gap.s4W(),
                      Expanded(
                        child: Text(
                          result.matchedMemberName!,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              Gap.s8H(),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  Gap.s4W(),
                  Text(
                    '${family.totalMembers} members',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isNotEmpty
                    ? Icons.search_off
                    : Icons.people_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              Gap.s16H(),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No families found'
                    : 'No families available',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.grey[600]),
              ),
              if (_searchQuery.isNotEmpty) ...[
                Gap.s8H(),
                Text(
                  'Try searching with different keywords',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          Gap.s16H(),
          Text(
            'Error Loading Families',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.red[700]),
          ),
          Gap.s8H(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Gap.s16H(),
          ElevatedButton.icon(
            onPressed: _loadFamilies,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ✅ Search result model
enum _MatchType { none, head, member }

class _FamilySearchResult {
  final Family family;
  final _MatchType matchType;
  final String? matchedMemberName;

  _FamilySearchResult({
    required this.family,
    required this.matchType,
    this.matchedMemberName,
  });
}
