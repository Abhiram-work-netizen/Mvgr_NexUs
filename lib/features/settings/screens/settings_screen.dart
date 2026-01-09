import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/settings_service.dart';
import '../../../services/user_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/data_seeder.dart';
import 'package:provider/provider.dart';

/// Premium Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = SettingsService.instance;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Notifications Section
          _SectionHeader(title: 'Notifications', isDark: isDark),
          const SizedBox(height: 12),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SwitchTile(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Receive alerts on your device',
                value: settings.pushNotifications,
                onChanged: (v) => setState(() => settings.pushNotifications = v),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SwitchTile(
                icon: Icons.event,
                title: 'Event Reminders',
                subtitle: 'Get notified about upcoming events',
                value: settings.eventReminders,
                onChanged: (v) => setState(() => settings.eventReminders = v),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SwitchTile(
                icon: Icons.message,
                title: 'Club Updates',
                subtitle: 'News from clubs you follow',
                value: settings.clubUpdates,
                onChanged: (v) => setState(() => settings.clubUpdates = v),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SwitchTile(
                icon: Icons.campaign,
                title: 'Announcements',
                subtitle: 'Important campus announcements',
                value: settings.announcements,
                onChanged: (v) => setState(() => settings.announcements = v),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _SectionHeader(title: 'Appearance', isDark: isDark),
          const SizedBox(height: 12),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SelectionTile(
                icon: Icons.dark_mode,
                title: 'Theme',
                subtitle: settings.themeMode.displayName,
                onTap: () => _showThemeSelector(context, settings),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SwitchTile(
                icon: Icons.animation,
                title: 'Animations',
                subtitle: 'Enable smooth transitions',
                value: settings.enableAnimations,
                onChanged: (v) => setState(() => settings.enableAnimations = v),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SwitchTile(
                icon: Icons.touch_app,
                title: 'Haptic Feedback',
                subtitle: 'Vibration on interactions',
                value: settings.hapticFeedback,
                onChanged: (v) => setState(() => settings.hapticFeedback = v),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Privacy Section
          _SectionHeader(title: 'Privacy', isDark: isDark),
          const SizedBox(height: 12),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SwitchTile(
                icon: Icons.visibility,
                title: 'Profile Visibility',
                subtitle: 'Show profile to other students',
                value: settings.profileVisible,
                onChanged: (v) => setState(() => settings.profileVisible = v),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SwitchTile(
                icon: Icons.location_on,
                title: 'Show Activity Status',
                subtitle: 'Let others see when you\'re online',
                value: settings.showActivityStatus,
                onChanged: (v) => setState(() => settings.showActivityStatus = v),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SwitchTile(
                icon: Icons.analytics,
                title: 'Analytics',
                subtitle: 'Help improve the app',
                value: settings.analyticsEnabled,
                onChanged: (v) => setState(() => settings.analyticsEnabled = v),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Data Section
          _SectionHeader(title: 'Data & Storage', isDark: isDark),
          const SizedBox(height: 12),
          _SettingsCard(
            isDark: isDark,
            children: [
              _ActionTile(
                icon: Icons.cached,
                title: 'Clear Cache',
                subtitle: '${settings.cacheSize} MB used',
                actionText: 'Clear',
                onTap: () => _clearCache(context, settings),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _ActionTile(
                icon: Icons.download,
                title: 'Download Data',
                subtitle: 'Export your data',
                actionText: 'Download',
                onTap: () => _downloadData(context),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About Section
          _SectionHeader(title: 'About', isDark: isDark),
          const SizedBox(height: 12),
          _SettingsCard(
            isDark: isDark,
            children: [
              _InfoTile(
                icon: Icons.info,
                title: 'Version',
                value: '1.0.0 Beta',
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SelectionTile(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () => _showTerms(context),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SelectionTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () => _showPrivacyPolicy(context),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SelectionTile(
                icon: Icons.code,
                title: 'Open Source Licenses',
                onTap: () => showLicensePage(context: context),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Demo Mode Section - For Hackathon Testing
          _SectionHeader(title: '🎮 Demo Mode (Hackathon)', isDark: isDark),
          const SizedBox(height: 12),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SelectionTile(
                icon: Icons.swap_horiz,
                title: 'Switch Role',
                subtitle: context.watch<UserProvider>().userRole.displayName,
                onTap: () => _showRoleSwitcher(context),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SelectionTile(
                icon: Icons.admin_panel_settings,
                title: 'Moderation Hub',
                onTap: () => Navigator.pushNamed(context, '/moderation'),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _SelectionTile(
                icon: Icons.school,
                title: 'Faculty Portal',
                onTap: () => Navigator.pushNamed(context, '/faculty'),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _ActionTile(
                icon: Icons.dataset,
                title: 'Seed Demo Data',
                subtitle: 'Populate app with sample data',
                actionText: 'Seed',
                onTap: () => _seedDemoData(context),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _ActionTile(
                icon: Icons.delete_sweep,
                title: 'Clear All Data',
                subtitle: 'Remove all seeded data',
                actionText: 'Clear',
                actionColor: AppColors.warning,
                onTap: () => _clearAllData(context),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Account Section
          _SectionHeader(title: 'Account', isDark: isDark),
          const SizedBox(height: 12),
          _SettingsCard(
            isDark: isDark,
            children: [
              _ActionTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your profile information',
                actionText: 'Edit',
                onTap: () {
                  Navigator.pop(context); // Go back to profile
                },
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _ActionTile(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Log out of your account',
                actionText: 'Logout',
                onTap: () => _signOut(context),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),
              _ActionTile(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently remove your account',
                actionText: 'Delete',
                actionColor: AppColors.error,
                onTap: () => _deleteAccount(context),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _seedDemoData(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Seeding demo data...'),
          ],
        ),
      ),
    );

    try {
      await DataSeeder.instance.seedAll();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo data seeded successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will remove all seeded demo data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Clearing data...'),
                    ],
                  ),
                ),
              );
              
              try {
                await DataSeeder.instance.clearAllData();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, SettingsService settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Theme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            ...AppThemeMode.values.map((mode) => ListTile(
              leading: Icon(
                mode == AppThemeMode.light 
                    ? Icons.light_mode 
                    : mode == AppThemeMode.dark 
                        ? Icons.dark_mode 
                        : Icons.brightness_auto,
                color: settings.themeMode == mode ? AppColors.primary : null,
              ),
              title: Text(mode.displayName),
              trailing: settings.themeMode == mode 
                  ? Icon(Icons.check_circle, color: AppColors.primary) 
                  : null,
              onTap: () {
                setState(() => settings.themeMode = mode);
                Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _clearCache(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache'),
        content: Text('This will free up ${settings.cacheSize} MB of storage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => settings.clearCache());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _downloadData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing your data download...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showTerms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _LegalDocScreen(title: 'Terms of Service')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _LegalDocScreen(title: 'Privacy Policy')),
    );
  }

  void _showRoleSwitcher(BuildContext context) {
    final roles = [
      (UserRole.student, Icons.school_outlined, 'Student', 'Browse clubs, RSVP events'),
      (UserRole.communityAdmin, Icons.groups, 'Community Admin', 'Manage assigned clubs'),
      (UserRole.overallAdmin, Icons.admin_panel_settings, 'Overall Admin', 'Full system access'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '🎭 Switch Role',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DEMO MODE',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Test different user experiences for hackathon judges',
              style: TextStyle(
                fontSize: 13,
                color: context.appColors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            ...roles.map((role) {
              final isSelected = context.watch<UserProvider>().userRole == role.$1;
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withValues(alpha: 0.1) 
                        : context.appColors.divider.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    role.$2,
                    color: isSelected ? AppColors.primary : context.appColors.textSecondary,
                  ),
                ),
                title: Text(
                  role.$3,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : null,
                  ),
                ),
                subtitle: Text(role.$4),
                trailing: isSelected 
                    ? Icon(Icons.check_circle, color: AppColors.primary) 
                    : null,
                onTap: () {
                  context.read<UserProvider>().updateRole(role.$1);
                  Navigator.pop(ctx);
                  // setState not needed if using context.watch/consumer, but here we are in a modal.
                  // The parent screen will rebuild if it watches.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Switched to ${role.$3} role'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion requested (demo mode)'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Account'),
          ),
        ],
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
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textSecondaryDark : context.appColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Settings Card
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.dividerDark : context.appColors.divider),
      ),
      child: Column(children: children),
    );
  }
}

/// Switch Tile
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Selection Tile
class _SelectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _SelectionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : context.appColors.textPrimary,
                ),
              ),
            ),
            if (subtitle != null) ...[
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, color: isDark ? AppColors.textTertiaryDark : context.appColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Action Tile
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionText;
  final Color? actionColor;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionText,
    this.actionColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (actionColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: actionColor ?? AppColors.primary, size: 20),
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
          TextButton(
            onPressed: onTap,
            child: Text(
              actionText,
              style: TextStyle(
                color: actionColor ?? AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Info Tile
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDark;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textPrimaryDark : context.appColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textTertiaryDark : context.appColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Divider
class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.dividerDark : context.appColors.divider,
      ),
    );
  }
}

/// Legal Document Screen
class _LegalDocScreen extends StatelessWidget {
  final String title;

  const _LegalDocScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: December 24, 2024',
            style: TextStyle(
              fontSize: 13,
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'This document outlines the terms and conditions for using MVGR NexUs. '
            'By using this application, you agree to these terms.\n\n'
            '1. USER ACCOUNTS\n'
            'You must be a valid MVGR student, faculty, or staff member to use this app. '
            'You are responsible for maintaining the confidentiality of your account.\n\n'
            '2. ACCEPTABLE USE\n'
            'You agree to use the app only for lawful purposes and in accordance with '
            'college policies. Harassment, spam, or inappropriate content is prohibited.\n\n'
            '3. PRIVACY\n'
            'We collect minimal data necessary for app functionality. Your data is stored '
            'securely and never sold to third parties.\n\n'
            '4. CONTENT\n'
            'You retain rights to content you post, but grant us license to display it '
            'within the app. Moderators may remove inappropriate content.\n\n'
            '5. CHANGES\n'
            'We may update these terms periodically. Continued use constitutes acceptance '
            'of any changes.',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
