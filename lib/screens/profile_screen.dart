import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_ninja/in_app_ninja.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // For logout navigation

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Loading...';
  String _city = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    AppNinja.track('profile_viewed', properties: {
      'user_tier': 'bbStar',
      'days_since_signup': 120, // Mock
      'notifications_enabled': true
    });
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _name = prefs.getString('user_name') ?? 'User';
      _city = prefs.getString('user_city') ?? 'Unknown';
      _email = user?.email ?? '';
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear local session
    
    AppNinja.track('logout_clicked', properties: {
      'session_duration_minutes': 45, // Mock
      'reason': 'user_action'
    });
    AppNinja.logout(); // Clear SDK session

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EmbedWidgetWrapper(
      id: 'profile_screen_scaffold',
      child: Scaffold(
        appBar: AppBar(title: const Text('My Account')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                color: const Color(0xFF689F38),
                child: EmbedWidgetWrapper(
                  id: 'profile_header_section',
                  child: Row(
                    children: [
                      EmbedWidgetWrapper(
                        id: 'profile_pic',
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 40, color: Color(0xFF689F38)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EmbedWidgetWrapper(
                            id: 'profile_name_text', 
                            child: Text(_name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
                          ),
                          EmbedWidgetWrapper(
                            id: 'profile_email_text',
                            child: Text(_email, style: const TextStyle(color: Colors.white70))
                          ),
                          Text(_city, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Menu Items
              _buildMenuItem(Icons.shopping_bag_outlined, 'My Orders'),
              _buildMenuItem(Icons.favorite_border, 'Wishlist'),
              _buildMenuItem(Icons.location_on_outlined, 'My Addresses'),
              _buildMenuItem(Icons.payment, 'Payment Methods'),
              _buildMenuItem(Icons.notifications_none, 'Notifications'),
              _buildMenuItem(Icons.help_outline, 'Customer Support'),
              
              const SizedBox(height: 24),
              EmbedWidgetWrapper(
                id: 'profile_logout_btn',
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () {
                     AppNinja.track('logout_clicked');
                     _logout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return EmbedWidgetWrapper(
      id: 'profile_menu_${title.replaceAll(' ', '_').toLowerCase()}',
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          AppNinja.track('profile_menu_clicked', properties: {'menu_item': title});
          // Mock Navigation
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Clicked $title')));
        },
      ),
    );
  }
}
