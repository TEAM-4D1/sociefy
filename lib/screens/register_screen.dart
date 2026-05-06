import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Allows new students to create an account with display name, email, and password.
/// Includes form validation and navigation back to SignInScreen.
/// Accessible only to unauthenticated users.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _color1 = ColorTween(
      begin: const Color(0xFF4A0072),
      end: const Color(0xFF1A237E),
    ).animate(_animController);

    _color2 = ColorTween(
      begin: const Color(0xFF1A237E),
      end: const Color(0xFF4A0072),
    ).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates form input and creates a new user account via Firebase Authentication
  /// with the provided display name. Navigation is handled reactively by AppState.
  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authService = AuthService();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final displayName = _displayNameController.text.trim();

    final result = await authService.register(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
      return;
    }

    await result.user?.updateDisplayName(displayName);
    await result.user?.reload();
    // Navigation handled by authStateChanges in AppState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use pop() not pushReplacement — RegisterScreen is pushed onto the stack
        // from SignInScreen, so popping is the correct way back.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Register'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _color1.value ?? const Color(0xFF4A0072),
                  _color2.value ?? const Color(0xFF1A237E),
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join your university societies',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _displayNameController,
                          decoration: _inputDecoration('Display Name'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your display name';
                            }
                            if (value.trim().length < 2) {
                              return 'Display name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration('Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration('Password').copyWith(
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4A0072),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () => _register(context),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Creates a consistent white-filled InputDecoration for form fields.
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
