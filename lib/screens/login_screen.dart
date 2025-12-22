import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_ninja/in_app_ninja.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // To access HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  
  bool _isLoading = false;
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    AppNinja.track('login_viewed', properties: {
      'prev_attempt_failed': false,
      'auth_method_default': 'email'
    });
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;
      if (_isLogin) {
        // LOGIN FLOW
        AppNinja.track('login_submit_clicked', properties: {
          'type': 'login',
          'email_domain': _emailController.text.contains('@') ? _emailController.text.split('@').last : 'invalid',
          'password_length': _passwordController.text.length
        });
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // SIGN UP FLOW
        AppNinja.track('signup_submit_clicked', properties: {
          'type': 'signup',
          'email_domain': _emailController.text.contains('@') ? _emailController.text.split('@').last : 'invalid',
          'phone_provided': _phoneController.text.isNotEmpty
        });
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      // 🎯 DYNAMIC IDENTIFICATION
      // In a real app, you would fetch name/city from Firestore here.
      // For this demo, we use the text inputs.
      
      final userId = userCredential.user!.uid;
      final name = _nameController.text.isNotEmpty ? _nameController.text : 'BigBasket User';
      final city = _cityController.text.isNotEmpty ? _cityController.text : 'Unknown';
      final phone = _phoneController.text.isNotEmpty ? _phoneController.text : '';
      final gender = _selectedGender ?? 'Unknown';

      // Save locally to persist session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      await prefs.setString('user_name', name);
      await prefs.setString('user_city', city);

      
      // 🎯 FIRESTORE STORAGE
      // Save user data to Firestore so it appears in the database console
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'name': name,
          'email': _emailController.text.trim(),
          'city': city,
          'phone': phone,
          'gender': gender,
          'plan': 'bb_star',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // Merge ensures we don't overwrite existing data on login
      } catch (e) {
        debugPrint('Firestore Error: $e');
        // Don't block login if Firestore fails, but log it
      }

      // Call SDK
      await AppNinja.identify({
        'user_id': userId,
        'name': name,
        'city': city,
        'phone': phone,
        'gender': gender,
        'email': _emailController.text.trim(),
        'plan': 'bb_star', 
        
        // 🌟 ALL AVAILABLE PROPERTIES (Enriched Metadata)
        'is_anonymous': userCredential.user?.isAnonymous ?? false,
        'email_verified': userCredential.user?.emailVerified ?? false,
        'creation_time': userCredential.user?.metadata.creationTime?.toIso8601String(),
        'last_sign_in_time': userCredential.user?.metadata.lastSignInTime?.toIso8601String(),
        'provider': userCredential.user?.providerData.isNotEmpty == true 
            ? userCredential.user!.providerData.first.providerId 
            : 'password',
        'app_version': '1.0.0+1', // Example of app-specific data
        'platform': Theme.of(context).platform.toString(),
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NinjaApp(child: HomeScreen())),
        );
      }

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Auth Failed'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo
              const Icon(Icons.shopping_basket, size: 80, color: Color(0xFF689F38)),
              const SizedBox(height: 16),
              const Text(
                'bigbasket',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Text(
                'A TATA Enterprise',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _isLogin = true),
                    child: Text('Login', style: TextStyle(fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal, fontSize: 18, color: _isLogin ? const Color(0xFF689F38) : Colors.grey)),
                  ),
                  const Text('|'),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = false),
                    child: Text('Sign Up', style: TextStyle(fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal, fontSize: 18, color: !_isLogin ? const Color(0xFF689F38) : Colors.grey)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              ),
              
              // Extra fields needed for dynamic identification demo
              if (!_isLogin) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                        value: _selectedGender,
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => _selectedGender = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
              ],

              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF689F38),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isLogin ? 'Login' : 'Create Account', style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
