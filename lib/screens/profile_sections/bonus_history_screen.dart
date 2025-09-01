import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class BonusHistoryScreen extends StatefulWidget {
  final User user;

  const BonusHistoryScreen({super.key, required this.user});

  @override
  State<BonusHistoryScreen> createState() => _BonusHistoryScreenState();
}

class _BonusHistoryScreenState extends State<BonusHistoryScreen> {
  String _selectedPeriod = 'Tous';
  final List<String> _periods = ['Tous', 'Cette semaine', 'Ce mois', 'Cette année'];

  final List<Bonus> _bonuses = [
    Bonus(
      id: 1,
      title: 'Bonus d\'anniversaire',
      description: 'Bonus spécial pour votre anniversaire',
      points: 500,
      dateEarned: '2024-01-15',
      type: 'birthday',
      iconName: 'card_giftcard',
      color: '0xFF8B5CF6',
    ),
    Bonus(
      id: 2,
      title: 'Niveau Gold atteint',
      description: 'Félicitations ! Vous avez atteint le niveau Gold',
      points: 1000,
      dateEarned: '2024-01-10',
      type: 'tier',
      iconName: 'emoji_events',
      color: '0xFFFFD700',
    ),
    Bonus(
      id: 3,
      title: '10ème achat',
      description: 'Bonus pour votre 10ème achat',
      points: 200,
      dateEarned: '2024-01-05',
      type: 'milestone',
      iconName: 'star',
      color: '0xFFF59E0B',
    ),
    Bonus(
      id: 4,
      title: 'Première inscription',
      description: 'Bonus de bienvenue',
      points: 100,
      dateEarned: '2023-12-20',
      type: 'special',
      iconName: 'check_circle',
      color: '0xFF10B981',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalBonusPoints = _bonuses.fold<int>(0, (sum, bonus) => sum + bonus.points);

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
          'Historique des bonus',
          style: TextStyle(
            fontSize: 16,
                      fontFamily: "b",
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
      body: Column(
        children: [
          // Total Bonus Points
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 24,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          totalBonusPoints.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                      fontFamily: "b",
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Points bonus gagnés',
                          style: TextStyle(
                            fontSize: 14,
                      fontFamily: "r",
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Period filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _periods.length,
              itemBuilder: (context, index) {
                final period = _periods[index];
                final isSelected = _selectedPeriod == period;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        period,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                      fontFamily: "r",
                          color: isSelected ? Colors.white : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Bonus list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _bonuses.length,
              itemBuilder: (context, index) {
                final bonus = _bonuses[index];
                return _buildBonusCard(bonus);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusCard(Bonus bonus) {
    final color = Color(int.parse(bonus.color));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(bonus.iconName),
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bonus.title,
                      style: const TextStyle(
                        fontSize: 14,
                      fontFamily: "b",
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bonus.description,
                      style: const TextStyle(
                      fontFamily: "r",
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(bonus.dateEarned),
                      style: const TextStyle(
                        fontSize: 12,
                      fontFamily: "r",
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${bonus.points}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "b",
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const Text(
                    'points',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: "r",
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getBonusTypeText(bonus.type),
                style: TextStyle(
                  fontSize: 12,
                      fontFamily: "r",
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'card_giftcard': return Icons.card_giftcard;
      case 'emoji_events': return Icons.emoji_events;
      case 'star': return Icons.star;
      case 'check_circle': return Icons.check_circle;
      default: return Icons.star;
    }
  }

  String _getBonusTypeText(String type) {
    switch (type) {
      case 'milestone': return 'Étape';
      case 'special': return 'Spécial';
      case 'tier': return 'Niveau';
      case 'birthday': return 'Anniversaire';
      default: return 'Bonus';
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}