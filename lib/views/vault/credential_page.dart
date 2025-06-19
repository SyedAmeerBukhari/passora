import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../models/credential.dart';

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

  void _saveCredential() async {
    developer.log('Save credential pressed', name: 'CredentialPage');
    final newCredential = Credential(
      title: _titleController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    if (widget.existingCredential != null) {
      // Update existing
      final box = StorageService.credentialBox;
      final index = box.values.toList().indexWhere(
        (c) =>
            c.title == widget.existingCredential!['title'] &&
            c.username == widget.existingCredential!['username'] &&
            c.password == widget.existingCredential!['password'] &&
            (c.note ?? '') == (widget.existingCredential!['note'] ?? ''),
      );
      if (index != -1) {
        final existing = box.getAt(index);
        if (existing != null) {
          developer.log(
            'Updating existing credential: ${existing.title}',
            name: 'CredentialPage',
          );
          existing.title = newCredential.title;
          existing.username = newCredential.username;
          existing.password = newCredential.password;
          existing.note = newCredential.note;
          await existing.save();
        }
      }
    } else {
      developer.log(
        'Adding new credential: ${newCredential.title}',
        name: 'CredentialPage',
      );
      await StorageService.credentialBox.add(newCredential);
    }
    if (mounted) {
      developer.log(
        'Credential save complete, popping page',
        name: 'CredentialPage',
      );
      Navigator.pop(context, {
        'title': newCredential.title,
        'username': newCredential.username,
        'password': newCredential.password,
        'note': newCredential.note ?? '',
      });
    }
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
