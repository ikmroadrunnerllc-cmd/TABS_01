// ============================================================================
// Activity 04: Flutter Widget Wars & State Derby
// Build Challenge Theme: Viral Content Studio
// Team Name: TODO_TEAM_NAME
// Members:
//   - TODO Full Name (Student ID: TODO)
//   - TODO Full Name (Student ID: TODO)
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================================
// 1. MAIN ENTRY POINT
// ============================================================================
void main() {
  runApp(const ViralStudioApp());
}

// ============================================================================
// 2. APP WIDGET (THEME)
// ============================================================================
// Keeps track of dark/light mode. It lives here at the top so MaterialApp
// can use it too. The screen changes it by calling onToggleTheme.
class ViralStudioApp extends StatefulWidget {
  const ViralStudioApp({super.key});

  @override
  State<ViralStudioApp> createState() => _ViralStudioAppState();
}

class _ViralStudioAppState extends State<ViralStudioApp> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viral Content Studio',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: ContentStudioScreen(
        isDark: isDarkMode,
        onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
      ),
    );
  }
}

// ============================================================================
// 3. MAIN SCREEN
// ============================================================================
// Holds the counters and the trending target. Every change goes through
// setState() so the badges, progress bar, and banner all update together.
class ContentStudioScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const ContentStudioScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<ContentStudioScreen> createState() => _ContentStudioScreenState();
}

class _ContentStudioScreenState extends State<ContentStudioScreen> {
  // --- Mutable State Variables ---
  int likes = 0; // +1 point each
  int comments = 0; // +2 points each
  int shares = 0; // +3 points each
  int saves = 0; // +2 points each
  int streak = 0; // Engagements in a row since the last reset
  double trendingTarget = 20; // Points needed to trend (slider-controlled)
  String lastAction = "POSTED";

  // Like 1, Comment 2, Share 3, Save 2
  int get engagementScore => likes + comments * 2 + shares * 3 + saves * 2;

  // Worked out from the score so it always matches
  bool get isTrending => engagementScore >= trendingTarget;

  void _engage(String actionName, VoidCallback increment) {
    setState(() {
      increment();
      streak++;
      lastAction = actionName;
    });
  }

  void _resetPost() {
    setState(() {
      likes = 0;
      comments = 0;
      shares = 0;
      saves = 0;
      streak = 0;
      lastAction = "NEW POST";
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenBg = isTrending
        ? (widget.isDark ? const Color(0xFF3A1E1A) : const Color(0xFFFFE3D6))
        : (widget.isDark ? const Color(0xFF1E1F29) : const Color(0xFFE0E5EC));
    final progress = (engagementScore / trendingTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        title: const Text(
          "VIRAL CONTENT STUDIO",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            PostHeaderCard(isDark: widget.isDark, lastAction: lastAction),
            const SizedBox(height: 16),
            if (isTrending) const TrendingBanner(),
            if (isTrending) const SizedBox(height: 16),

            // --- COUNTERS ---
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                MetricBadge(
                  label: "SCORE",
                  value: engagementScore,
                  color: Colors.deepOrange,
                  isDark: widget.isDark,
                ),
                MetricBadge(
                  label: "LIKES",
                  value: likes,
                  color: Colors.pinkAccent,
                  isDark: widget.isDark,
                ),
                MetricBadge(
                  label: "COMMENTS",
                  value: comments,
                  color: Colors.lightBlueAccent,
                  isDark: widget.isDark,
                ),
                MetricBadge(
                  label: "SHARES",
                  value: shares,
                  color: Colors.greenAccent,
                  isDark: widget.isDark,
                ),
                MetricBadge(
                  label: "SAVES",
                  value: saves,
                  color: Colors.amber,
                  isDark: widget.isDark,
                ),
                MetricBadge(
                  label: "STREAK",
                  value: streak,
                  color: Colors.purpleAccent,
                  isDark: widget.isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- PROGRESS BAR ---
            Text(
              "Trending progress: $engagementScore / ${trendingTarget.toInt()} pts",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                color: isTrending ? Colors.deepOrange : Colors.blueAccent,
                backgroundColor: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 28),

            // --- ENGAGEMENT PADS ---
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                EngagementPad(
                  icon: Icons.favorite,
                  label: "LIKE +1",
                  accentColor: Colors.pinkAccent,
                  isDark: widget.isDark,
                  onPressed: () => _engage("LIKED", () => likes++),
                ),
                EngagementPad(
                  icon: Icons.chat_bubble,
                  label: "COMMENT +2",
                  accentColor: Colors.lightBlueAccent,
                  isDark: widget.isDark,
                  onPressed: () => _engage("COMMENTED", () => comments++),
                ),
                EngagementPad(
                  icon: Icons.share,
                  label: "SHARE +3",
                  accentColor: Colors.greenAccent,
                  isDark: widget.isDark,
                  onPressed: () => _engage("SHARED", () => shares++),
                ),
                EngagementPad(
                  icon: Icons.bookmark,
                  label: "SAVE +2",
                  accentColor: Colors.amber,
                  isDark: widget.isDark,
                  onPressed: () => _engage("SAVED", () => saves++),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- TRENDING TARGET SLIDER ---
            Text(
              "Trending target: ${trendingTarget.toInt()} pts",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Slider(
              value: trendingTarget,
              min: 10,
              max: 50,
              divisions: 40,
              activeColor: Colors.deepOrange,
              inactiveColor: Colors.grey.withValues(alpha: 0.3),
              onChanged: (newVal) => setState(() => trendingTarget = newVal),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _resetPost,
              icon: const Icon(Icons.refresh),
              label: const Text("RESET POST"),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. STATELESS WIDGETS
// ============================================================================
// These don't keep any state. They just show what the screen passes in.

/// Card at the top that shows the post and the last action.
class PostHeaderCard extends StatelessWidget {
  final bool isDark;
  final String lastAction;

  const PostHeaderCard({
    super.key,
    required this.isDark,
    required this.lastAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282A36) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.deepOrange,
            child: Icon(Icons.videocam, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "@studio_team • \"My first Flutter app 🚀\"",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "LAST ACTION: $lastAction",
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isDark ? Colors.tealAccent : Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small box that shows one counter.
class MetricBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool isDark;

  const MetricBadge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282A36) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner that only shows up when the post is trending.
class TrendingBanner extends StatelessWidget {
  const TrendingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepOrange, Colors.pinkAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "TRENDING 🔥",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ============================================================================
// 5. ENGAGEMENT PAD (STATEFUL)
// ============================================================================
// Each pad has its own isPressed so pressing one doesn't affect the others.
// Touch down pushes it in, letting go runs the action, and dragging off
// cancels it. While it's held it shrinks a little and the shadow changes.
class EngagementPad extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onPressed;

  const EngagementPad({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.isDark,
    required this.onPressed,
  });

  @override
  State<EngagementPad> createState() => _EngagementPadState();
}

class _EngagementPadState extends State<EngagementPad> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDark
        ? const Color(0xFF222430)
        : const Color(0xFFE0E5EC);
    final darkShadow = widget.isDark ? Colors.black87 : const Color(0xFFA3B1C6);
    final lightShadow = widget.isDark ? const Color(0xFF2F3244) : Colors.white;

    // Semantics lets screen readers treat the pad as a button.
    return Semantics(
      button: true,
      label: widget.label,
      onTap: widget.onPressed,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          setState(() => isPressed = true);
        },
        onTapUp: (_) {
          setState(() => isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => isPressed = false),
        child: AnimatedScale(
          scale: isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isPressed
                  ? [
                      // Pressed: small shadow so it looks pushed in
                      BoxShadow(
                        color: darkShadow.withValues(alpha: 0.5),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                      BoxShadow(
                        color: lightShadow.withValues(alpha: 0.5),
                        offset: const Offset(-2, -2),
                        blurRadius: 4,
                      ),
                    ]
                  : [
                      // Not pressed: big shadow so it looks raised
                      BoxShadow(
                        color: darkShadow.withValues(alpha: 0.7),
                        offset: const Offset(8, 8),
                        blurRadius: 16,
                      ),
                      BoxShadow(
                        color: lightShadow.withValues(alpha: 0.9),
                        offset: const Offset(-8, -8),
                        blurRadius: 16,
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: isPressed ? 40 : 46,
                  color: isPressed
                      ? widget.accentColor
                      : (widget.isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.1,
                    color: isPressed
                        ? widget.accentColor
                        : (widget.isDark ? Colors.white54 : Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
