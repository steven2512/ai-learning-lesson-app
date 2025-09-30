// FILE: lib/core/screen_size.dart
import 'package:flutter/widgets.dart';

enum ScreenCategory { small, medium, large }

enum WidthCategory { small, large }

class ScreenSize {
  static double? _height;
  static double? _width;
  static ScreenCategory? _category;
  static WidthCategory? _widthCategory;
  static globalFontSize() {
    final width = ScreenSize.width;

    // Pixel baseline
    const pixelWidth = 411.0;
    const pixelSize = 22.0;

    // A15 baseline
    const a15Width = 384.0;
    const a15Size = 20.0;

    // Linear interpolation between A15 and Pixel
    final slope =
        (a15Size - pixelSize) / (a15Width - pixelWidth); // -2 / -27 ≈ 0.074
    double size = pixelSize + (width - pixelWidth) * slope;

    // Clamp so it never goes crazy on tablets / tiny phones
    if (size < 18) size = 18;
    if (size > 24) size = 24;

    return size;
  }

  /// Call this once early in the widget tree (e.g., in a top-level widget build)
  static void init(BuildContext context) {
    if (_height != null && _width != null) return; // already initialized
    final size = MediaQuery.sizeOf(context);
    _height = size.height;
    _width = size.width;

    // 🔹 Height breakpoints
    if (_height! < 650) {
      _category = ScreenCategory.small;
    } else if (_height! < 800) {
      _category = ScreenCategory.medium;
    } else {
      _category = ScreenCategory.large;
    }

    // 🔹 Width breakpoints (more conservative)
    if (_width! < 500) {
      _widthCategory = WidthCategory.small; // phones
    } else {
      _widthCategory = WidthCategory.large; // tablets
    }
  }

  static double get height {
    if (_height == null) {
      throw Exception("ScreenSize.init(context) must be called first!");
    }
    return _height!;
  }

  static double get width {
    if (_width == null) {
      throw Exception("ScreenSize.init(context) must be called first!");
    }
    return _width!;
  }

  static ScreenCategory get category {
    if (_category == null) {
      throw Exception("ScreenSize.init(context) must be called first!");
    }
    return _category!;
  }

  static WidthCategory get widthCategory {
    if (_widthCategory == null) {
      throw Exception("ScreenSize.init(context) must be called first!");
    }
    return _widthCategory!;
  }
}
