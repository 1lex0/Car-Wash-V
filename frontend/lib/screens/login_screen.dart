import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/auth_api.dart';
import '../data/result.dart';
import '../models/car_wash_catalog_model.dart';
import '../models/profile_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _hidePassword = true;
  bool _isRegister = false;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthApi>();
    setState(() => _busy = true);
    final result = _isRegister
        ? await auth.register(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          )
        : await auth.login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case Ok():
        context.read<CarWashCatalogModel>().load();
        context.read<ProfileModel>().load();
        context.go('/home');
      case Err(:final msg):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8DF),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    Text(
                      _isRegister ? 'Create account' : 'Welcome back',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F3A33),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _isRegister
                          ? 'Sign up to continue'
                          : 'Log in to continue',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6F7D78),
                      ),
                    ),

                    const SizedBox(height: 36),

                    if (_isRegister) ...[
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          filled: true,
                          fillColor: const Color(0xFFF7F4EE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          final name = value?.trim() ?? '';
                          if (name.isEmpty) return 'Name is required';
                          if (name.length < 2) return 'Minimum 2 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _emailController,

                      keyboardType: TextInputType.emailAddress,

                      textInputAction: TextInputAction.next,

                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: const Color(0xFFF7F4EE),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),

                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Email is required';
                        }

                        if (!email.contains('@')) {
                          return 'Enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,

                      obscureText: _hidePassword,

                      textInputAction: TextInputAction.done,

                      onFieldSubmitted: (_) {
                        _submit();
                      },

                      decoration: InputDecoration(
                        labelText: 'Password',

                        filled: true,
                        fillColor: const Color(0xFFF7F4EE),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }

                        if (value.length < 6) {
                          return 'Minimum 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: _busy ? null : _submit,

                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3A33),

                        minimumSize: const Size.fromHeight(56),
                      ),

                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isRegister ? 'Sign up' : 'Log in'),
                    ),

                    const SizedBox(height: 14),

                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _isRegister = !_isRegister),
                      child: Text(
                        _isRegister
                            ? 'I already have an account'
                            : 'Create an account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
