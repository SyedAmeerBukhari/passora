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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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
              ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          developer.log(
                            'Login button pressed',
                            name: 'LoginPage',
                          );
                          if (_formKey.currentState!.validate()) {
                            _handleLogin();
                          }
                        },
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  developer.log('Navigating to signup page', name: 'LoginPage');
                  context.go('/signup');
                },
                child: const Text('Don’t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
