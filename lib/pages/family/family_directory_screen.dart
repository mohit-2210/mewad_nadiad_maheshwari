import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/models/family.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:mmsn/data_service.dart';
import 'package:mmsn/components/family_card.dart';
import 'package:mmsn/pages/family/family_details_screen.dart';

@NowaGenerated()
class FamilyDirectoryScreen extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const FamilyDirectoryScreen({super.key});

  @override
  State<FamilyDirectoryScreen> createState() {
    return _FamilyDirectoryScreenState();
  }
}

@NowaGenerated()
class _FamilyDirectoryScreenState extends State<FamilyDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Family> _allFamilies = [];

  List<Family> _filteredFamilies = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFamilies();
    _searchController.addListener(_filterFamilies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilies() async {
    try {
      final families = await DataService.instance.getFamilies();
      setState(() {
        _allFamilies = families;
        _filteredFamilies = families;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterFamilies() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredFamilies = _allFamilies;
      });
    } else {
      setState(() {
        _filteredFamilies = _allFamilies
            .where(
              (family) =>
                  family.head.fullName.toLowerCase().contains(query) ||
                  family.head.phoneNumber.contains(query) ||
                  family.society.toLowerCase().contains(query) ||
                  family.area.toLowerCase().contains(query),
            )
            .toList();
      });
    }
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or society...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadFamilies,
                    child: _filteredFamilies.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchController.text.isNotEmpty
                                      ? Icons.search_off
                                      : Icons.people_outline,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                Gap.s16H(),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'No families found'
                                      : 'No families available',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                if (_searchController.text.isNotEmpty) ...[
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
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredFamilies.length,
                            itemBuilder: (context, index) {
                              final family = _filteredFamilies[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: FamilyCard(
                                  family: family,
                                  heroTagPrefix: 'directory_family',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FamilyDetailsScreen(
                                              familyId: family.id,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
