import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/auth/start_button.dart';

import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // LessonText
import 'package:running_robot/z_pages/mini-games/stat_board.dart';

/// ─────────────────────────────────────────────────────────
/// Slide data models
/// ─────────────────────────────────────────────────────────
class LFRow {
  final String f1;
  final String f2;
  final String label;
  const LFRow(this.f1, this.f2, this.label);
}

class LFSlideData {
  final String feature1Name; // short pill
  final String feature2Name; // short pill
  final String labelName; // short pill
  final List<LFRow> rows; // 5 rows
  final List<String> distractors; // 6 short decoys
  const LFSlideData({
    required this.feature1Name,
    required this.feature2Name,
    required this.labelName,
    required this.rows,
    required this.distractors,
  });

  List<String> allTokens() =>
      [feature1Name, feature2Name, labelName, ...distractors];
}

/// ─────────────────────────────────────────────────────────
/// Slides (intuitive + short tokens)
/// 1) Weight (kg) + Age (yrs) → Obesity (Yes/No)
/// 2) Year + Model → Price ($)
/// 3) Director + Cast → Rating  (Spielberg, Nolan, Tarantino, Scorsese, Bong)
/// 4) Study (hrs) + Avg Grade → Pass?
/// ─────────────────────────────────────────────────────────
final List<LFSlideData> _slides = [
  // 1) Obesity from Weight + Age (units added, simple values)
  LFSlideData(
    feature1Name: "Weight (kg)",
    feature2Name: "Age (yrs)",
    labelName: "Obesity",
    rows: [
      LFRow("55", "16", "No"),
      LFRow("88", "45", "Yes"),
      LFRow("102", "35", "Yes"),
      LFRow("63", "28", "No"),
      LFRow("95", "50", "Yes"),
    ],
    distractors: ["Color", "Brand", "Score", "Type", "Speed", "Mood"],
  ),

  // 2) Car price from Year + Model
  LFSlideData(
    feature1Name: "Year",
    feature2Name: "Model",
    labelName: "Price (\$)",
    rows: [
      LFRow("2007", "Civic", "18000"),
      LFRow("2022", "Model 3", "42000"),
      LFRow("2015", "Camry", "21000"),
      LFRow("2018", "Corolla", "17000"),
      LFRow("2020", "Mustang", "35000"),
    ],
    distractors: ["Color", "Doors", "Trim", "Fuel", "City", "Dealer"],
  ),

  // 3) Movie rating (1–10) from Director + Cast — famous, short pills
  LFSlideData(
    feature1Name: "Director",
    feature2Name: "Cast",
    labelName: "Rating",
    rows: [
      LFRow("Spielberg", "Hanks", "9"),
      LFRow("Nolan", "Bale", "9"),
      LFRow("Tarantino", "Pitt", "8"),
      LFRow("Scorsese", "DeNiro", "9"),
      LFRow("Bong", "Song", "8"),
    ],
    distractors: [
      "Studio",
      "Budget",
      "Country",
      "Runtime",
      "Genre",
      "Producer"
    ],
  ),

  // 4) Pass? from Study hours + Avg Grade (/100)
  LFSlideData(
    feature1Name: "Study (hrs)",
    feature2Name: "Avg Grade (/100)",
    labelName: "Pass?",
    rows: [
      LFRow("1", "40", "No"),
      LFRow("3", "58", "No"),
      LFRow("5", "62", "Yes"),
      LFRow("7", "75", "Yes"),
      LFRow("4", "68", "Yes"),
    ],
    distractors: ["Homework", "Quiz", "Club", "Day", "Seat", "Class"],
  ),
];

/// ─────────────────────────────────────────────────────────
/// Game widget (reused for each slide)
/// ─────────────────────────────────────────────────────────
class LabelFeatureGame extends StatefulWidget {
  final int slideIndex; // 0..3
  final VoidCallback? onCompleted;
  final VoidCallback? onReset;

  const LabelFeatureGame({
    super.key,
    required this.slideIndex,
    this.onCompleted,
    this.onReset,
  });

  @override
  State<LabelFeatureGame> createState() => _LabelFeatureGameState();
}

class _LabelFeatureGameState extends State<LabelFeatureGame> {
  // Compact pill sizing (tiny padding, larger fonts)
  static const double _pillMinHeight = 32;
  static const EdgeInsets _pillPad =
      EdgeInsets.symmetric(horizontal: 10, vertical: 4);
  static const double _pillRadius = 999; // true pill
  static const double _pillFont = 17;
  static const double _placeholderFont = 16;
  static const double _cellFont = 16;
  static const double _headerFont = 21;

  // Colors for empty slots (more obvious): pale fill + red border
  static const _emptyFill = Color(0xFFFBFCFE); // very pale
  static const _emptyBorder = Color(0xFFD32F2F); // red
  static const _emptyBorderHover = Color(0xFFB71C1C); // darker red
  static const _filledBorder = Color(0xFF2E7D32); // green

  // Fade choreography — fade ALL content out, then show StatsBoard
  static const int _contentFadeMs = 450;
  double _contentOpacity = 1.0;

  late LFSlideData data;
  final Random _rng = Random();

  String? _slotF1, _slotF2, _slotLbl;
  final Set<String> _used = {};

  bool _showEnd = false;
  bool _didWin = false;

  @override
  void initState() {
    super.initState();
    data = _slides[widget.slideIndex.clamp(0, _slides.length - 1)];
  }

  void _resetGame({bool reshuffle = true}) {
    widget.onReset?.call();
    setState(() {
      _slotF1 = _slotF2 = _slotLbl = null;
      _used.clear();
      _showEnd = false;
      _didWin = false;
      _contentOpacity = 1.0;
      if (reshuffle) {
        final list = data.distractors.toList()..shuffle(_rng);
        data = LFSlideData(
          feature1Name: data.feature1Name,
          feature2Name: data.feature2Name,
          labelName: data.labelName,
          rows: data.rows,
          distractors: list,
        );
      }
    });
  }

  bool get _allPlaced => _slotF1 != null && _slotF2 != null && _slotLbl != null;

  void _finishWithFade(bool ok) {
    setState(() {
      _didWin = ok;
      _contentOpacity = 0.0; // fade out everything first
    });
    Future.delayed(const Duration(milliseconds: _contentFadeMs), () {
      if (!mounted) return;
      setState(() => _showEnd = true); // then show StatsBoard
    });
  }

  void _checkAndFinish() {
    if (!_allPlaced) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Place both Features and the Label first.')),
      );
      return;
    }
    final ok = (_slotF1 == data.feature1Name) &&
        (_slotF2 == data.feature2Name) &&
        (_slotLbl == data.labelName);
    _finishWithFade(ok);
  }

  // General pill (palette + filled slot).
  // By default pills are single-line & ellipsized; in header slots we can allow wrap.
  Widget _pill(
    String text, {
    EdgeInsets? padding,
    Color bg = Colors.white,
    Color border = const Color(0xFFDFE3E8),
    double borderWidth = 1,
    Color textColor = Colors.black87,
    double fontSize = _pillFont,
    FontWeight fontWeight = FontWeight.w800,
    bool allowWrap = false,
    int maxWrapLines = 2,
    TextAlign align = TextAlign.center,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _pillMinHeight),
      child: Container(
        padding: padding ?? _pillPad,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(_pillRadius),
          border: Border.all(color: border, width: borderWidth),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: Text(
          text,
          maxLines: allowWrap ? maxWrapLines : 1,
          overflow: allowWrap ? TextOverflow.clip : TextOverflow.ellipsis,
          softWrap: allowWrap,
          textAlign: align,
          style: GoogleFonts.lato(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  // Draggable palette chip (single-line, never wraps)
  Widget _draggableChip(String token) {
    if (_used.contains(token)) return const SizedBox.shrink();
    return Draggable<String>(
      data: token,
      feedback: Material(type: MaterialType.transparency, child: _pill(token)),
      childWhenDragging: Opacity(opacity: 0.18, child: _pill(token)),
      child: _pill(token),
    );
  }

  // Header drop slot — paler fill + red border to make it obvious;
  // darker red on hover; green when filled.
  Widget _slot({
    required String? value,
    required void Function(String?) onChange,
    required String placeholder,
  }) {
    final bool filled = value != null;

    return DragTarget<String>(
      builder: (context, candidate, _) {
        final bool hovering = candidate.isNotEmpty;

        final Color borderColor = hovering
            ? _emptyBorderHover
            : (filled ? _filledBorder : _emptyBorder);
        final double borderWidth = hovering ? 3.0 : (filled ? 1.8 : 2.4);
        final Color bgColor = filled ? Colors.white : _emptyFill;

        if (filled) {
          // In header, allow 2-line wrap for column names (don’t overdo).
          return GestureDetector(
            onTap: () {
              setState(() {
                _used.remove(value);
                onChange(null);
              });
            },
            child: _pill(
              value!,
              bg: bgColor,
              border: borderColor,
              borderWidth: borderWidth,
              textColor: Colors.black87,
              allowWrap: true,
              maxWrapLines: 2,
            ),
          );
        } else {
          // Placeholder text that literally says Feature Here / Label Here.
          return _pill(
            placeholder,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            bg: bgColor,
            border: borderColor,
            borderWidth: borderWidth,
            textColor: const Color(0xFF5F6A7D),
            fontSize: _placeholderFont,
            fontWeight: FontWeight.w900,
            allowWrap: true,
            maxWrapLines: 2,
          );
        }
      },
      onWillAccept: (s) => s != null && !_used.contains(s),
      onAccept: (s) {
        setState(() {
          if (value != null) _used.remove(value);
          _used.add(s);
          onChange(s);
        });
        // ⛔️ Removed auto-check here. Submit will decide pass/fail.
        // Future.microtask(_checkAndFinish);
      },
    );
  }

  // Styled table cell
  Widget _cell(
    String text, {
    FontWeight fw = FontWeight.w700,
    Color color = Colors.black87,
    Alignment align = Alignment.center,
    double? fs,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      alignment: align,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
            fontSize: fs ?? _cellFont, fontWeight: fw, color: color),
      ),
    );
  }

  // Tight ~3-per-row palette (chips keep natural width but capped; ellipsis in pill)
  Widget _palette(List<String> tokens) {
    return LayoutBuilder(builder: (context, c) {
      const spacing = 8.0;
      const per = 3;
      final double maxPerChip = (c.maxWidth - spacing * (per - 1)) / per;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final t in tokens)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxPerChip),
              child: Align(
                  alignment: Alignment.centerLeft, child: _draggableChip(t)),
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = data.allTokens().toList()..shuffle(_rng);

    final content = AnimatedOpacity(
      opacity: _contentOpacity,
      duration: const Duration(milliseconds: _contentFadeMs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Instruction header
          LessonText.box(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Center(
              child: LessonText.sentence(
                [
                  LessonText.word("Drag", Colors.black87, fontSize: 19),
                  LessonText.word("the", Colors.black87, fontSize: 19),
                  LessonText.word("correct", Colors.black87, fontSize: 19),
                  LessonText.word("Features", Colors.blue, fontSize: 19),
                  LessonText.word("and", Colors.black87, fontSize: 19),
                  LessonText.word("Label", Colors.orange, fontSize: 19),
                  LessonText.word("to", Colors.black87, fontSize: 19),
                  LessonText.word("the", Colors.black87, fontSize: 19),
                  LessonText.word("table", Colors.black87, fontSize: 19),
                  LessonText.word("below", Colors.black87, fontSize: 19),
                ],
                alignment: WrapAlignment.center,
              ),
            ),
          ),

          // Table (two-line "Data Sample #", bigger, orange)
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black26, width: 1),
            ),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(88), // narrower—more space for slots
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              border: const TableBorder(
                horizontalInside:
                    BorderSide(color: Color(0x22000000), width: 1),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF3F7FF)),
                  children: [
                    _cell("Data\nSample #",
                        fw: FontWeight.w900,
                        color: Color(0xFFFF6D00),
                        fs: _headerFont),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: _slot(
                        value: _slotF1,
                        onChange: (s) => setState(() => _slotF1 = s),
                        placeholder: "Feature Here",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: _slot(
                        value: _slotF2,
                        onChange: (s) => setState(() => _slotF2 = s),
                        placeholder: "Feature Here",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: _slot(
                        value: _slotLbl,
                        onChange: (s) => setState(() => _slotLbl = s),
                        placeholder: "Label Here",
                      ),
                    ),
                  ],
                ),
                for (int i = 0; i < data.rows.length; i++)
                  TableRow(
                    decoration: BoxDecoration(
                      color:
                          (i % 2 == 0) ? const Color(0xFFFAFAFA) : Colors.white,
                    ),
                    children: [
                      _cell("${i + 1}", fw: FontWeight.w800),
                      _cell(data.rows[i].f1, fw: FontWeight.w700),
                      _cell(data.rows[i].f2, fw: FontWeight.w700),
                      _cell(data.rows[i].label, fw: FontWeight.w900),
                    ],
                  ),
              ],
            ),
          ),

          // Palette — tight pills, ~3 per row, capped width, ellipsis
          LessonText.box(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: _palette(tokens),
          ),

          const SizedBox(height: 8),

          // ✅ 3D Submit button (green) — triggers pass/fail + fade → StatsBoard
          PillCta(
            label: "Submit",
            onTap: _checkAndFinish,
            color: const Color(0xFF22C55E), // green
            expand: true,
            height: 48,
            fontSize: 18,
          ),

          const SizedBox(height: 6),

          // Clear button
          TextButton.icon(
            onPressed: () => _resetGame(reshuffle: false),
            icon: const Icon(Icons.refresh),
            label: Text(
              "Clear Headers",
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: [
            content,
            if (_showEnd)
              StatsBoard(
                visible: true,
                didWin: _didWin,
                onCompleted:
                    widget.onCompleted, // fires after board sequence on win
                onRestart: _resetGame,
                stats: [
                  StatItem("Placed Feature 1", _slotF1 ?? "-", Colors.blue),
                  StatItem("Placed Feature 2", _slotF2 ?? "-", Colors.blue),
                  StatItem("Placed Label", _slotLbl ?? "-", Colors.orange),
                ],
                body: _didWin
                    ? null
                    : Text(
                        "Try Again",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
