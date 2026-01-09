import 'package:flutter/material.dart';

/// Custom page transitions for premium navigation feel
class AppPageTransitions {
  AppPageTransitions._();

  /// Smooth fade + slide transition
  static PageRouteBuilder<T> fadeSlide<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.02);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        final offsetAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Slide up transition (for modals converted to pages)
  static PageRouteBuilder<T> slideUp<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        final offsetAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeOut).animate(animation),
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Scale + fade transition (for detail views)
  static PageRouteBuilder<T> scaleFade<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .animate(animation);

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Shared axis transition (horizontal)
  static PageRouteBuilder<T> sharedAxisHorizontal<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.05, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }
}

/// Page route that respects theme transitions
class AppPageRoute<T> extends MaterialPageRoute<T> {
  AppPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}

/// Extension for easy navigation with transitions
extension NavigatorExtensions on NavigatorState {
  /// Push with fade + slide transition
  Future<T?> pushFadeSlide<T extends Object?>(Widget page) {
    return push(AppPageTransitions.fadeSlide<T>(page: page));
  }

  /// Push with scale + fade transition
  Future<T?> pushScaleFade<T extends Object?>(Widget page) {
    return push(AppPageTransitions.scaleFade<T>(page: page));
  }

  /// Push with slide up transition
  Future<T?> pushSlideUp<T extends Object?>(Widget page) {
    return push(AppPageTransitions.slideUp<T>(page: page));
  }
}
