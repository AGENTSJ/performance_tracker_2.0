import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Example user data fields
  String _name = '';
  int _age = 18;
  double _weight = 60.0;
  double _height = 170.0;
  String _gender = 'Male';

  // Simulate loading user data (replace with real data source)
  void _loadUserData() {
    setState(() {
      _name = 'John Doe';
      _age = 25;
      _weight = 72.5;
      _height = 178.0;
      _gender = 'Male';
    });
  }

  // Simulate saving user data (replace with real data source)
  void _saveUserData() {
    // Save logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                child: Icon(Icons.person, size: 48),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => _name = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => _gender = val ?? 'Male'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _age.toString(),
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) =>
                    _age = int.tryParse(val ?? '') ?? _age,
                validator: (val) {
                  final age = int.tryParse(val ?? '');
                  if (age == null || age < 10 || age > 100) {
                    return 'Enter a valid age (10-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _weight.toString(),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) =>
                    _weight = double.tryParse(val ?? '') ?? _weight,
                validator: (val) {
                  final weight = double.tryParse(val ?? '');
                  if (weight == null || weight < 30 || weight > 300) {
                    return 'Enter a valid weight (30-300 kg)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _height.toString(),
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) =>
                    _height = double.tryParse(val ?? '') ?? _height,
                validator: (val) {
                  final height = double.tryParse(val ?? '');
                  if (height == null || height < 100 || height > 250) {
                    return 'Enter a valid height (100-250 cm)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    _saveUserData();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}