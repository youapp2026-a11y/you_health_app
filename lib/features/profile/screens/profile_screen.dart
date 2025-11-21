import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await supabase.from('users').select().eq('id', user.id).single();
        setState(() {
          _userProfile = response;
          _isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching profile: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/edit-profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? const Center(child: Text('No profile data found.'))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    CircleAvatar(
                      radius: 50,
                      child: Text(_userProfile!['name']?[0] ?? 'U', style: const TextStyle(fontSize: 40)),
                    ),
                    const SizedBox(height: 16),
                    Center(child: Text(_userProfile!['name'] ?? '', style: Theme.of(context).textTheme.titleLarge)),
                    Center(child: Text(supabase.auth.currentUser?.email ?? '', style: Theme.of(context).textTheme.bodyMedium)),
                    const SizedBox(height: 24),
                    _buildProfileDetail(context, 'Age', _userProfile!['age']?.toString() ?? 'N/A'),
                    _buildProfileDetail(context, 'Height', '${_userProfile!['height']?.toString() ?? 'N/A'} cm'),
                    _buildProfileDetail(context, 'Weight', '${_userProfile!['weight']?.toString() ?? 'N/A'} kg'),
                    _buildProfileDetail(context, 'Gender', _userProfile!['gender'] ?? 'N/A'),
                  ],
                ),
    );
  }

  Widget _buildProfileDetail(BuildContext context, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
