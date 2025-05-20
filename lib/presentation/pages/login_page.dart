import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _emailError;
  String? _passwordError;
  void _goToSignUp() {
    // Use go_router navigation
    if (mounted) {
      // ignore: use_build_context_synchronously
      context.go('/signup');
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://fakestoreapi.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );
      context.go('/dashboard');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Login successful!')));
            await Future.delayed(const Duration(milliseconds: 500));
            context.go('/dashboard');
          }
        } else {
          throw Exception('Invalid response: No token');
        }
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Login failed';
        String? emailError;
        String? passwordError;
        if (errorMsg.toString().toLowerCase().contains('password')) {
          passwordError = 'Incorrect Password';
        } else if (errorMsg.toString().toLowerCase().contains('username')) {
          emailError = 'Incorrect Email';
        } else {
          emailError = 'Invalid credentials';
          passwordError = 'Invalid credentials';
        }
        setState(() {
          _emailError = emailError;
          _passwordError = passwordError;
        });
        // Revalidate form to show error in validator
        _formKey.currentState?.validate();
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString().toLowerCase();
        if (!(errorStr.contains('incorrect password') ||
            errorStr.contains('incorrect email') ||
            errorStr.contains('invalid credentials'))) {
          setState(() {
            _passwordError = 'Incorrect Password';
            _emailError = 'Incorrect Email';
          });
          _formKey.currentState?.validate();
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  if (_emailError != null ||
                      (_formKey.currentState != null &&
                          _formKey.currentState!.validate() == false)) {
                    setState(() {
                      _emailError = null;
                    });
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (_emailError != null) {
                    return _emailError;
                  }
                  if (value == null || value.trim().isEmpty) {
                    // Only show required error if field is untouched or empty and not being edited
                    if (!_emailController.text.isEmpty) return null;
                    return 'Enter your email';
                  }
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  if (_passwordError != null ||
                      (_formKey.currentState != null &&
                          _formKey.currentState!.validate() == false)) {
                    setState(() {
                      _passwordError = null;
                    });
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (_passwordError != null) {
                    return _passwordError;
                  }
                  if (value == null || value.isEmpty) {
                    // Only show required error if field is untouched or empty and not being edited
                    if (!_passwordController.text.isEmpty) return null;
                    return 'Enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Login'),
                  ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _goToSignUp,
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
