import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64, this.showWordmark = false});

  static const String markAssetPath = 'lib/assets/logo.png';
  static const String wordmarkAssetPath = 'lib/assets/logo_with_des.png';

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final Widget animatedLogo = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(scale: value, child: child);
      },
      child: showWordmark
          ? SizedBox(
              height: size * 1.1,
              child: Image.asset(
                wordmarkAssetPath,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                semanticLabel: 'GigLert logo',
              ),
            )
          : Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.32),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: 0.28),
                    blurRadius: size * 0.34,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Colors.white.withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(size * 0.14),
                    child: Image.asset(
                      markAssetPath,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      semanticLabel: 'GigLert logo mark',
                    ),
                  ),
                ],
              ),
            ),
    );

    return animatedLogo;
  }
}
