import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Light Theme for MVGR NexUs - Premium Modern Design
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: AppTypography.fontFamily,
  
  // Color scheme - Modern Indigo
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.accentLight,
    tertiary: AppColors.accent,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    error: AppColors.error,
    onError: Colors.white,
  ),
  
  // Scaffold
  scaffoldBackgroundColor: AppColors.backgroundLight,
  
  // AppBar
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.surfaceLight,
    foregroundColor: AppColors.textPrimaryLight,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryLight,
    ),
  ),
  
  // Cards
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.cardLight,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderMd,
    ),
    clipBehavior: Clip.antiAlias,
  ),
  
  // Page transitions - smooth slide and fade
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
    },
  ),
  
  // Elevated Button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
      ),
      textStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Outlined Button
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
      ),
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      textStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Text Button
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Floating Action Button
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderLg,
    ),
  ),
  
  // Input Decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.backgroundLight,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    hintStyle: TextStyle(
      color: AppColors.textTertiaryLight.withValues(alpha: 0.8),
    ),
  ),
  
  // Chip
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.backgroundLight,
    selectedColor: AppColors.primaryLight,
    labelStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 12,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderSm,
    ),
  ),
  
  // BottomNavigationBar
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textTertiaryLight,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  
  // Tab Bar
  tabBarTheme: const TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondaryLight,
    indicatorColor: AppColors.primary,
    dividerColor: Colors.transparent,
    labelStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
  ),
  
  // Divider
  dividerTheme: const DividerThemeData(
    color: AppColors.dividerLight,
    thickness: 1,
    space: 1,
  ),
  
  // List Tile
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderMd,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  ),
  
  // Dialog
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surfaceLight,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderLg,
    ),
  ),
  
  // Snackbar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.textPrimaryLight,
    contentTextStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      color: Colors.white,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderMd,
    ),
    behavior: SnackBarBehavior.floating,
  ),
  
  // Bottom Sheet
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surfaceLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),
);

/// Dark Theme for MVGR NexUs - Premium Dark Mode
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: AppTypography.fontFamily,
  
  // Color scheme - Modern Dark with Cyan accent
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primary,
    secondary: AppColors.accent,
    onSecondary: Colors.black,
    secondaryContainer: AppColors.accentDark,
    tertiary: AppColors.accent,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    error: AppColors.errorLight,
    onError: Colors.black,
  ),
  
  // Scaffold
  scaffoldBackgroundColor: AppColors.backgroundDark,
  
  // AppBar
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textPrimaryDark,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
    ),
  ),
  
  // Cards
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.cardDark,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderMd,
    ),
    clipBehavior: Clip.antiAlias,
  ),
  
  // Page transitions
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
    },
  ),
  
  // Elevated Button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
      ),
      textStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Outlined Button
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
      ),
      side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      textStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Text Button
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Floating Action Button
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderLg,
    ),
  ),
  
  // Input Decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.cardDark,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: const BorderSide(color: AppColors.borderDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.borderMd,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    hintStyle: TextStyle(
      color: AppColors.textTertiaryDark.withValues(alpha: 0.8),
    ),
  ),
  
  // Chip
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.cardDark,
    selectedColor: AppColors.primaryDark,
    labelStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 12,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderSm,
    ),
  ),
  
  // BottomNavigationBar
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedItemColor: AppColors.primaryLight,
    unselectedItemColor: AppColors.textTertiaryDark,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  
  // Tab Bar
  tabBarTheme: const TabBarThemeData(
    labelColor: AppColors.primaryLight,
    unselectedLabelColor: AppColors.textSecondaryDark,
    indicatorColor: AppColors.primaryLight,
    dividerColor: Colors.transparent,
    labelStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
  ),
  
  // Divider
  dividerTheme: const DividerThemeData(
    color: AppColors.dividerDark,
    thickness: 1,
    space: 1,
  ),
  
  // List Tile
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderMd,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  ),
  
  // Dialog
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surfaceDark,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderLg,
    ),
  ),
  
  // Snackbar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.cardDark,
    contentTextStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      color: AppColors.textPrimaryDark,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderMd,
    ),
    behavior: SnackBarBehavior.floating,
  ),
  
  // Bottom Sheet
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surfaceDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),
);
