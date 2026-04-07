import 'package:flutter/material.dart';

class LoadingSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;
  final BoxShape shape;

  const LoadingSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.shape = BoxShape.rectangle,
  });

  const LoadingSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = BorderRadius.zero,
        shape = BoxShape.circle;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerOffset = (_controller.value * 2) - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius:
                widget.shape == BoxShape.circle ? null : widget.borderRadius,
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFECEFF3),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: widget.shape == BoxShape.circle
              ? ClipOval(child: _buildShimmer(shimmerOffset))
              : ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: _buildShimmer(shimmerOffset),
                ),
        );
      },
    );
  }

  Widget _buildShimmer(double shimmerOffset) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: Colors.white),
        ),
        Positioned.fill(
          child: FractionalTranslation(
            translation: Offset(shimmerOffset, 0),
            child: Transform.rotate(
              angle: 0.18,
              child: Container(
                width: widget.width ?? 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      const Color(0xFFF3F6FA).withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppHeaderSkeleton extends StatelessWidget {
  const AppHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned(
          left: 19,
          top: 60,
          child: LoadingSkeleton.circle(size: 55),
        ),
        Positioned(
          left: 86,
          top: 67,
          right: 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingSkeleton(width: 108, height: 16),
                    SizedBox(height: 10),
                    LoadingSkeleton(width: 188, height: 24),
                  ],
                ),
              ),
              SizedBox(width: 12),
              LoadingSkeleton(width: 40, height: 40),
            ],
          ),
        ),
      ],
    );
  }
}
