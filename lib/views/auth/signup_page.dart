import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    developer.log('Signup submit pressed', name: 'SignupPage');
    if (_formKey.currentState!.validate()) {
      try {
        final username = _usernameController.text.trim();
        final password = _passwordController.text;
        developer.log(
          'Attempting to save credentials for username: $username',
          name: 'SignupPage',
        );
        await AuthService.saveCredentials(username, password);
        developer.log(
          'Credentials saved for username: $username',
          name: 'SignupPage',
        );
        // Optionally, initialize the user's vault after signup
        // await StorageService.initForUser(username);
        if (!mounted) return;
        developer.log('Navigating to /login after signup', name: 'SignupPage');
        context.go('/login');
      } catch (e) {
        developer.log('Signup failed: $e', name: 'SignupPage', error: e);
        setState(() {
          _error = 'Failed to create account. Please try again.';
        });
      }
    } else {
      developer.log('Signup form validation failed', name: 'SignupPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal[100],
                child: const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.teal[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 6,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Enter username'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter password'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Confirm your password';
                            if (value != _passwordController.text)
                              return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.person_add),
                            label: const Text('Sign Up'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.teal,
                            ),
                            onPressed: _submit,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          child: const Text('Already have an account? Log in'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
