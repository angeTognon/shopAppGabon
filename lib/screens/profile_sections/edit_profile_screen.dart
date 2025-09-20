// filepath: [edit_profile_screen.dart](http://_vscodecontentref_/0)
import 'package:flutter/material.dart';
import 'package:gabon_client_app/const.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdate;

  const EditProfileScreen({super.key, required this.user, required this.onUserUpdate});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    final url = '$baseUrl/update_client.php'; 
    final body = jsonEncode({
      'id': widget.user.id,
      'email': _emailController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final updatedUser = widget.user.copyWith(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        );
        widget.onUserUpdate(updatedUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur réseau'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildInputGroup({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: "r",
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: "r",
              fontSize: 13,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
        ),
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
            fontSize: 17,
            fontFamily: "b",
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _handleSave,
            icon: const Icon(Icons.save, color: Color(0xFF3B82F6)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputGroup(
              label: 'Prénom',
              controller: _firstNameController,
              icon: Icons.person,
            ),
            _buildInputGroup(
              label: 'Nom',
              controller: _lastNameController,
              icon: Icons.person,
            ),
            _buildInputGroup(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildInputGroup(
              label: 'Téléphone',
              controller: _phoneController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Sauvegarder les modifications',
                        style: TextStyle(
                          fontFamily: "b",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}