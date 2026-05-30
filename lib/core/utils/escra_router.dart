import 'package:flutter/material.dart';

/// Modern custom routing engine for the ESCRA application.
/// Provides a sleek modal-style bottom-to-top ease transition to replace
/// generic platform-default side-swipe animations.
class EscraRouter {
  /// Create custom PageRouteBuilder with a clean, subtle Instagram-like fade-in transition.
  static Route<T> createFadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        );
      },
    );
  }

  /// Create custom PageRouteBuilder with bottom-to-top slide and fade transition.
  static Route<T> createSlideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Subtle slide up from 15% down
        final slideTween = Tween<Offset>(
          begin: const Offset(0.0, 0.15),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.fastOutSlowIn));

        // Soft opacity transition
        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Pushes a new page with the modern Instagram-like fade-in transition.
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(context, createFadeRoute<T>(page));
  }

  /// Pushes and replaces the current page with the modern Instagram-like fade-in transition.
  static Future<T?> pushReplacement<T, TO>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, TO>(context, createFadeRoute<T>(page));
  }

  /// Pushes a new page with the modal slide-up transition.
  static Future<T?> pushSlide<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(context, createSlideRoute<T>(page));
  }

  /// Pushes and replaces the current page with the modal slide-up transition.
  static Future<T?> pushReplacementSlide<T, TO>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, TO>(context, createSlideRoute<T>(page));
  }
}
