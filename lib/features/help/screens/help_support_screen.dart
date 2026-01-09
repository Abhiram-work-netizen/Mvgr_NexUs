import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/settings_service.dart';
import 'ai_chat_screen.dart';

/// Premium Help & Support Screen
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Quick Actions
          _QuickActionsCard(isDark: isDark),
          const SizedBox(height: 24),

          // FAQs Section
          _SectionHeader(title: 'Frequently Asked Questions', isDark: isDark),
          const SizedBox(height: 12),
          _FAQCard(
            question: 'How do I join a club?',
            answer: 'Go to the Clubs tab, browse available clubs, and tap "Join" on any club you\'re interested in. Some clubs may require approval.',
            isDark: isDark,
          ),
          _FAQCard(
            question: 'How do I find a study buddy?',
            answer: 'Navigate to Study Buddy from the home screen, browse requests by topic, or create your own request specifying subject and preferred times.',
            isDark: isDark,
          ),
          _FAQCard(
            question: 'How do I report lost items?',
            answer: 'Go to Lost & Found, tap "Report Item", select whether you lost or found it, and fill in the details with location and description.',
            isDark: isDark,
          ),
          _FAQCard(
            question: 'How do I request mentorship?',
            answer: 'Visit the Mentorship section, browse available mentors by area, view their profile, and send a mentorship request with your goals.',
            isDark: isDark,
          ),
          _FAQCard(
            question: 'How do I change my notification settings?',
            answer: 'Go to Profile > Settings > Notifications. You can toggle individual notification types on or off.',
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Contact Section
          _SectionHeader(title: 'Contact Us', isDark: isDark),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@mvgrnexus.edu.in',
            color: AppColors.info,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening email client...')),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.bug_report_outlined,
            title: 'Report a Bug',
            subtitle: 'Help us improve the app',
            color: AppColors.warning,
            onTap: () => _showBugReportSheet(context, isDark),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.lightbulb_outline,
            title: 'Suggest a Feature',
            subtitle: 'We\'d love to hear your ideas',
            color: AppColors.success,
            onTap: () => _showFeatureRequestSheet(context, isDark),
            isDark: isDark,
          ),
          const SizedBox(height: 32),

          // App Info
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.school, color: AppColors.primary, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'MVGR NexUs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0 Beta',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textTertiaryDark : context.appColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with ❤️ for MVGR Students',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textTertiaryDark : context.appColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showBugReportSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FeedbackSheet(
        title: 'Report a Bug',
        hintText: 'Describe the issue you encountered...',
        buttonText: 'Submit Report',
        buttonColor: AppColors.warning,
        onSubmit: (title, description) {
          FeedbackService.instance.submitBugReport(
            userId: context.read<UserProvider>().userId,
            title: title,
            description: description,
          );
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bug report submitted. Thank you!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
        isDark: isDark,
      ),
    );
  }

  void _showFeatureRequestSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FeedbackSheet(
        title: 'Suggest a Feature',
        hintText: 'Describe your feature idea...',
        buttonText: 'Submit Suggestion',
        buttonColor: AppColors.success,
        onSubmit: (title, description) {
          FeedbackService.instance.submitFeatureRequest(
            userId: context.read<UserProvider>().userId,
            title: title,
            description: description,
          );
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feature suggestion submitted. Thank you!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
        isDark: isDark,
      ),
    );
  }
}

/// Quick Actions Card
class _QuickActionsCard extends StatelessWidget {
  final bool isDark;

  const _QuickActionsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need Help?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'We\'re here to help you get the most out of NexUs',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Live Chat',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AIChatScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quick Action Button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : context.appColors.textPrimary,
      ),
    );
  }
}

/// FAQ Card
class _FAQCard extends StatefulWidget {
  final String question;
  final String answer;
  final bool isDark;

  const _FAQCard({
    required this.question,
    required this.answer,
    required this.isDark,
  });

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isDark ? AppColors.dividerDark : context.appColors.divider,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark ? AppColors.textPrimaryDark : context.appColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.isDark ? AppColors.textTertiaryDark : context.appColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.isDark ? AppColors.textSecondaryDark : context.appColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Contact Card
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : context.appColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textPrimaryDark : context.appColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textTertiaryDark : context.appColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.textTertiaryDark : context.appColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Feedback Sheet
class _FeedbackSheet extends StatefulWidget {
  final String title;
  final String hintText;
  final String buttonText;
  final Color buttonColor;
  final Function(String title, String description) onSubmit;
  final bool isDark;

  const _FeedbackSheet({
    required this.title,
    required this.hintText,
    required this.buttonText,
    required this.buttonColor,
    required this.onSubmit,
    required this.isDark,
  });

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: widget.isDark ? AppColors.textPrimaryDark : context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Brief summary',
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: widget.hintText,
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
                    widget.onSubmit(_titleController.text, _descriptionController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(widget.buttonText),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
