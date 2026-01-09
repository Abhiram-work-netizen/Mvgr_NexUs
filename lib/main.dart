import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/user_service.dart';
import 'services/settings_service.dart';
import 'features/home/screens/home_screen.dart';
import 'features/clubs/screens/clubs_screen.dart';
import 'features/events/screens/events_screen.dart';
import 'features/academic_forum/screens/forum_screen.dart';
import 'features/vault/screens/vault_screen.dart';
import 'features/lost_found/screens/lost_found_screen.dart';
import 'features/study_buddy/screens/study_buddy_screen.dart';
import 'features/play_buddy/screens/play_buddy_screen.dart';
import 'features/radio/screens/radio_screen.dart';
import 'features/offline_community/screens/meetups_screen.dart';
import 'features/clubs/screens/clubs_and_communities_screen.dart';
import 'features/academic_forum/screens/academics_hub_screen.dart';
import 'features/mentorship/screens/opportunities_screen.dart';
import 'features/faculty/screens/faculty_dashboard_screen.dart';
// Premium screens
import 'features/profile/screens/profile_screen.dart' as profile;
import 'features/profile/screens/my_clubs_screen.dart';
import 'features/profile/screens/my_events_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/help/screens/help_support_screen.dart';
import 'features/announcements/screens/announcements_screen.dart';
import 'features/mentorship/screens/mentorship_screen.dart';
import 'features/interests/screens/interests_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/council/screens/moderation_dashboard_screen.dart';
// Auth
import 'features/auth/screens/auth_wrapper.dart';
import 'features/auth/screens/auth_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Expects google-services.json on Android)
  await Firebase.initializeApp();
  
  // Configure Firestore for offline persistence (Uber-like capabilities)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  // Load saved settings from SharedPreferences
  await SettingsService.instance.loadFromStorage();
  
  runApp(const MVGRNexUsApp());
}

class MVGRNexUsApp extends StatelessWidget {
  const MVGRNexUsApp({super.key});

  ThemeMode _getThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      // Listen to SettingsService for theme changes
      child: ListenableBuilder(
        listenable: SettingsService.instance,
        builder: (context, _) {
          return MaterialApp(
            title: 'MVGR NexUs',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: _getThemeMode(SettingsService.instance.themeMode),
            home: const AuthWrapper(child: MainNavigationScreen()),
            routes: {
              '/auth': (context) => const AuthScreen(),
              '/clubs': (context) => const ClubsScreen(),
              '/events': (context) => const EventsScreen(),
              '/forum': (context) => const AcademicForumScreen(),
              '/vault': (context) => const VaultScreen(),
              '/lost_found': (context) => const LostFoundScreen(),
              '/study_buddy': (context) => const StudyBuddyScreen(),
              '/teams': (context) => const PlayBuddyScreen(),
              '/radio': (context) => const RadioScreen(),
              '/meetups': (context) => const MeetupsScreen(),
              // Premium screens
              '/announcements': (context) => const AnnouncementsScreen(),
              '/mentorship': (context) => const MentorshipScreen(),
              '/interests': (context) => const InterestsScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/help': (context) => const HelpSupportScreen(),
              '/profile': (context) => const profile.ProfileScreen(),
              '/my_clubs': (context) => const MyClubsScreen(),
              '/my_events': (context) => const MyEventsScreen(),
              '/moderation': (context) => const ModerationDashboardScreen(),
              '/faculty': (context) => const FacultyDashboardScreen(),
              '/search': (context) => const GlobalSearchScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Main screen with bottom navigation
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const ClubsAndCommunitiesScreen(),
    const AcademicsHubScreen(),
    const OpportunitiesScreen(),
    const profile.ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Clubs',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Academics',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'Growth',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}


