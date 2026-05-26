import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A premium, liquid-silver and high-contrast glassmorphic card container.
/// Integrates metallic borders, subtle reflections, and shadows for visual excellence.
class SilverCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool isMetallic;
  final VoidCallback? onTap;

  const SilverCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.isMetallic = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMetallic ? Colors.white.withValues(alpha: 0.8) : AppColors.border,
          width: isMetallic ? 1.5 : 1.0,
        ),
        gradient: isMetallic
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.metallicGradient,
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.obsidianGradient,
              ),
        boxShadow: isMetallic
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: cardContent,
          ),
        ),
      );
    }

    return cardContent;
  }
}
