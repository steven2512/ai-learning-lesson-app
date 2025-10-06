// FILE: lib/z_pages/assets/lessonAssets/image_slider.dart
// ✅ ImageSlider — smooth left/right sliding image carousel wrapped in LessonText.box
// - Constructor takes: imagePaths (assets), width, height
// - Optional: paddings (List<double>) to control LessonText.box padding
// - Optional tags per image:
//     • imageTag (bool), imageTags (List<String>), imageTagTop (bool)
//     • tagReserveSpace (bool, default: true)
//     • tagBox (bool, default: true)
//     • tagFill (Color?), tagTextColor (Color?)
//     • tagFontSize (double, default: 22) ← NEW
// - Arrows: Left/Right
// - onFinished fires first time last image reached

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imagePaths;
  final double width;
  final double height;
  final List<double>? paddings;
  final bool imageTag;
  final List<String>? imageTags;
  final bool imageTagTop;
  final bool tagReserveSpace;
  final bool tagBox;
  final Color? tagFill;
  final Color? tagTextColor;
  final double tagFontSize; // ✅ NEW
  final VoidCallback? onFinished;
  final Duration animationDuration;
  final Curve animationCurve;

  const ImageSlider({
    super.key,
    required this.imagePaths,
    required this.width,
    required this.height,
    this.paddings,
    this.imageTag = false,
    this.imageTags,
    this.imageTagTop = true,
    this.tagReserveSpace = true,
    this.tagBox = true,
    this.tagFill,
    this.tagTextColor,
    this.tagFontSize = 22, // ✅ Default
    this.onFinished,
    this.animationDuration = const Duration(milliseconds: 350),
    this.animationCurve = Curves.easeInOutCubic,
  }) : assert(imagePaths.length > 0, 'imagePaths must not be empty');

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late final PageController _controller;
  int _index = 0;
  bool _finishedFired = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final path in widget.imagePaths) {
      precacheImage(AssetImage(path), context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  EdgeInsets _edgeInsetsFromList(List<double>? p) {
    if (p == null || p.isEmpty) {
      return const EdgeInsets.symmetric(vertical: 15, horizontal: 13);
    }
    if (p.length == 4) return EdgeInsets.fromLTRB(p[3], p[0], p[1], p[2]);
    if (p.length == 2)
      return EdgeInsets.symmetric(vertical: p[0], horizontal: p[1]);
    return const EdgeInsets.symmetric(vertical: 15, horizontal: 13);
  }

  void _goNext() {
    if (_index < widget.imagePaths.length - 1) {
      _controller.animateToPage(
        _index + 1,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    }
  }

  void _goPrev() {
    if (_index > 0) {
      _controller.animateToPage(
        _index - 1,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    }
  }

  String? _tagTextFor(int i) {
    if (widget.imageTags == null) return null;
    if (i < 0 || i >= widget.imageTags!.length) return null;
    final t = widget.imageTags![i].trim();
    return t.isEmpty ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    final padding = _edgeInsetsFromList(widget.paddings);
    final isFirst = _index == 0;
    final isLast = _index == widget.imagePaths.length - 1;

    return LessonText.box(
      padding: padding,
      child: Center(
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageView.builder(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.imagePaths.length,
                  onPageChanged: (i) {
                    setState(() => _index = i);
                    if (i == widget.imagePaths.length - 1 && !_finishedFired) {
                      _finishedFired = true;
                      widget.onFinished?.call();
                    }
                  },
                  itemBuilder: (_, i) {
                    final tagText = _tagTextFor(i);
                    final boxed = widget.tagBox;
                    final fill = widget.tagFill ?? Colors.black54;
                    final textColor = widget.tagTextColor ??
                        (boxed ? Colors.white : Colors.black);

                    // === Reserved-space mode ===
                    if (widget.imageTag && widget.tagReserveSpace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.imageTagTop && tagText != null)
                            _TagLabel(
                              text: tagText,
                              boxed: boxed,
                              fill: fill,
                              textColor: textColor,
                              fontSize: widget.tagFontSize, // ✅
                            ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: widget.animationDuration,
                              switchInCurve: widget.animationCurve,
                              switchOutCurve: widget.animationCurve,
                              child: Image.asset(
                                widget.imagePaths[i],
                                key: ValueKey(widget.imagePaths[i]),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          if (!widget.imageTagTop && tagText != null)
                            _TagLabel(
                              text: tagText,
                              boxed: boxed,
                              fill: fill,
                              textColor: textColor,
                              fontSize: widget.tagFontSize, // ✅
                            ),
                        ],
                      );
                    }

                    // === Overlay mode ===
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedSwitcher(
                          duration: widget.animationDuration,
                          switchInCurve: widget.animationCurve,
                          switchOutCurve: widget.animationCurve,
                          child: Image.asset(
                            widget.imagePaths[i],
                            key: ValueKey(widget.imagePaths[i]),
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (widget.imageTag)
                          _TagOverlay(
                            text: tagText,
                            top: widget.imageTagTop,
                            boxed: boxed,
                            fill: fill,
                            textColor: textColor,
                            fontSize: widget.tagFontSize, // ✅
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (!isFirst && widget.imagePaths.length > 1)
                Positioned(
                  left: 6,
                  child: _ArrowButton(
                      direction: AxisDirection.left, onTap: _goPrev),
                ),
              if (!isLast && widget.imagePaths.length > 1)
                Positioned(
                  right: 6,
                  child: _ArrowButton(
                      direction: AxisDirection.right, onTap: _goNext),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final AxisDirection direction;
  final VoidCallback onTap;

  const _ArrowButton({required this.direction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLeft = direction == AxisDirection.left;
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            isLeft ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _TagLabel extends StatelessWidget {
  final String text;
  final bool boxed;
  final Color fill;
  final Color textColor;
  final double fontSize; // ✅

  const _TagLabel({
    required this.text,
    required this.boxed,
    required this.fill,
    required this.textColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.lato(
        fontSize: fontSize, // ✅
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.2,
      ),
    );

    if (!boxed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: textWidget,
        ),
      );
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: textWidget,
      ),
    );
  }
}

class _TagOverlay extends StatelessWidget {
  final String? text;
  final bool top;
  final bool boxed;
  final Color fill;
  final Color textColor;
  final double fontSize; // ✅

  const _TagOverlay({
    required this.text,
    required this.top,
    required this.boxed,
    required this.fill,
    required this.textColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.trim().isEmpty) return const SizedBox.shrink();

    final textWidget = Text(
      text!,
      textAlign: TextAlign.center,
      style: GoogleFonts.lato(
        fontSize: fontSize, // ✅
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.2,
      ),
    );

    Widget child;
    if (boxed) {
      child = Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: textWidget,
      );
    } else {
      child = Container(
        margin: const EdgeInsets.all(10),
        child: textWidget,
      );
    }

    return Align(
      alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
      child: child,
    );
  }
}
