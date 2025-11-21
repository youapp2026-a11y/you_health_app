import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _age = 0;
  double _height = 0.0;
  double _weight = 0.0;
  String _gender = 'Other';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await supabase.from('users').select().eq('id', user.id).single();
        setState(() {
          _name = response['name'] ?? '';
          _age = response['age'] ?? 0;
          _height = (response['height'] as num?)?.toDouble() ?? 0.0;
          _weight = (response['weight'] as num?)?.toDouble() ?? 0.0;
          _gender = response['gender'] ?? 'Other';
          _isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = supabase.auth.currentUser;
      if (user != null) {
        try {
          await supabase.from('users').update({
            'name': _name,
            'age': _age,
            'height': _height,
            'weight': _weight,
            'gender': _gender,
          }).eq('id', user.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
            context.pop();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value!,
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                initialValue: _age.toString(),
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _age = int.parse(value!),
                validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
              ),
              TextFormField(
                initialValue: _height.toString(),
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _height = double.parse(value!),
                validator: (value) => value!.isEmpty ? 'Please enter your height' : null,
              ),
              TextFormField(
                initialValue: _weight.toString(),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _weight = double.parse(value!),
                validator: (value) => value!.isEmpty ? 'Please enter your weight' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _gender = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
