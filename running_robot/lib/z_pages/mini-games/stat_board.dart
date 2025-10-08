// FILE: lib/z_pages/mini-games/stat_board.dart
// 🎬 Auto two-phase cinematic StatsBoard (final, safe version)
// 1️⃣ "You win" stays 2s with bigger font + tighter padding
// 2️⃣ Big stats board fades in slower + softer
// ✅ Only fires onCompleted() if didWin == true

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatItem {
  final String label;
  final String value;
  final Color color;
  const StatItem(this.label, this.value, this.color);
}

class StatsBoard extends StatefulWidget {
  final bool visible;
  final bool didWin;
  final List<StatItem> stats;
  final Widget? body;
  final VoidCallback? onRestart;
  final VoidCallback? onCompleted;
  final Color? winColor;
  final Color? loseColor;

  const StatsBoard({
    super.key,
    required this.visible,
    required this.didWin,
    required this.stats,
    this.body,
    this.onRestart,
    this.onCompleted,
    this.winColor,
    this.loseColor,
  });

  @override
  State<StatsBoard> createState() => _StatsBoardState();
}

class _StatsBoardState extends State<StatsBoard> with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  bool _showStats = false;
  bool _callbackFired = false;

  // smoother timing
  static const int kFadeMs = 800; // slower fade
  static const int kWaitMs = 2000; // show "You win" for 2s

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kFadeMs),
    );
    if (widget.visible) _triggerFadeSequence();
  }

  @override
  void didUpdateWidget(covariant StatsBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) _triggerFadeSequence();
  }

  Future<void> _triggerFadeSequence() async {
    if (!mounted) return;
    _fadeCtrl.reset();
    await Future.delayed(const Duration(milliseconds: 30));
    if (!mounted) return;

    await _fadeCtrl.forward(); // fade in first card
    await Future.delayed(const Duration(milliseconds: kWaitMs));

    if (!mounted) return;
    setState(() => _showStats = true);

    await Future.delayed(const Duration(milliseconds: kFadeMs + 300));

    // ✅ Only fire callback if didWin == true
    if (!_callbackFired && mounted && widget.didWin) {
      _callbackFired = true;
      widget.onCompleted?.call();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    final didWin = widget.didWin;
    final Color headerColor = didWin
        ? (widget.winColor ?? Colors.green.shade900)
        : (widget.loseColor ?? Colors.red.shade900);

    return Positioned.fill(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const IgnorePointer(
            ignoring: true,
            child: ColoredBox(color: Color(0xF0FFFFFF)),
          ),
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _fadeCtrl,
              curve: Curves.easeInOutCubic,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: kFadeMs),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubicEmphasized,
              child: _showStats
                  ? _buildBigStats(headerColor)
                  : _buildWinCard(headerColor),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Phase 1 — Small Congratulations card
  // ────────────────────────────────────────────────
  Widget _buildWinCard(Color headerColor) {
    final didWin = widget.didWin;
    final title = didWin ? "🎉 Congratulations!\nYou win!" : "💥 Game Over";

    return Container(
      key: const ValueKey("winCard"),
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          height: 1.2,
          color: headerColor,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Phase 2 — Full Stats Board
  // ────────────────────────────────────────────────
  Widget _buildBigStats(Color headerColor) {
    final titleStyle = GoogleFonts.lato(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: headerColor,
    );

    return Container(
      key: const ValueKey("statsCard"),
      width: 340,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Your Results", textAlign: TextAlign.center, style: titleStyle),
          const SizedBox(height: 10),
          if (widget.body != null) widget.body!,
          const SizedBox(height: 10),
          for (final s in widget.stats) _statRow(s),
          const SizedBox(height: 18),
          if (widget.onRestart != null)
            ElevatedButton.icon(
              onPressed: widget.onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04A07C),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statRow(StatItem s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              s.label,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: s.color,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: s.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: s.color.withOpacity(0.5)),
            ),
            child: Text(
              s.value,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: s.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
