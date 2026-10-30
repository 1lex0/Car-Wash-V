import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/car_wash.dart';
import '../models/car_wash_catalog_model.dart';

class CarWashFormScreen extends StatefulWidget {
  const CarWashFormScreen({super.key});

  @override
  State<CarWashFormScreen> createState() => _CarWashFormScreenState();
}

class _CarWashFormScreenState extends State<CarWashFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController(text: 'Chișinău');

  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _cityController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final draft = CarWash(
      id: 0,
      name: _nameController.text.trim(),
      area: _areaController.text.trim(),
      city: _cityController.text.trim(),
    );

    setState(() => _saving = true);
    final error = await context.read<CarWashCatalogModel>().add(draft);
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    context.pop();
  }

  String? _required(String? value, String field) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return '$field is required';
    }

    if (text.length < 2) {
      return 'Minimum 2 characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8DF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFECE8DF),
        elevation: 0,
        title: const Text(
          'Add car wash',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F3A33),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),

          child: Form(
            key: _formKey,

            autovalidateMode: AutovalidateMode.onUserInteraction,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                TextFormField(
                  controller: _nameController,

                  textInputAction: TextInputAction.next,

                  decoration: const InputDecoration(labelText: 'Name'),

                  validator: (value) => _required(value, 'Name'),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _areaController,

                  textInputAction: TextInputAction.next,

                  decoration: const InputDecoration(
                    labelText: 'Area',
                    hintText: 'e.g. Botanica',
                  ),

                  validator: (value) => _required(value, 'Area'),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _cityController,

                  textInputAction: TextInputAction.done,

                  onFieldSubmitted: (_) {
                    if (!_saving) _save();
                  },

                  decoration: const InputDecoration(labelText: 'City'),

                  validator: (value) => _required(value, 'City'),
                ),

                const SizedBox(height: 28),

                FilledButton(
                  onPressed: _saving ? null : _save,

                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3A33),

                    minimumSize: const Size.fromHeight(56),
                  ),

                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
