import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../models/interests_model.dart';

/// Premium Interests Selection Screen - Onboarding/Profile Setup
class InterestsScreen extends StatefulWidget {
  final bool isOnboarding;
  
  const InterestsScreen({super.key, this.isOnboarding = false});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selectedInterests = {};
  int _currentCategory = 0;

  final List<_InterestCategory> _categories = [
    _InterestCategory(
      name: 'Tech & Academic',
      icon: Icons.code,
      interests: [
        'Programming', 'Machine Learning', 'Web Development', 'Mobile Development',
        'Data Science', 'Cybersecurity', 'Cloud Computing', 'Robotics', 'IoT', 'Blockchain',
      ],
    ),
    _InterestCategory(
      name: 'Creative',
      icon: Icons.palette,
      interests: [
        'Music', 'Dance', 'Art & Design', 'Photography',
        'Video Editing', 'Writing', 'Content Creation',
      ],
    ),
    _InterestCategory(
      name: 'Sports & Fitness',
      icon: Icons.sports_soccer,
      interests: [
        'Cricket', 'Football', 'Basketball', 'Badminton',
        'Table Tennis', 'Chess', 'Athletics', 'Fitness',
      ],
    ),
    _InterestCategory(
      name: 'Gaming',
      icon: Icons.gamepad,
      interests: ['E-Sports', 'PC Gaming', 'Mobile Gaming', 'Board Games'],
    ),
    _InterestCategory(
      name: 'Entertainment',
      icon: Icons.movie,
      interests: ['Movies', 'Anime', 'Reading', 'Podcasts'],
    ),
    _InterestCategory(
      name: 'Social & Leadership',
      icon: Icons.groups,
      interests: [
        'Public Speaking', 'Debate', 'Event Management',
        'Volunteering', 'Entrepreneurship',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select user's existing interests if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userInterests = context.read<UserProvider>().user.interests;
      if (userInterests.isNotEmpty) {
        setState(() {
          _selectedInterests.addAll(userInterests);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _Header(
              isOnboarding: widget.isOnboarding,
              selectedCount: _selectedInterests.length,
            ),

            // Category Tabs
            _CategoryTabs(
              categories: _categories,
              currentIndex: _currentCategory,
              onTap: (index) => setState(() => _currentCategory = index),
            ),

            // Interests Grid
            Expanded(
              child: _InterestsGrid(
                interests: _categories[_currentCategory].interests,
                selectedInterests: _selectedInterests,
                onToggle: (interest) {
                  setState(() {
                    if (_selectedInterests.contains(interest)) {
                      _selectedInterests.remove(interest);
                    } else if (_selectedInterests.length < 10) {
                      _selectedInterests.add(interest);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Maximum 10 interests allowed'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    }
                  });
                },
              ),
            ),

            // Save Button
            _SaveButton(
              count: _selectedInterests.length,
              isValid: _selectedInterests.length >= 3,
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_selectedInterests.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 3 interests'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Update user interests
    context.read<UserProvider>().updateInterests(_selectedInterests.toList());

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Interests updated!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

/// Header
class _Header extends StatelessWidget {
  final bool isOnboarding;
  final int selectedCount;

  const _Header({required this.isOnboarding, required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!isOnboarding)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.appColors.divider,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.arrow_back, size: 20, color: context.appColors.textPrimary),
                  ),
                ),
              if (!isOnboarding) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnboarding ? 'What are you into?' : 'Your Interests',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnboarding 
                          ? 'Select 3-10 interests for personalized recommendations'
                          : 'Edit your interests',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selectedCount >= 3 
                      ? AppColors.success.withValues(alpha: 0.1)
                      : context.appColors.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$selectedCount/10',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selectedCount >= 3 
                        ? AppColors.success 
                        : context.appColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Category Tabs
class _CategoryTabs extends StatelessWidget {
  final List<_InterestCategory> categories;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CategoryTabs({
    required this.categories,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              margin: EdgeInsets.only(right: index < categories.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.primary : context.appColors.divider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 16,
                    color: isSelected ? Colors.white : context.appColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Interests Grid
class _InterestsGrid extends StatelessWidget {
  final List<String> interests;
  final Set<String> selectedInterests;
  final ValueChanged<String> onToggle;

  const _InterestsGrid({
    required this.interests,
    required this.selectedInterests,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: interests.map((interest) {
          final isSelected = selectedInterests.contains(interest);
          return GestureDetector(
            onTap: () => onToggle(interest),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : context.appColors.divider,
                  width: 1.5,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Interests.getIcon(interest),
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    interest,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : context.appColors.textPrimary,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.check_circle, size: 16, color: Colors.white),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Save Button
class _SaveButton extends StatelessWidget {
  final int count;
  final bool isValid;
  final VoidCallback onSave;

  const _SaveButton({
    required this.count,
    required this.isValid,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (count < 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text(
                    'Select ${3 - count} more interest${3 - count != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isValid ? onSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: context.appColors.divider,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                count >= 3 ? 'Save Interests' : 'Select at least 3',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isValid ? Colors.white : context.appColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interest Category
class _InterestCategory {
  final String name;
  final IconData icon;
  final List<String> interests;

  const _InterestCategory({
    required this.name,
    required this.icon,
    required this.interests,
  });
}
