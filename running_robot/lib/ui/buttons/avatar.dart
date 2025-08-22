import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  /// Diameter in logical pixels
  final double size;

  /// Optional image provider: NetworkImage, AssetImage, FileImage, etc.
  final ImageProvider? image;

  /// Placeholder widget when [image] is null or fails to load
  final Widget? placeholder;

  /// Fill color (inside the circle, shown under the image or placeholder)
  final Color fillColor;

  /// Callback when avatar is tapped
  final VoidCallback onPressed;

  /// Scale factor for the image inside the circle (1.0 = fit fully, <1 = smaller, >1 = zoom in)
  final double imageScale;

  const ProfileAvatar({
    super.key,
    required this.size,
    required this.onPressed,
    this.image,
    this.placeholder,
    this.fillColor = Colors.white,
    this.imageScale = 1.0, // NEW
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor,
          ),
          clipBehavior: Clip.antiAlias,
          child: image != null
              ? Transform.scale(
                  scale: imageScale, // <-- NEW
                  child: Image(
                    image: image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback(),
                  ),
                )
              : _fallback(),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Center(
      child: placeholder ??
          Icon(Icons.person_rounded, size: size * 0.5, color: Colors.black54),
    );
  }
}
