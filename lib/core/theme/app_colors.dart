import 'package:flutter/material.dart';

/// MVGR NexUs Premium Color Palette v2.0
/// Modern, Sophisticated, World-Class Design
class AppColors {
  // ============ PRIMARY COLORS ============
  // Deep Indigo - Modern, Professional, Tech-Forward
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF3730A3);
  
  // ============ SECONDARY COLORS ============
  // Warm Slate - Balance, Sophistication
  static const Color secondary = Color(0xFF64748B);
  static const Color secondaryLight = Color(0xFF94A3B8);
  static const Color secondaryDark = Color(0xFF475569);
  
  // ============ ACCENT COLORS ============
  // Vibrant Cyan/Teal - Energy, Innovation
  static const Color accent = Color(0xFF06B6D4);
  static const Color accentLight = Color(0xFF22D3EE);
  static const Color accentDark = Color(0xFF0891B2);
  
  // ============ LIGHT MODE BACKGROUNDS ============
  static const Color backgroundLight = Color(0xFFFAFAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // ============ DARK MODE BACKGROUNDS ============
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  
  // ============ TEXT COLORS - LIGHT MODE ============
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  
  // ============ TEXT COLORS - DARK MODE ============
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF64748B);
  
  // ============ SEMANTIC COLORS ============
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  
  // ============ FEATURE COLORS - Vibrant & Modern ============
  static const Color clubsColor = Color(0xFF8B5CF6);       // Violet
  static const Color eventsColor = Color(0xFFF43F5E);      // Rose
  static const Color forumColor = Color(0xFFA855F7);       // Purple
  static const Color vaultColor = Color(0xFF14B8A6);       // Teal
  static const Color lostFoundColor = Color(0xFFF97316);   // Orange
  static const Color studyBuddyColor = Color(0xFF3B82F6);  // Blue
  static const Color playBuddyColor = Color(0xFF22C55E);   // Green
  static const Color radioColor = Color(0xFFEC4899);       // Pink
  static const Color mentorshipColor = Color(0xFF8B5CF6);  // Violet
  static const Color meetupsColor = Color(0xFFEAB308);     // Yellow
  static const Color announcementsColor = Color(0xFF6366F1); // Indigo
  static const Color interestsColor = Color(0xFF14B8A6);   // Teal
  
  // ============ PREMIUM GRADIENTS ============
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF4F46E5),
  ];
  
  static const List<Color> premiumGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFA855F7),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFF22D3EE),
    Color(0xFF06B6D4),
  ];
  
  static const List<Color> warmGradient = [
    Color(0xFFFBBF24),
    Color(0xFFF59E0B),
  ];
  
  static const List<Color> darkGradient = [
    Color(0xFF1E293B),
    Color(0xFF0F172A),
  ];
  
  // Feature gradients
  static const List<Color> clubsGradient = [Color(0xFFA78BFA), Color(0xFF8B5CF6)];
  static const List<Color> eventsGradient = [Color(0xFFFB7185), Color(0xFFF43F5E)];
  static const List<Color> forumGradient = [Color(0xFFC084FC), Color(0xFFA855F7)];
  static const List<Color> vaultGradient = [Color(0xFF2DD4BF), Color(0xFF14B8A6)];
  
  // ============ OVERLAY COLORS ============
  static Color overlayLight = Colors.black.withValues(alpha: 0.04);
  static Color overlayMedium = Colors.black.withValues(alpha: 0.08);
  static Color overlayDark = Colors.black.withValues(alpha: 0.16);
  static Color overlayBlack = Colors.black.withValues(alpha: 0.5);
  
  // ============ DIVIDER COLORS ============
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);
  
  // ============ BORDER COLORS ============
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  
  // ============ GLASS EFFECT COLORS ============
  static Color glassLight = Colors.white.withValues(alpha: 0.8);
  static Color glassDark = const Color(0xFF1E293B).withValues(alpha: 0.8);
}

/// Theme-aware color provider
/// Usage: context.appColors.textPrimary (automatically switches based on theme)
class ThemeColors {
  final bool isDark;
  
  const ThemeColors({required this.isDark});
  
  // Text colors - auto-switch based on theme
  Color get textPrimary => isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary => isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textTertiary => isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
  
  // Background colors
  Color get background => isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surface => isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get card => isDark ? AppColors.cardDark : AppColors.cardLight;
  
  // Divider/Border colors
  Color get divider => isDark ? AppColors.dividerDark : AppColors.dividerLight;
  Color get border => isDark ? AppColors.borderDark : AppColors.borderLight;
  
  // Glass effect
  Color get glass => isDark ? AppColors.glassDark : AppColors.glassLight;
}

/// Extension on BuildContext to easily access theme-aware colors
extension ThemeColorsExtension on BuildContext {
  /// Get theme-aware colors that automatically switch based on current theme
  /// Usage: context.appColors.textPrimary
  ThemeColors get appColors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return ThemeColors(isDark: isDark);
  }
  
  /// Quick access to check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

/// App Typography - Modern & Clean
class AppTypography {
  static const String fontFamily = 'Inter';
  static const String fontFamilyBody = 'Inter';
  
  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.25,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );
  
  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );
  
  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0.1,
  );
}

/// App Spacing - Generous whitespace
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
  
  // Standard paddings
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  
  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  
  // Vertical paddings
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  
  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(16);
  
  // List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );
}

/// App Border Radius - Modern rounded corners
class AppRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 32;
  static const double circular = 100;
  
  static BorderRadius get borderXs => BorderRadius.circular(xs);
  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderXxl => BorderRadius.circular(xxl);
  static BorderRadius get borderCircular => BorderRadius.circular(circular);
  
  static BorderRadius get topLg => const BorderRadius.vertical(
    top: Radius.circular(lg),
  );
  static BorderRadius get topXl => const BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

/// App Shadows - Subtle and elegant
class AppShadows {
  static List<BoxShadow> get none => [];
  
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get xl => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];
  
  // Colored shadows
  static List<BoxShadow> colored(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];
  
  // Glow effect
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
}

/// Animation Durations
class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration page = Duration(milliseconds: 350);
}

/// Animation Curves
class AppCurves {
  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeOutQuart;
  static const Curve sharp = Curves.easeInOutCubic;
}
