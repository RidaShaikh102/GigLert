import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.shellGradient(isDark),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -80,
              right: -40,
              child: _Orb(
                size: 220,
                color: AppColors.emerald.withValues(alpha: isDark ? 0.18 : 0.22),
              ),
            ),
            Positioned(
              left: -70,
              bottom: 100,
              child: _Orb(
                size: 180,
                color: AppColors.warning.withValues(alpha: isDark ? 0.12 : 0.16),
              ),
            ),
            Positioned(
              top: 210,
              left: 24,
              child: _Orb(
                size: 120,
                color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.20),
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color,
              blurRadius: size * 0.24,
              spreadRadius: size * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}
