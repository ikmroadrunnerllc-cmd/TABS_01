# README Reflection — Mario Gutierrez
### In-Class 1 · v3 — Concept Check & Team GitHub Challenge

## Reflection Questions

**1. What surprised you most about how the widget tree, state, or lifecycle actually behaves once you saw it applied in the app?**

Seeing `TabController` in practice made it clear that "state" isn't just a variable — it's an object with its own lifecycle that has to be created and torn down deliberately. It was surprising that `TabBar` and `TabBarView` don't talk to each other directly at all; they're both just wired to the same `_tabController`, and that controller is the actual thing keeping them in sync. It also stood out that the `RestorationMixin` layer exists specifically to survive scenarios `setState()` alone can't handle, like the OS killing the app process entirely.

**2. Which concept (Widget Tree, Stateless vs. Stateful, Controllers & Lifecycle, or Declarative UI) took the longest to click for you, and what finally made it make sense?**

Controllers & Lifecycle took the longest. Understanding *why* `initState()`/`dispose()` need to be a matched pair didn't click until I traced through what would actually stay alive in memory if `dispose()` were skipped — thinking through the memory-leak scenario in Critical Thinking Question 3 made the abstract "clean up your resources" rule feel like a real, concrete consequence instead of just a style guideline.

**3. What part of the GitHub workflow (repo setup, cloning, committing, pull requests) felt least familiar, and how did you work through it?**

Working entirely solo (no partner available for this activity), the least familiar part was self-reviewing a pull request — normally a PR exists so a second person catches mistakes, so opening one with nobody else to review it felt a bit artificial. I worked through it by treating the diff review step seriously anyway: reading through every changed line in the PR view before merging, as if I were a reviewer seeing the code for the first time.

**4. If you rebuilt this activity from scratch tomorrow, what would you do differently?**

I'd write the critical-thinking answers *while* reading through `main.dart` line by line rather than after, since tying each answer directly to a specific line number or block made the answers much more concrete than trying to recall the code from memory afterward.

## Peer Feedback & Reflection

**Note:** I completed this activity individually — I was not enrolled with an in-person partner to pair with for this session, so the peer-feedback questions below don't apply this time.

- One specific helpful contribution from my teammate: N/A — no partner for this activity.
- One piece of constructive feedback for my teammate: N/A — no partner for this activity.
- One thing I learned from watching my teammate: N/A — no partner for this activity.
- How we resolved disagreements/merge conflicts: N/A — no partner for this activity.
