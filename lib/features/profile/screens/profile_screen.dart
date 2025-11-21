
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchUserProfile();
  }

  Future<UserProfile?> _fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    final response = await supabase.from('users').select().eq('id', user.id).single();
    return UserProfile.fromMap(response);
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        context.go('/auth');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
               context.push('/edit-profile');
            },
          ),
        ],
      ),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Could not load profile.'));
          }

          final profile = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProfileHeader(profile, context),
              const SizedBox(height: 24),
              _buildProfileDetailCard(profile, context),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: _signOut,
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile, BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          child: Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '', style: const TextStyle(fontSize: 40)),
        ),
        const SizedBox(height: 16),
        Text(profile.name, style: Theme.of(context).textTheme.headlineSmall),
        Text(supabase.auth.currentUser?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildProfileDetailCard(UserProfile profile, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Details', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            _buildDetailRow('Age', '${profile.age} years'),
            _buildDetailRow('Gender', profile.gender),
            _buildDetailRow('Height', '${profile.height} cm'),
            _buildDetailRow('Weight', '${profile.weight} kg'),
            const Divider(height: 24),
            Text('Your Goals', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            _buildDetailRow('Activity Level', profile.activityLevel),
            _buildDetailRow('Primary Goal', profile.fitnessGoal),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }
}
