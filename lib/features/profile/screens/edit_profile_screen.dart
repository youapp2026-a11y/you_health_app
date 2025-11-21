
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';
import '../models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<UserProfile?> _profileFuture;

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Dropdown values
  String? _gender;
  String? _activityLevel;
  String? _fitnessGoal;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchAndPopulateProfile();
  }

  Future<UserProfile?> _fetchAndPopulateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    final response = await supabase.from('users').select().eq('id', user.id).single();
    final profile = UserProfile.fromMap(response);

    // Populate controllers and dropdowns
    _nameController.text = profile.name;
    _ageController.text = profile.age.toString();
    _heightController.text = profile.height.toString();
    _weightController.text = profile.weight.toString();
    setState(() {
      _gender = profile.gender;
      _activityLevel = profile.activityLevel;
      _fitnessGoal = profile.fitnessGoal;
    });

    return profile;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are not logged in.')),
        );
        return;
      }

      try {
        await supabase.from('users').update({
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'gender': _gender,
          'height': double.parse(_heightController.text),
          'weight': double.parse(_weightController.text),
          'activity_level': _activityLevel,
          'fitness_goal': _fitnessGoal,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Could not load profile.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female', 'Other']
                        .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                        .toList(),
                    onChanged: (value) => setState(() => _gender = value),
                    validator: (value) => value == null ? 'Please select your gender' : null,
                  ),
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Please enter your height' : null,
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Please enter your weight' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _activityLevel,
                    decoration: const InputDecoration(labelText: 'Activity Level'),
                    items: [
                      'Sedentary',
                      'Lightly Active',
                      'Moderately Active',
                      'Very Active'
                    ]
                        .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                        .toList(),
                    onChanged: (value) => setState(() => _activityLevel = value),
                    validator: (value) => value == null ? 'Please select your activity level' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _fitnessGoal,
                    decoration: const InputDecoration(labelText: 'Fitness Goal'),
                    items: ['Lose Weight', 'Maintain Weight', 'Gain Muscle']
                        .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                        .toList(),
                    onChanged: (value) => setState(() => _fitnessGoal = value),
                    validator: (value) => value == null ? 'Please select your fitness goal' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
