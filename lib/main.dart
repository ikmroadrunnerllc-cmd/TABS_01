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
// 2. ROOT APPLICATION WIDGET (Owns Global Theme State)
// ============================================================================
// Summary: The single source of truth for light/dark mode. The theme flag is
// lifted to this root so MaterialApp and every screen below it agree on it;
// the screen flips it through the onToggleTheme callback.
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
// 3. MAIN STUDIO SCREEN (Stateful Controller)
// ============================================================================
// Summary: Holds the post's engagement counters and the trending target.
// Every mutation goes through setState(), so the metric badges, progress
// meter, background color, and TRENDING banner all rebuild together.
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

  // Weighted engagement score: Like 1, Comment 2, Share 3, Save 2
  int get engagementScore => likes + comments * 2 + shares * 3 + saves * 2;

  // Derived rather than stored, so it can never drift out of sync with the score
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

            // --- METRICS ROW ---
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

            // --- DYNAMIC PROGRESS METER ---
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

            // --- 2x2 GRID OF TACTILE ENGAGEMENT PADS ---
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
// 4. STATELESS PRESENTATION WIDGETS
// ============================================================================
// Summary: These hold no state of their own; they render whatever the parent
// passes in and rebuild only when the parent's setState() gives them new data.

/// Post preview card showing the simulated post and its latest engagement.
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

/// Small labeled counter tile for one engagement metric.
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

/// Banner revealed only while the post is trending.
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
// 5. CUSTOM STATEFUL TACTILE PAD
// ============================================================================
// Summary: Each pad owns its own isPressed flag, so pressing one never affects
// the others. GestureDetector drives the full touch lifecycle: sink on down,
// release + fire on up, release without firing on cancel. The pad scales down
// and swaps from raised to sunken neomorphic shadows while held.
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

    // GestureDetector exposes no button semantics on its own, so screen
    // readers get an explicit button node that fires the same action.
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
                      // Pressed (sunken): small, tight shadows
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
                      // Unpressed (raised): large, soft shadows
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
