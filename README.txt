Fall Festival Roster - Local Storage Lab Part 1
================================================

Name: ____________
Pathway: Undergraduate / Graduate (circle one)
Flutter version: ____________   (run: flutter --version)
Device: ____________            (example: Pixel 7 emulator, Android 15)

How to run
----------
flutter pub get
flutter run

Files
-----
lib/main.dart             - the screen (form, list, add, edit, delete)
lib/database_helper.dart  - the supplied database helper
evidence/                 - screenshots and analyzer output

Changes I made
--------------
- Added orderBy _id ASC in queryAllRows() so the list shows in ID order.
- Removed the old counter test in test/widget_test.dart.
- Age rule: whole number from 0 to 130. Name cannot be blank.


Test results
------------
Format: test | action/input | expected | observed rows/count | pass/fail

T1 | Refresh empty roster | count 0, empty message | count __ , message shown? __ | ____
T2 | Add River 21, River 34 | count 2, two IDs | A = ID __ , B = ID __ , count __ | ____
T3 | Edit B to 99, Cancel | B stays 34 | B = __ | ____
T3 | Edit B, Save 35 | 1 row changed, A 21, B 35 | message: "__ row changed", A = __ , B = __ , count __ | ____
T4 | Stop app and reopen (method below) | same IDs, ages, count | A = ID __ age __ , B = ID __ age __ , count __ | ____
T5 | Delete A, Cancel | count 2 | count __ | ____
T5 | Delete A, confirm, Refresh | 1 row removed, only B left | message: "__ row removed", count __ | ____
T6 | Name "   " age 21 | rejected | message: ________ , count __ | ____
T6 | Maple, age "abc" | rejected | message: ________ , count __ | ____
T6 | Maple, age 1.5 | rejected | message: ________ , count __ | ____
T6 | Maple, age -1 | rejected | message: ________ , count __ | ____
T6 | Maple, age 131 | rejected | message: ________ , count __ | ____
T6 | Acorn, age 0 | accepted | ID __ | ____
T6 | Oak, age 130 | accepted | ID __ , final count __ | ____

T4 restart method: ____________
(Android: stop flutter run, Settings > Apps > local_storage_lab > Force stop,
 then open the app from its icon. Do NOT clear storage.)

Screenshots: evidence/T4_before.png, evidence/T4_after.png, evidence/T6_invalid.png
Analyzer output: evidence/analysis_output.txt


Questions
---------

1. The disappearing-data mystery
My guess before T4: ____________ (write this BEFORE you restart)

After the restart I saw A = ID __ (age __) and B = ID __ (age __), count __,
same as before (see T4_before.png and T4_after.png). When the app starts,
main() calls helper.init(), which opens MyDatabase.db on the phone. Then
initState() calls _load() (main.dart line 68), which runs queryAllRows() and
queryRowCount() (line 85) and puts the rows on screen. The app never adds
rows by itself, so the rows had to come from the saved file. If the list
had been empty or the IDs had changed after the restart, that would show
the data was not really saved.

2. Two Rivers, one wrong edit
Both guests are named River, so the name cannot tell them apart. I picked B
by its ID (__), and the update call (main.dart line 163) uses that ID in
"WHERE _id = ?". It returned 1 row changed, and A stayed at 21. If I picked
by list position instead, and the list got sorted by age, row 2 might become
A instead of B, and I would change the wrong River.

3. My own walkthrough
One thing I noticed: ____________ (example: after tapping Edit, it was not
easy to see which row I was editing).
Small fix idea: ____________ . Trade-off: ____________ .
Bad input did not save: in T6 each bad try showed a red message under the
field and the count stayed at __. Only Acorn and Oak were added, making the
count __.

4. Storage boundary (graduate only - this is a prediction, not a test)
The table only says NOT NULL, so the database would still accept an empty
name "" or an age of -5. My app blocks these in the form, but any other code
that writes to the table could skip that check. If I change CREATE TABLE but
keep version 1, nothing happens on a phone that already has the database,
because onCreate only runs when the file is new. For Part 2 I would raise
the version to 2 and use onUpgrade with ALTER TABLE (or copy rows into a new
table), so the old rows are kept.
