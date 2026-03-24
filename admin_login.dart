import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/theme.dart';
import 'admin_dashboard.dart';
import 'admin_signup.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool showPass = false;
  bool isLoading = false;

  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  Future<void> login() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      msg("All fields required");
      return;
    }

    setState(() => isLoading = true);

    try {
      // Check if admin exists in Firestore
      final adminSnap = await _firestore
          .collection('admin_users')
          .where('email', isEqualTo: emailCtrl.text.trim())
          .where('password', isEqualTo: passCtrl.text.trim())
          .where('status', isEqualTo: 'active')
          .get();

      if (adminSnap.docs.isEmpty) {
        msg("Invalid email or password");
        setState(() => isLoading = false);
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } catch (e) {
      msg("Login failed: $e");
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
      body: Padding(
        padding: const EdgeInsets.all(20),
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
                      child: const Icon(Icons.admin_panel_settings),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            Text(
              'Admin Login',
              style: AppTheme.headingStyle,
            ),
            const SizedBox(height: 10),

            Text(
              'Manage your TRACKiD system',
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 40),

            // Email Field
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "admin@srm.com",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            TextField(
              controller: passCtrl,
              obscureText: !showPass,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    showPass ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => showPass = !showPass),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Login Button
            ElevatedButton(
              style: AppTheme.primaryButtonStyle(),
              onPressed: isLoading ? null : login,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Login"),
            ),
            const SizedBox(height: 20),

            // Back to Parent Login
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back to Parent Login"),
            ),
            const SizedBox(height: 10),

            // Sign Up Button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminSignUpPage(),
                  ),
                );
              },
              child: const Text(
                "New Admin? Create Account",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}
