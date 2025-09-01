import 'package:flutter/material.dart';
import '../models/user_model.dart';

class SupportScreen extends StatefulWidget {
  final User user;

  const SupportScreen({super.key, required this.user});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int? _expandedFAQ;
  final _messageController = TextEditingController();

  final List<Map<String, String>> _faqData = [
    {
      'question': 'Comment gagner des points de fidélité ?',
      'answer': 'Vous gagnez des points à chaque achat effectué. En général, 1€ dépensé = 1 point gagné. Des promotions spéciales peuvent vous permettre de gagner des points bonus.',
    },
    {
      'question': 'Quand mes points expirent-ils ?',
      'answer': 'Vos points sont valables 12 mois à partir de la date d\'acquisition. Vous recevrez une notification avant l\'expiration.',
    },
    {
      'question': 'Comment échanger mes points ?',
      'answer': 'Rendez-vous dans l\'onglet "Récompenses" pour voir toutes les récompenses disponibles. Sélectionnez celle qui vous intéresse et suivez les instructions.',
    },
    {
      'question': 'Comment modifier mes informations personnelles ?',
      'answer': 'Allez dans l\'onglet "Profil" et appuyez sur "Modifier le profil". Vous pourrez y changer vos informations personnelles.',
    },
    {
      'question': 'Puis-je transférer mes points à quelqu\'un d\'autre ?',
      'answer': 'Non, les points de fidélité sont personnels et ne peuvent pas être transférés à un autre compte.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Support',
                  style: TextStyle(
                      fontFamily: "b",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),

              // Contact options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nous contacter',
                      style: TextStyle(
                        fontSize: 16,
                      fontFamily: "b",
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildContactOption(
                      icon: Icons.chat,
                      title: 'Chat en direct',
                      subtitle: 'Disponible 9h-18h',
                      color: const Color(0xFF3B82F6),
                    ),
                    
                    _buildContactOption(
                      icon: Icons.phone,
                      title: 'Téléphone',
                      subtitle: '01 23 45 67 89',
                      color: const Color(0xFF10B981),
                    ),
                    
                    _buildContactOption(
                      icon: Icons.email,
                      title: 'Email',
                      subtitle: 'support@exemple.com',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // FAQ Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Questions fréquentes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ..._faqData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final faq = entry.value;
                      return _buildFAQItem(index, faq);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Contact form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Envoyez-nous un message',
                      style: TextStyle(
                        fontSize: 14,
                      fontFamily: "b",
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
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
                        children: [
                          TextField(
                            controller: _messageController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Décrivez votre problème ou votre question...',
                              border: OutlineInputBorder(),
                              hintStyle: TextStyle(color: Color(0xFF9CA3AF),fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _messageController.text.trim().isNotEmpty 
                                  ? _sendMessage 
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Envoyer',
                                    style: TextStyle(
                                      fontSize: 14,
                      fontFamily: "b",
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
                      fontFamily: "b",
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
                      fontFamily: "r",
            color: Color(0xFF6B7280),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        onTap: () {},
      ),
    );
  }

  Widget _buildFAQItem(int index, Map<String, String> faq) {
    final isExpanded = _expandedFAQ == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF3B82F6)),
            title: Text(
              faq['question']!,
              style: const TextStyle(
                fontSize: 12,
                      fontFamily: "b",

                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFF9CA3AF),
            ),
            onTap: () {
              setState(() {
                _expandedFAQ = isExpanded ? null : index;
              });
            },
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
              child: Text(
                faq['answer']!,
                style: const TextStyle(
                  fontSize: 12,
                      fontFamily: "r",
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message envoyé avec succès !'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _messageController.clear();
    }
  }
}