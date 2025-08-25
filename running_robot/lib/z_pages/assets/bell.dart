// lib/z_pages/assets/bell.dart
import 'package:flutter/material.dart';

class Bell extends StatelessWidget {
  const Bell({
    super.key,
    this.onTap,
    this.size = 38, // overall box size (outer edge)
    this.showDot = true, // show the red badge
    this.assetPath = 'assets/images/bell.png',

    // NEW: container styling
    this.withContainer = true, // turn the grey holder on/off
    this.padding = 3.0, // gap between holder edge and bell
    this.radius = 12.0, // holder corner radius
    this.containerColor = const Color(0xFFF6F7F9), // soft neutral grey
    this.borderColor = const Color(0x14000000), // ~8% black hairline
  });

  final VoidCallback? onTap;
  final double size;
  final bool showDot;
  final String assetPath;

  // Holder options
  final bool withContainer;
  final double padding;
  final double radius;
  final Color containerColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final double innerBox = (size - (padding * 2)).clamp(0, size);
    final double iconSize =
        innerBox * 0.66; // keeps proportions similar to before
    final double dot = size * 0.24; // ~9 when size=38

    Widget content = Stack(
      clipBehavior: Clip.none,
      children: [
        // transparent bell only (no outline)
        Center(
          child: Image.asset(
            assetPath,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        if (showDot)
          Positioned(
            // align with holder’s edge
            top: -2,
            right: -2,
            child: Container(
              width: dot,
              height: dot,
              decoration: const BoxDecoration(
                color: Color(0xFFE11D48), // badge red
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );

    // Optional elegant grey container with radius + hairline
    if (withContainer) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: content,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
