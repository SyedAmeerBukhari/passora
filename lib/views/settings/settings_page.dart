import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(themeProvider);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/home');
              },
            ),
          ),
          body: ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: theme.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  ref
                      .read(themeProvider)
                      .setTheme(value ? ThemeMode.dark : ThemeMode.light);
                },
                secondary: const Icon(Icons.brightness_6),
              ),
              // Add more settings here
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Change Username'),
                onTap: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) => _ChangeUsernameDialog(),
                  );
                  if (result != null && result.isNotEmpty) {
                    // Optionally show a snackbar or reload
                    setState(() {});
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                onTap: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => _ChangePasswordDialog(),
                  );
                  if (result == true) {
                    // Optionally show a snackbar or reload
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChangeUsernameDialog extends StatefulWidget {
  @override
  State<_ChangeUsernameDialog> createState() => _ChangeUsernameDialogState();
}

class _ChangeUsernameDialogState extends State<_ChangeUsernameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      setState(() {
        _error = 'Username cannot be empty';
        _isLoading = false;
      });
      return;
    }
    try {
      final oldUsername = await AuthService.getCurrentUsername();
      if (oldUsername == null) throw Exception('No user logged in');
      final password = await AuthService.getPasswordForUsername(oldUsername);
      if (password == null) throw Exception('Password not found');
      // Save credentials under new username
      await AuthService.saveCredentials(newUsername, password);
      // Remove old username/password
      await AuthService.logout(oldUsername);
      // Set new username as current
      await AuthService.login(newUsername, password);
      if (mounted) Navigator.of(context).pop(newUsername);
    } catch (e) {
      setState(() {
        _error = 'Failed to change username';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Username'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'New Username'),
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Enter a username'
                          : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                    if (_formKey.currentState!.validate()) _submit();
                  },
          child:
              _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Change'),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (newPassword.isEmpty || oldPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'All fields are required.';
      });
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() {
        _isLoading = false;
        _error = 'New passwords do not match.';
      });
      return;
    }
    try {
      final username = await AuthService.getCurrentUsername();
      if (username == null) throw Exception('No user logged in');
      final storedPassword = await AuthService.getPasswordForUsername(username);
      if (storedPassword != oldPassword) {
        setState(() {
          _isLoading = false;
          _error = 'Old password is incorrect.';
        });
        return;
      }
      await AuthService.saveCredentials(username, newPassword);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = 'Failed to change password.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            TextFormField(
              controller: _oldPasswordController,
              obscureText: _obscureOld,
              decoration: InputDecoration(
                labelText: 'Old Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureOld = !_obscureOld;
                    });
                  },
                ),
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Enter old password'
                          : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                ),
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Enter new password'
                          : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirm new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                    if (_formKey.currentState!.validate()) {
                      _submit();
                    }
                  },
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Change'),
        ),
      ],
    );
  }
}
