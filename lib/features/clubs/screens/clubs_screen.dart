import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/club_service.dart';
import '../models/club_model.dart';
import '../widgets/club_widgets.dart';
import 'club_detail_screen.dart';

/// Premium Clubs Screen - Discovery Focused
class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ClubCategory? _selectedCategory;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _autoSeed();
  }
  
  Future<void> _autoSeed() async {
    if (!_seeded) {
      _seeded = true;
      await ClubService.instance.seedClubs();
      await ClubService.instance.seedAdminUsers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.clubsColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.clubsColor,
                      AppColors.clubsColor.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Clubs & Communities',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Find your community',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              if (context.watch<UserProvider>().canCreateClub)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  onPressed: () => _showCreateClubSheet(context),
                  tooltip: 'Create Club',
                ),
              IconButton(
                icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white70),
                tooltip: 'Seed Clubs',
                onPressed: () async {
                  try {
                    await ClubService.instance.seedClubs();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Clubs seeded!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(width: 4),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search clubs...',
                    hintStyle: TextStyle(color: context.appColors.textTertiary, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: context.appColors.textTertiary, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
          ),

          // Category Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip(null, 'All', '🎯'),
                  ...ClubCategory.values.map((cat) => _buildCategoryChip(cat, cat.displayName, cat.icon)),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Clubs Content
          StreamBuilder<List<Club>>(
            stream: ClubService.instance.getClubsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final allClubs = snapshot.data ?? [];
              final filteredClubs = allClubs.where((club) {
                final matchesSearch = _searchQuery.isEmpty ||
                    club.name.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchesCategory = _selectedCategory == null ||
                    club.category == _selectedCategory;
                return matchesSearch && matchesCategory;
              }).toList();

              if (filteredClubs.isEmpty) {
                return SliverFillRemaining(
                  child: ClubEmptyState(
                    icon: Icons.groups_outlined,
                    title: 'No clubs found',
                    subtitle: 'Try adjusting your search or filters',
                  ),
                );
              }

              // Grouped View
              if (_selectedCategory == null && _searchQuery.isEmpty) {
                final Map<ClubCategory, List<Club>> grouped = {};
                for (var cat in ClubCategory.values) {
                  grouped[cat] = [];
                }
                for (var club in filteredClubs) {
                  grouped[club.category]?.add(club);
                }
                grouped.removeWhere((_, v) => v.isEmpty);

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = grouped.keys.elementAt(index);
                      final clubs = grouped[category]!;

                      return _CategorySection(
                        category: category,
                        clubs: clubs,
                        onClubTap: (club) => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
                        ),
                      );
                    },
                    childCount: grouped.length,
                  ),
                );
              }

              // Flat List
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CompactClubTile(
                        club: filteredClubs[index],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ClubDetailScreen(club: filteredClubs[index])),
                        ),
                      ),
                    ),
                    childCount: filteredClubs.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ClubCategory? category, String label, String icon) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.clubsColor : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.clubsColor : context.appColors.divider,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateClubSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateClubSheet(),
    );
  }
}

/// Category Section with vertical club list
class _CategorySection extends StatelessWidget {
  final ClubCategory category;
  final List<Club> clubs;
  final void Function(Club) onClubTap;

  const _CategorySection({
    required this.category,
    required this.clubs,
    required this.onClubTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.clubsColor.withValues(alpha: 0.1),
                AppColors.clubsColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.clubsColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.clubsColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(category.icon, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${clubs.length} ${clubs.length == 1 ? 'club' : 'clubs'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(category.iconData, color: AppColors.clubsColor, size: 24),
            ],
          ),
        ),

        // Clubs in this category
        ...clubs.map((club) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _CompactClubTile(club: club, onTap: () => onClubTap(club)),
        )),
      ],
    );
  }
}

/// Compact Club Tile - Premium design, no overflow
class _CompactClubTile extends StatelessWidget {
  final Club club;
  final VoidCallback onTap;

  const _CompactClubTile({required this.club, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Club Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.clubsColor.withValues(alpha: 0.2),
                    AppColors.clubsColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(club.category.icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            
            // Club Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          club.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (club.isOfficial) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.verified, size: 14, color: AppColors.clubsColor),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    club.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColors.textTertiary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: context.appColors.textTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
