// FILE: lib/z_pages/assets/lessonAssets/mascot_dialogue.dart
// ✅ MascotDialogue — compose any DialogueBox with a mascot PNG below it.
// - Takes an existing DialogueBox instance (so you keep its paging/buttons).
// - Paints a mascot image just beneath the bubble using a Stack.
// - Adds reserved space so the mascot isn't clipped by the parent.
// - Lightly configurable offsets/sizing and left/right anchoring.

import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/dialouge.dart';

enum MascotAnchor { left, right }

class MascotDialogue extends StatelessWidget {
  /// Your already-configured DialogueBox (content, width, finishButton, etc.)
  final DialogueBox dialogue;

  /// Asset path for the mascot pose PNG, e.g. 'assets/images/mascot.png'
  final String mascotAsset;

  /// Height of the mascot image.
  final double mascotHeight;

  /// Gap between the bubble’s bottom edge and the mascot’s top.
  final double gapBelowBubble;

  /// Horizontal offset from the chosen [anchor] edge.
  final double horizontalOffset;

  /// Whether to flip the mascot horizontally (useful if you have a “pointing” pose).
  final bool flipHorizontally;

  /// Anchor to place the mascot under the bubble’s tail-ish area.
  /// Default = left (matches the DialogueBox tail).
  final MascotAnchor anchor;

  /// If true (default), adds a SizedBox after the Stack to reserve
  /// vertical space equal to mascotHeight + gapBelowBubble.
  final bool reserveBottomSpace;

  const MascotDialogue({
    super.key,
    required this.dialogue,
    required this.mascotAsset,
    this.mascotHeight = 88.0,
    this.gapBelowBubble = 8.0,
    this.horizontalOffset = 18.0,
    this.flipHorizontally = false,
    this.anchor = MascotAnchor.left,
    this.reserveBottomSpace = true,
  });

  @override
  Widget build(BuildContext context) {
    final mascot = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(flipHorizontally ? -1.0 : 1.0, 1.0),
      child: Image.asset(
        mascotAsset,
        height: mascotHeight,
        fit: BoxFit.contain,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Bubble + paging/buttons from DialogueBox
            dialogue,

            // Mascot placed just below the DialogueBox widget
            Positioned(
              bottom: -(mascotHeight + gapBelowBubble),
              left: anchor == MascotAnchor.left ? horizontalOffset : null,
              right: anchor == MascotAnchor.right ? horizontalOffset : null,
              child: mascot,
            ),
          ],
        ),

        // Reserve space so the mascot isn’t clipped by the next widgets.
        if (reserveBottomSpace) SizedBox(height: mascotHeight + gapBelowBubble),
      ],
    );
  }
}
