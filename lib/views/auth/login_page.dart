import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _error = null;
    developer.log('LoginPage initState called', name: 'LoginPage');
  }

  Future<void> _handleLogin() async {
    developer.log(
      'Login attempt for username: "+_usernameController.text.trim()+"',
      name: 'LoginPage',
    );
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AuthService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      developer.log('AuthService.login successful', name: 'LoginPage');
      await StorageService.initForUser(_usernameController.text.trim());
      developer.log('StorageService.initForUser successful', name: 'LoginPage');
      if (!mounted) return;
      setState(() {
        _error = null;
      });
      context.go('/home'); // Navigate to home if successful
      developer.log('Navigated to /home', name: 'LoginPage');
    } catch (e) {
      developer.log(
        'Login failed: "+e.toString()',
        name: 'LoginPage',
        error: e,
      );
      if (!mounted) return;
      setState(() {
        _error = 'Invalid username or password';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      developer.log('Login process finished', name: 'LoginPage');
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
                child: const Icon(Icons.lock, size: 48, color: Colors.teal),
              ),
              const SizedBox(height: 16),
              Text(
                'Passora',
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
                          obscureText: _obscurePassword,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter password'
                                      : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.login),
                            label:
                                _isLoading
                                    ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text('Login'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.teal,
                            ),
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      if (_formKey.currentState!.validate()) {
                                        _handleLogin();
                                      }
                                    },
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    context.go('/signup');
                                  },
                          child: const Text('Don’t have an account? Sign up'),
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
