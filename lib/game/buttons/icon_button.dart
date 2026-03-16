import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/game/events/event_type.dart'; // EventHorizontalObstacle

/// Minimal icon-only button:
/// - Renders a single transparent PNG (no background)
/// - Same show()/hide()/switchPhase() contract as GenericButton
/// - Optional tint; preserves icon aspect ratio
class IconButton<T> extends PositionComponent with TapCallbacks {
  final String iconPath; // e.g. 'assets/ui/arrow_left.png'
  final void Function(T? value)? onPressed; // tap callback
  final T? payload; // optional payload
  final Color? tint; // null = keep original icon colors

  // Event-driven visibility (matches your architecture)
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;
  bool _phaseDirty = true;
  bool _isVisible = false;

  Sprite? _icon;

  IconButton({
    required Vector2 position,
    required Vector2 size,
    required Anchor anchor,
    required this.iconPath,
    this.onPressed,
    this.payload,
    this.tint,
  }) : super(position: position, size: size, anchor: anchor);

  // Same API as GenericButton
  void switchPhase(EventHorizontalObstacle next) {
    next == EventHorizontalObstacle.startMoving ? show() : hide();
  }

  void show() {
    currentEvent = EventHorizontalObstacle.startMoving;
    _phaseDirty = true;
  }

  void hide() {
    currentEvent = EventHorizontalObstacle.stopMoving;
    _phaseDirty = true;
  }

  @override
  Future<void> onLoad() async {
    _icon = await Sprite.load(iconPath);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_phaseDirty) {
      _isVisible = currentEvent == EventHorizontalObstacle.startMoving;
      _phaseDirty = false;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_isVisible || _icon == null) return;

    // Fit icon into component bounds, preserving aspect ratio
    final Rect box = Offset.zero & Size(size.x, size.y);
    final src = _icon!.srcSize;
    final aspect = src.x / src.y;

    double dw = box.width, dh = box.height;
    if (dw / dh > aspect) {
      dw = dh * aspect;
    } else {
      dh = dw / aspect;
    }
    final dx = box.left + (box.width - dw) / 2.0;
    final dy = box.top + (box.height - dh) / 2.0;
    final dest = Rect.fromLTWH(dx, dy, dw, dh);

    _icon!.renderRect(
      canvas,
      dest,
      overridePaint: (tint == null) ? null : (Paint()..color = tint!),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isVisible) onPressed?.call(payload);
  }
}
