import 'package:flutter/material.dart';

class CredentialPage extends StatefulWidget {
  final Map<String, String>? existingCredential; // null = add mode

  const CredentialPage({super.key, this.existingCredential});

  @override
  State<CredentialPage> createState() => _CredentialPageState();
}

class _CredentialPageState extends State<CredentialPage> {
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _noteController;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final data = widget.existingCredential ?? {};

    _titleController = TextEditingController(text: data['title'] ?? '');
    _usernameController = TextEditingController(text: data['username'] ?? '');
    _passwordController = TextEditingController(text: data['password'] ?? '');
    _noteController = TextEditingController(text: data['note'] ?? '');
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _generateRandomPassword() {
    // For now, use a placeholder. We'll generate a real one later.
    const generated = 'P@ssw0rd123!';
    _passwordController.text = generated;
  }

  void _saveCredential() {
    final newCredential = {
      'title': _titleController.text,
      'username': _usernameController.text,
      'password': _passwordController.text,
      'note': _noteController.text,
    };

    // TODO: Save or update in secure storage
    Navigator.pop(context, newCredential); // Return to previous screen
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingCredential != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Credential' : 'Add Credential'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username / Email',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _generateRandomPassword,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCredential,
                child: Text(isEdit ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
