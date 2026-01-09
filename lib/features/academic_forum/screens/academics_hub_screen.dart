import 'package:flutter/material.dart';
import '../../vault/screens/vault_screen.dart';
import '../../study_buddy/screens/study_buddy_screen.dart';
import 'forum_screen.dart';
import '../../../core/theme/app_colors.dart';

class AcademicsHubScreen extends StatelessWidget {
  const AcademicsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academics Hub'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HubCard(
            title: 'The Vault',
            subtitle: 'Access notes, PYQs, and academic resources',
            icon: Icons.folder_shared_outlined,
            color: AppColors.vaultColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VaultScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _HubCard(
            title: 'Academic Forum',
            subtitle: 'Ask questions, discuss topics, and help others',
            icon: Icons.forum_outlined,
            color: AppColors.forumColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AcademicForumScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _HubCard(
            title: 'Study Buddy',
            subtitle: 'Find peers for group study and collaboration',
            icon: Icons.school_outlined,
            color: AppColors.studyBuddyColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudyBuddyScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HubCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
