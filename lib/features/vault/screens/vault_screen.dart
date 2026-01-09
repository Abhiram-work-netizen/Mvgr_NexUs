import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/user_service.dart';
import '../../../services/vault_service.dart';
import '../models/vault_model.dart';
import '../data/vault_data.dart';

/// Premium Vault Screen - Library-like aesthetic
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // Community Tab State
  String _searchQuery = '';
  String? _selectedBranch;
  String? _selectedYear;
  String? _selectedType;

  // Regulation Tab State
  bool _isR24Selected = true; // Toggle for R24/R23

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Switch to Community tab and show upload
          _tabController.animateTo(2); 
          _showUploadSheet(context);
        },
        backgroundColor: AppColors.vaultColor,
        icon: const Icon(Icons.upload),
        label: const Text('Upload Notes'),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.vaultColor,
                      AppColors.vaultColor.withValues(alpha: 0.85),
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.library_books,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'The Vault',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Academic regulations, notes & resources',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                height: 48,
                alignment: Alignment.bottomCenter,
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 3, color: Colors.white),
                    insets: EdgeInsets.only(bottom: 4),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Regulations'),
                    Tab(text: 'Subjects'),
                    Tab(text: 'Community'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildRegulationsTab(),
            _buildSubjectNotesTab(),
            _buildCommunityTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegulationsTab() {
    final regulations = _isR24Selected ? VaultData.r24Regulations : VaultData.r23Regulations;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle R24/R23
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _RegulationToggle(
                    label: 'R24 Regulation',
                    isSelected: _isR24Selected,
                    onTap: () => setState(() => _isR24Selected = true),
                  ),
                ),
                Expanded(
                  child: _RegulationToggle(
                    label: 'R23 Regulation',
                    isSelected: !_isR24Selected,
                    onTap: () => setState(() => _isR24Selected = false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Syllabus & Regulations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: regulations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final dept = regulations.keys.elementAt(index);
              final url = regulations.values.elementAt(index);
              return _OfficialResourceTile(
                title: '$dept Syllabus',
                subtitle: _isR24Selected ? 'R24 Regulation' : 'R23 Regulation',
                icon: Icons.picture_as_pdf,
                color: AppColors.error, // Red for PDF
                onTap: () => _launchUrl(url),
              );
            },
          ),
          const SizedBox(height: 80), // Fab spacing
        ],
      ),
    );
  }

  Widget _buildSubjectNotesTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Materials',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Access complete notes via Google Drive folders',
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: VaultData.subjectNotes.length,
            itemBuilder: (context, index) {
              final subject = VaultData.subjectNotes.keys.elementAt(index);
              final url = VaultData.subjectNotes.values.elementAt(index);
              return _SubjectFolderCard(
                title: subject,
                onTap: () => _launchUrl(url),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    return CustomScrollView(
      key: const PageStorageKey('CommunityTab'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.appColors.divider),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search community uploads...',
                      hintStyle: TextStyle(color: context.appColors.textTertiary),
                      prefixIcon: Icon(Icons.search, color: context.appColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                       _FilterChip(
                          label: _selectedBranch ?? 'Branch',
                          isSelected: _selectedBranch != null,
                          onTap: () => _showBranchPicker(),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: _selectedYear ?? 'Year',
                          isSelected: _selectedYear != null,
                          onTap: () => _showYearPicker(),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: _selectedType ?? 'Type',
                          isSelected: _selectedType != null,
                          onTap: () => _showTypePicker(),
                        ),
                        if (_selectedBranch != null || _selectedYear != null || _selectedType != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedBranch = null;
                              _selectedYear = null;
                              _selectedType = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                        ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Resources List
        StreamBuilder<List<VaultItem>>(
          stream: VaultService.instance.getVaultItemsStream(
            branch: _selectedBranch,
            year: _selectedYear != null ? int.tryParse(_selectedYear!.replaceAll(RegExp(r'[^0-9]'), '')) : null,
            type: _selectedType != null ? VaultItemType.values.firstWhere((e) => e.displayName == _selectedType, orElse: () => VaultItemType.other) : null,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return SliverFillRemaining(child: Center(child: Text('Error: ${snapshot.error}')));
            }

            final allItems = snapshot.data ?? [];
            var items = allItems.where((item) {
              final matchesSearch = _searchQuery.isEmpty ||
                  item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  item.subject.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesSearch;
            }).toList();

            if (items.isEmpty) {
              return SliverFillRemaining(
                child: _EmptyState(
                  icon: Icons.folder_open_outlined,
                  title: 'No community notes found',
                  subtitle: 'Be the first to upload!',
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ResourceCard(item: items[index]),
                  ),
                  childCount: items.length,
                ),
              ),
            );
          },
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  void _showBranchPicker() {
    _showPickerSheet(
      context: context,
      title: 'Select Branch',
      options: ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT'],
      currentValue: _selectedBranch,
      onSelect: (value) => setState(() => _selectedBranch = value),
    );
  }

  void _showYearPicker() {
    _showPickerSheet(
      context: context,
      title: 'Select Year',
      options: ['1st Year', '2nd Year', '3rd Year', '4th Year'],
      currentValue: _selectedYear,
      onSelect: (value) => setState(() => _selectedYear = value),
    );
  }

  void _showTypePicker() {
    _showPickerSheet(
      context: context,
      title: 'Select Type',
      options: VaultItemType.values.map((t) => t.displayName).toList(),
      currentValue: _selectedType,
      onSelect: (value) => setState(() => _selectedType = value),
    );
  }

  void _showPickerSheet({
    required BuildContext context,
    required String title,
    required List<String> options,
    String? currentValue,
    required void Function(String?) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.appColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return ListTile(
                    title: Text(option),
                    trailing: currentValue == option
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      onSelect(currentValue == option ? null : option);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _UploadSheet(),
    );
  }
}

/// Helper Widgets
class _RegulationToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegulationToggle({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vaultColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.appColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OfficialResourceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OfficialResourceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.appColors.divider.withValues(alpha: 0.5)),
      ),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

class _SubjectFolderCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SubjectFolderCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.vaultColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder, size: 48, color: AppColors.vaultColor.withValues(alpha: 0.8)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter Chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.appColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : context.appColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isSelected ? Colors.white : context.appColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Resource Card
class _ResourceCard extends StatelessWidget {
  final VaultItem item;

  const _ResourceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getTypeColor(item.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(item.type),
                    color: _getTypeColor(item.type),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subject,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Tag(label: item.branch, color: AppColors.clubsColor),
                _Tag(label: 'Year ${item.year}', color: AppColors.eventsColor),
                _Tag(label: item.type.displayName, color: _getTypeColor(item.type)),
              ],
            ),
            const SizedBox(height: 14),
            
            // Footer
            Row(
              children: [
                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Downloads
                Row(
                  children: [
                    Icon(Icons.download_outlined, size: 16, color: context.appColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${item.downloadCount}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Delete Button (only if uploader)
                if (context.watch<UserProvider>().currentUser?.uid == item.uploaderId)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Resource'),
                            content: const Text('Are you sure you want to delete this resource?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await VaultService.instance.deleteVaultItem(
                              item.id,
                              context.read<UserProvider>().currentUser!.uid,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Resource deleted')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      tooltip: 'Delete',
                    ),
                  ),
                // Download Button
                TextButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(item.fileUrl);
                    if (await canLaunchUrl(uri)) {
                       await launchUrl(uri, mode: LaunchMode.externalApplication);
                       await VaultService.instance.incrementDownloadCount(item.id);
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch file URL')),
                      );
                    }
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(VaultItemType type) {
    switch (type) {
      case VaultItemType.notes:
        return AppColors.forumColor;
      case VaultItemType.pyq:
        return AppColors.eventsColor;
      case VaultItemType.handwritten:
        return AppColors.clubsColor;
      case VaultItemType.assignment:
        return AppColors.studyBuddyColor;
      case VaultItemType.slides:
        return AppColors.vaultColor;
      case VaultItemType.lab:
        return AppColors.playBuddyColor;
      case VaultItemType.other:
        return AppColors.textSecondaryLight;
    }
  }

  IconData _getTypeIcon(VaultItemType type) {
    switch (type) {
      case VaultItemType.notes:
        return Icons.note_outlined;
      case VaultItemType.pyq:
        return Icons.assignment_outlined;
      case VaultItemType.handwritten:
        return Icons.draw_outlined;
      case VaultItemType.assignment:
        return Icons.edit_document;
      case VaultItemType.slides:
        return Icons.slideshow_outlined;
      case VaultItemType.lab:
        return Icons.science_outlined;
      case VaultItemType.other:
        return Icons.folder_outlined;
    }
  }
}

/// Tag
class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/// Empty State
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: context.appColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Upload Sheet
class _UploadSheet extends StatefulWidget {
  const _UploadSheet();

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _driveUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _branch = 'CSE';
  String _year = '1st Year';
  int _semester = 1;
  VaultItemType _type = VaultItemType.notes;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _driveUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Validate Google Drive link format
  String? _validateDriveUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Google Drive link is required';
    }
    // Accept various Google Drive URL formats
    if (!value.contains('drive.google.com') && 
        !value.contains('docs.google.com')) {
      return 'Please enter a valid Google Drive link';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.appColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Share a Resource',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share your notes via Google Drive link',
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textTertiary,
                ),
              ),
              const SizedBox(height: 24),

              // Google Drive Link Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.vaultColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.vaultColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.vaultColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.network(
                        'https://ssl.gstatic.com/docs/doclist/images/drive_2022q3_32dp.png',
                        width: 28,
                        height: 28,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.folder_shared,
                          color: AppColors.vaultColor,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Drive',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Paste your shareable Drive link',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.appColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Drive URL field
              TextFormField(
                controller: _driveUrlController,
                validator: _validateDriveUrl,
                decoration: InputDecoration(
                  hintText: 'https://drive.google.com/file/d/...',
                  hintStyle: TextStyle(color: context.appColors.textTertiary),
                  prefixIcon: Icon(Icons.link, color: context.appColors.textTertiary),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.appColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.appColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.vaultColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Form Fields
              _FormField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g. Data Structures Notes - Unit 1',
                validator: (v) => v?.isEmpty ?? true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              
              _FormField(
                controller: _subjectController,
                label: 'Subject',
                hint: 'e.g. Data Structures',
                validator: (v) => v?.isEmpty ?? true ? 'Subject is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief description of the resource...',
                  hintStyle: TextStyle(color: context.appColors.textTertiary),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.appColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.appColors.divider),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _DropdownField(
                      label: 'Branch',
                      value: _branch,
                      items: ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT'],
                      onChanged: (v) => setState(() => _branch = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DropdownField(
                      label: 'Year',
                      value: _year,
                      items: ['1st Year', '2nd Year', '3rd Year', '4th Year'],
                      onChanged: (v) => setState(() => _year = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DropdownField<int>(
                      label: 'Semester',
                      value: _semester,
                      items: [1, 2],
                      displayBuilder: (v) => 'Sem $v',
                      onChanged: (v) => setState(() => _semester = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _DropdownField<VaultItemType>(
                label: 'Type',
                value: _type,
                items: VaultItemType.values,
                displayBuilder: (v) => v.displayName,
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 24),
              
              // Upload Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isLoading ? 'Sharing...' : 'Share Resource'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vaultColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = context.read<UserProvider>().currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to share resources'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      
      try {
        // Extract or clean up the Drive URL
        final driveUrl = _driveUrlController.text.trim();
        
        // Create Item with Drive URL
        final item = VaultItem(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          subject: _subjectController.text.trim(),
          branch: _branch,
          year: int.tryParse(_year.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1,
          semester: _semester,
          type: _type,
          uploaderId: user.uid,
          uploaderName: user.name,
          fileUrl: driveUrl,
          fileName: 'Google Drive Link',
          fileSizeBytes: 0, // Not applicable for Drive links
          createdAt: DateTime.now(),
        );

        await VaultService.instance.createVaultItem(item);
        
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resource shared successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
         setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error: $e'),
             backgroundColor: AppColors.error,
           ),
         );
      }
    }
  }
}

/// Form Field
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.appColors.textTertiary),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.appColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.appColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

/// Dropdown Field
class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T)? displayBuilder;
  final void Function(T?) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    this.displayBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.appColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(12),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(displayBuilder?.call(item) ?? item.toString()),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
