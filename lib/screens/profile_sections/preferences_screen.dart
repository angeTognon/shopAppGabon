import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  Map<String, bool> _preferences = {
    'notifications': true,
    'offers': true,
    'newsletter': false,
    'sms': true,
    'location': false,
    'analytics': true,
  };

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
          'Préférences',
          style: TextStyle(
            fontSize: 16,
                      fontFamily: "b",
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPreferenceSection(
              title: 'Notifications',
              items: [
                _buildPreferenceItem(
                  icon: Icons.notifications,
                  title: 'Notifications push',
                  key: 'notifications',
                  color: const Color(0xFF3B82F6),
                ),
                _buildPreferenceItem(
                  icon: Icons.email,
                  title: 'Newsletter email',
                  key: 'newsletter',
                  color: const Color(0xFF8B5CF6),
                ),
                _buildPreferenceItem(
                  icon: Icons.sms,
                  title: 'SMS promotionnels',
                  key: 'sms',
                  color: const Color(0xFF10B981),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildPreferenceSection(
              title: 'Offres et contenu',
              items: [
                _buildPreferenceItem(
                  icon: Icons.local_offer,
                  title: 'Offres personnalisées',
                  key: 'offers',
                  color: const Color(0xFFF59E0B),
                ),
                _buildPreferenceItem(
                  icon: Icons.location_on,
                  title: 'Géolocalisation',
                  key: 'location',
                  color: const Color(0xFFEF4444),
                ),
                _buildPreferenceItem(
                  icon: Icons.analytics,
                  title: 'Analyses d\'usage',
                  key: 'analytics',
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sauvegarder les préférences',
                  style: TextStyle(
                      fontFamily: "b",
                    fontSize: 13,
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

  Widget _buildPreferenceSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                      fontFamily: "b",
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String key,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                      fontFamily: "r",
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Switch(
            value: _preferences[key] ?? false,
            onChanged: (value) {
              setState(() {
                _preferences[key] = value;
              });
            },
            activeColor: color,
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Préférences mises à jour'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
    Navigator.pop(context);
  }
}