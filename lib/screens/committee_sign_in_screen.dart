import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/main_tabs.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/services/auth_service.dart';

class CommitteeSignInScreen extends StatefulWidget {
  const CommitteeSignInScreen({super.key});

  @override
  State<CommitteeSignInScreen> createState() => _CommitteeSignInScreenState();
}

class _CommitteeSignInScreenState extends State<CommitteeSignInScreen> {
  // Map of valid admin credentials
  static const Map<String, String> _validAdminCredentials = {
    'jburfoot12@gmail.com': '111444',
    'up2306278@myport.ac.uk': '123456',
  };

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInAsCommitteeOrAdmin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final enteredEmail = _emailController.text.trim().toLowerCase();
    final enteredPassword = _passwordController.text.trim();

    if (_validAdminCredentials[enteredEmail] != enteredPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid admin credentials.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Set admin pending flag before Firebase auth
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setAdminPending(true);

    final result = await AuthService().signIn(
      enteredEmail,
      enteredPassword,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) {
      appState.setAdminPending(false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainTabs()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Committee/Admin Sign in')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 72,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Committee & Admin Portal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Use your committee/admin credentials to sign in.',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter committee/admin email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Committee/Admin Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter committee/admin password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Committee/Admin Password',
                        filled: true,
                        fillColor: Colors.white,
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            _signInAsCommitteeOrAdmin(context);
                          }
                        },
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.login),
                        label: Text(
                          _isLoading
                              ? 'Signing in...'
                              : 'Sign in as Committee/Admin',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4A148C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
  }
}
