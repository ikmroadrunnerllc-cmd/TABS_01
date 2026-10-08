import 'package:flutter/material.dart';

import 'database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final helper = DatabaseHelper();
  try {
    await helper.init();
  } catch (error, stackTrace) {
    debugPrint('Database initialization failed: $error\n$stackTrace');
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Could not open local storage. Restart the app and check the logs.',
          ),
        ),
      ),
    ));
    return;
  }
  runApp(DirectoryApp(helper: helper));
}

class DirectoryApp extends StatelessWidget {
  const DirectoryApp({super.key, required this.helper});

  final DatabaseHelper helper;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fall Festival Roster',
      theme: ThemeData(colorSchemeSeed: Colors.orange),
      home: RosterScreen(helper: helper),
    );
  }
}

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key, required this.helper});

  final DatabaseHelper helper;

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  List<Map<String, dynamic>> _rows = [];
  int _count = 0;
  bool _loading = true;
  bool _busy = false;
  String? _readError;
  String? _message;
  int? _selectedId;

  DatabaseHelper get _helper => widget.helper;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // Reads rows and count from the database. Returns true if it worked.
  Future<bool> _load() async {
    setState(() {
      _loading = true;
      _readError = null;
    });
    try {
      final rows = await _helper.queryAllRows();
      final count = await _helper.queryRowCount();
      if (!mounted) return false;
      setState(() {
        _rows = rows;
        _count = count;
        _loading = false;
      });
      return true;
    } catch (error, stackTrace) {
      debugPrint('Read failed: $error\n$stackTrace');
      if (!mounted) return false;
      setState(() {
        _loading = false;
        _readError = 'Could not read the roster. Tap Retry to try again.';
      });
      return false;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name cannot be blank.';
    }
    return null;
  }

  String? _validateAge(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Age is required.';
    final age = int.tryParse(text);
    if (age == null) return 'Age must be a whole number.';
    if (age < 0 || age > 130) return 'Age must be from 0 to 130.';
    return null;
  }

  void _clearForm() {
    _nameController.clear();
    _ageController.clear();
    _selectedId = null;
    _formKey.currentState?.reset();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _message = 'Not saved. Fix the fields marked in red.');
      return;
    }
    final name = _nameController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final editingId = _selectedId;

    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      String result;
      try {
        if (editingId == null) {
          final id = await _helper.insert({
            DatabaseHelper.columnName: name,
            DatabaseHelper.columnAge: age,
          });
          result = 'Added $name with ID $id.';
        } else {
          final updated = await _helper.update({
            DatabaseHelper.columnId: editingId,
            DatabaseHelper.columnName: name,
            DatabaseHelper.columnAge: age,
          });
          if (updated == 0) {
            if (!mounted) return;
            setState(_clearForm);
            await _load();
            if (!mounted) return;
            setState(() =>
                _message = 'Guest ID $editingId was not found. Nothing changed.');
            return;
          }
          result = 'Updated ID $editingId ($updated row changed).';
        }
      } catch (error, stackTrace) {
        debugPrint('Write failed: $error\n$stackTrace');
        if (!mounted) return;
        setState(() => _message = 'Save failed. Your input was kept. Try again.');
        return;
      }

      if (!mounted) return;
      setState(_clearForm);
      final ok = await _load();
      if (!mounted) return;
      setState(() => _message =
          ok ? result : '$result Saved, but refresh failed. Tap Retry.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startEdit(Map<String, dynamic> row) {
    setState(() {
      _selectedId = row[DatabaseHelper.columnId] as int;
      _nameController.text = row[DatabaseHelper.columnName] as String;
      _ageController.text = '${row[DatabaseHelper.columnAge]}';
      _message = 'Editing ID $_selectedId.';
    });
  }

  void _cancelEdit() {
    setState(() {
      _clearForm();
      _message = 'Edit canceled. Nothing changed.';
    });
  }

  Future<void> _delete(Map<String, dynamic> row) async {
    final id = row[DatabaseHelper.columnId] as int;
    final name = row[DatabaseHelper.columnName];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete guest?'),
        content: Text('Delete ID $id ($name)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      setState(() => _message = 'Delete canceled. Nothing changed.');
      return;
    }

    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      int deleted;
      try {
        deleted = await _helper.delete(id);
      } catch (error, stackTrace) {
        debugPrint('Delete failed: $error\n$stackTrace');
        if (!mounted) return;
        setState(() => _message = 'Delete failed. Try again.');
        return;
      }
      if (!mounted) return;
      if (_selectedId == id) setState(_clearForm);
      final ok = await _load();
      if (!mounted) return;
      var result = deleted == 0
          ? 'Guest ID $id was not found. Nothing deleted.'
          : 'Deleted ID $id ($deleted row removed).';
      if (!ok) result = '$result Refresh failed. Tap Retry.';
      setState(() => _message = result);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_readError != null) {
      return Center(child: Text(_readError!, textAlign: TextAlign.center));
    }
    if (_rows.isEmpty) {
      return const Center(
        child: Text('No festival guests yet. The pumpkins are waiting!'),
      );
    }
    return ListView.builder(
      itemCount: _rows.length,
      itemBuilder: (context, index) {
        final row = _rows[index];
        final id = row[DatabaseHelper.columnId];
        return Card(
          child: ListTile(
            title: Text('${row[DatabaseHelper.columnName]}'),
            subtitle: Text('ID: $id   Age: ${row[DatabaseHelper.columnAge]}'),
            selected: id == _selectedId,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit ID $id',
                  icon: const Icon(Icons.edit),
                  onPressed: _busy ? null : () => _startEdit(row),
                ),
                IconButton(
                  tooltip: 'Delete ID $id',
                  icon: const Icon(Icons.delete),
                  onPressed: _busy ? null : () => _delete(row),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = _selectedId != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Fall Festival Roster')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    enabled: !_busy,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ageController,
                    enabled: !_busy,
                    decoration: const InputDecoration(labelText: 'Age (0-130)'),
                    keyboardType: TextInputType.number,
                    validator: _validateAge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: Text(editing ? 'Save ID $_selectedId' : 'Add'),
                ),
                OutlinedButton(
                  onPressed: _busy || !editing ? null : _cancelEdit,
                  child: const Text('Cancel edit'),
                ),
                OutlinedButton(
                  onPressed: _busy ? null : _refresh,
                  child: Text(_readError != null ? 'Retry' : 'Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_message != null) Text(_message!),
            const SizedBox(height: 8),
            Text(
              'Guests: ${_loading || _readError != null ? '-' : _count}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }
}
