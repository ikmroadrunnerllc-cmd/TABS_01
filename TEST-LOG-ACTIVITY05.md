Activity 05 - Test Log

I ran the tests with: flutter test test/counter_test.dart
Result: all 6 tests passed.

1. Lower boundary
Action: at counter = 10, tap Decrease.
Before: 10
After: 10 (unchanged)
Result: PASS. The Decrease button disables itself at 10.

2. Upper boundary
Action: drag the slider to 150, then tap Increase.
Before: 150
After: 150 (unchanged)
Result: PASS. The Increase button disables itself at 150.

3. Overshoot
Action: get the counter to 143, set the increment to 20, then tap Increase
(143 + 20 = 163, which is over 150).
Before: 143
After: 143 (unchanged)
Result: PASS. The Increase button disables itself before the tap can even
go through, since it can tell 163 would break the limit.

4. Invalid input
Action: type blank, -2, 2.5, and hello into the increment box, one at a
time.
Before: increment = 7
After: increment stays 7 the whole time
Result: PASS. Every one of the four shows a message and none of them
change the increment.

5. Undo chain
Action: starting at 40, tap Increase, Increase, Decrease (40 -> 47 -> 54
-> 47), then tap Undo four times.
Before: 40
Values during: 47, then 54, then 47
After each undo: 54, then 47, then 40, then 40 again
Result: PASS. The fourth undo has nothing left to restore, so it shows a
message and leaves the counter at 40 instead of crashing.

6. Slider and undo together
Action: drag the slider away from 40, then tap Undo.
Before: 40
After the drag: a new value
After undo: back to 40
Result: PASS. The number and the History line both agree it's back to 40.

Note: these results come from automated tests I wrote, which run the real
app code. They are not a replacement for manually running the app yourself
and watching it happen, which I also did separately.
