import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/screens/committee_sign_in_screen.dart';
import 'package:sociefy/screens/register_screen.dart';
import 'package:sociefy/services/auth_service.dart';
import 'package:sociefy/widgets/app_bar_logo_action.dart';

/// The primary authentication entry point for Sociefy.
/// Provides email/password login for students and a separate button for committee/admin sign in.
/// Accessible to all users (guests, students, and admins) as the main entry screen.
class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  static const String _committeeAdminEmail = 'jburfoot12@gmail.com';

  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _color1 = ColorTween(
      begin: const Color(0xFF4A0072),
      end: const Color(0xFF1A237E),
    ).animate(_controller);

    _color2 = ColorTween(
      begin: const Color(0xFF1A237E),
      end: const Color(0xFF4A0072),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles student user sign in with email/password validation and Firebase authentication.
  /// Guards against admin email being used on the student portal.
  Future<void> _signInWithUop(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final enteredEmail = _emailController.text.trim().toLowerCase();
    if (enteredEmail == _committeeAdminEmail) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please use the admin sign in portal')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService().signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
      return;
    }

    // Immediately update AppState so the UI navigates without waiting
    // for the auth state listener (protects against race conditions).
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.login(userId: result.user?.uid, isAdmin: false);
    } catch (e) {
      debugPrint('Sign in: failed to update AppState: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        actions: const [AppBarLogoAction()],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _color1.value ?? const Color(0xFF4A0072),
                  _color2.value ?? const Color(0xFF1A237E),
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Sociefy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // EMAIL
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter email';
                              }
                              if (!value.contains('@')) {
                                return 'Enter valid email';
                              }
                              return null;
                            },
                            decoration: _inputDecoration('Email'),
                          ),

                          const SizedBox(height: 16),

                          // PASSWORD
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!_isLoading &&
                                  _formKey.currentState!.validate()) {
                                _signInWithUop(context);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter password';
                              }
                              return null;
                            },
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
                          ),

                          const SizedBox(height: 24),

                          // SIGN IN
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        _signInWithUop(context);
                                      }
                                    },
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Sign In'),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // GUEST
                          TextButton(
                            onPressed: () async {
                              final appState = Provider.of<AppState>(
                                context,
                                listen: false,
                              );
                              await appState.login(
                                userId: 'guest',
                                isAdmin: false,
                              );
                              if (!mounted) return;
                            },
                            child: const Text(
                              'Continue as Guest',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // REGISTER — push (not pushReplacement) so back works
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Don't have an account? Register",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // COMMITTEE — push (not pushReplacement) so back button works
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.admin_panel_settings),
                              label: const Text(
                                'Are you a committee member or admin? Sign in here',
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const CommitteeSignInScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF4A148C),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                textStyle: const TextStyle(
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
    );
  }
}
