import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/meal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/constants.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  String _foodItem = '';
  int _calories = 0;
  String _mealType = 'Breakfast'; // Default value

  Future<void> _submitMeal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = supabase.auth.currentUser;
      if (user != null) {
        final meal = Meal(
          id: '',
          userId: user.id,
          foodItem: _foodItem,
          calories: _calories,
          mealType: _mealType,
          createdAt: DateTime.now(),
        );
        try {
          await supabase.from('meals').insert(meal.toJson());
          if (mounted) {
            context.pop();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving meal: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Meal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Food Item'),
                onSaved: (value) => _foodItem = value!,
                validator: (value) => value!.isEmpty ? 'Please enter a food item' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _calories = int.parse(value!),
                validator: (value) => value!.isEmpty ? 'Please enter calories' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _mealType,
                decoration: const InputDecoration(labelText: 'Meal Type'),
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _mealType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitMeal,
                child: const Text('Add Meal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
