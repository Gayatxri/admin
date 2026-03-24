import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/theme.dart';
import 'admin_login.dart';

class AdminSignUpPage extends StatefulWidget {
  const AdminSignUpPage({super.key});

  @override
  State<AdminSignUpPage> createState() => _AdminSignUpPageState();
}

class _AdminSignUpPageState extends State<AdminSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  bool showPass = false;
  bool showConfirmPass = false;
  bool isLoading = false;

  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  Future<void> registerAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    if (passCtrl.text != confirmPassCtrl.text) {
      msg("Passwords don't match");
      return;
    }

    setState(() => isLoading = true);

    try {
      // Check if email already exists
      final existing = await _firestore
          .collection('admin_users')
          .where('email', isEqualTo: emailCtrl.text.trim())
          .get();

      if (existing.docs.isNotEmpty) {
        msg("Email already registered");
        setState(() => isLoading = false);
        return;
      }

      // Create admin user in Firestore
      await _firestore.collection('admin_users').add({
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'password': passCtrl.text.trim(), // In production, use hashing
        'role': 'admin',
        'status': 'active',
        'createdAt': DateTime.now(),
        'createdBy': 'system', // You can track who created this admin
      });

      if (!mounted) return;

      msg("Admin account created successfully!");

      // Navigate back to login
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      );
    } catch (e) {
      msg("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void msg(String t) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text('Create Admin Account'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/srm.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  'Register New Admin',
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 8),

                Text(
                  'Create a new administrator account',
                  style: AppTheme.bodyStyle,
                ),
                const SizedBox(height: 32),

                // Full Name Field
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Please enter full name" : null,
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "admin@srm.com",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return "Please enter email";
                    if (!v.contains('@')) return "Invalid email format";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Field
                TextFormField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Please enter phone number" : null,
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: passCtrl,
                  obscureText: !showPass,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPass
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => showPass = !showPass),
                    ),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return "Please enter password";
                    if (v.length < 6)
                      return "Password must be at least 6 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: confirmPassCtrl,
                  obscureText: !showConfirmPass,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPass
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => showConfirmPass = !showConfirmPass,
                      ),
                    ),
                  ),
                  validator: (v) => v!.isEmpty
                      ? "Please confirm password"
                      : null,
                ),
                const SizedBox(height: 32),

                // Register Button
                ElevatedButton(
                  style: AppTheme.primaryButtonStyle(),
                  onPressed: isLoading ? null : registerAdmin,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text("Create Admin Account"),
                ),
                const SizedBox(height: 16),

                // Back to Login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }
}
