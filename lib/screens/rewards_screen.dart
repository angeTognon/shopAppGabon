import 'package:flutter/material.dart';
import '../models/user_model.dart';

class RewardsScreen extends StatefulWidget {
  final User user;

  const RewardsScreen({super.key, required this.user});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  String _selectedStore = 'Toutes';

  // Liste des boutiques disponibles (à adapter selon tes données réelles)
  final List<String> _stores = [
    'Toutes',
    'Boutique Fashion',
    'Café Paris',
    'Tech Store',
  ];

  final List<String> _categories = [
    'Tous',
    'Shopping',
    'Restaurant',
    'Technologie',
    'Divertissement'
  ];

  // Ajoute la propriété 'store' à chaque Reward
  final List<Reward> _rewards = [
    Reward(
      id: 1,
      title: 'Réduction 20%',
      description: 'Sur votre prochain achat',
      points: 500,
      category: 'Shopping',
      available: true,
      iconName: 'shopping_bag',
      color: '0xFF3B82F6',
      store: 'Boutique Fashion',
    ),
    Reward(
      id: 2,
      title: 'Café gratuit',
      description: 'Dans nos partenaires cafés',
      points: 200,
      category: 'Restaurant',
      available: true,
      iconName: 'local_cafe',
      color: '0xFF8B4513',
      store: 'Café Paris',
    ),
    Reward(
      id: 3,
      title: 'Écouteurs Bluetooth',
      description: 'Écouteurs sans fil premium',
      points: 2000,
      category: 'Technologie',
      available: true,
      iconName: 'headphones',
      color: '0xFF8B5CF6',
      store: 'Tech Store',
    ),
    Reward(
      id: 4,
      title: 'Smartphone Premium',
      description: 'Dernier modèle disponible',
      points: 5000,
      category: 'Technologie',
      available: false,
      iconName: 'smartphone',
      color: '0xFF1F2937',
      store: 'Tech Store',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredRewards = _rewards.where((reward) {
      final matchesSearch = reward.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          reward.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Tous' || reward.category == _selectedCategory;
      final matchesStore = _selectedStore == 'Toutes' || reward.store == _selectedStore;
      return matchesSearch && matchesCategory && matchesStore;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Récompenses',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "b",
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, color: Color(0xFF3B82F6)),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                    const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Rechercher une récompense...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15,),            
            // Remplace le widget DropdownButton du filtre boutique par ce widget plus esthétique :
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _stores.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final store = _stores[index];
                    final isSelected = _selectedStore == store;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStore = store;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              store == 'Toutes'
                                  ? Icons.store_mall_directory
                                  : store == 'Boutique Fashion'
                                      ? Icons.shopping_bag
                                      : store == 'Café Paris'
                                          ? Icons.local_cafe
                                          : Icons.devices_other,
                              size: 18,
                              color: isSelected ? Colors.white : const Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              store,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                                fontFamily: "b",
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // ...existing code...

            const SizedBox(height: 6),

            // Categories
            Container(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12,bottom: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                          category,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "r",
                            fontWeight: FontWeight.w500,
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

            // Rewards list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredRewards.length,
                itemBuilder: (context, index) {
                  final reward = filteredRewards[index];
                  return _buildRewardCard(reward);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    final color = Color(int.parse(reward.color));
    final canAfford = widget.user.points >= reward.points;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  _getIconData(reward.iconName),
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
                      reward.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: "b",
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.description,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: "r",
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(
                          '${reward.points} points',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: "b",
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        if (!reward.available) ...[
                          const SizedBox(width: 16),
                          const Text(
                            'Indisponible',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "b",
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(width: 16),
                        // Affiche le nom de la boutique
                        Text(
                          reward.store,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: "r",
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: reward.available && canAfford ? () => _redeemReward(reward) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: reward.available && canAfford
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFFE5E7EB),
                foregroundColor: reward.available && canAfford
                    ? Colors.white
                    : const Color(0xFF9CA3AF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                !reward.available
                    ? 'Indisponible'
                    : !canAfford
                        ? 'Points insuffisants'
                        : 'Échanger',
                style: const TextStyle(
                  fontFamily: "b",
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'headphones':
        return Icons.headphones;
      case 'smartphone':
        return Icons.smartphone;
      default:
        return Icons.card_giftcard;
    }
  }

  void _redeemReward(Reward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer l\'échange'),
        content: Text('Voulez-vous échanger ${reward.points} points contre "${reward.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle reward redemption
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${reward.title} échangé avec succès !'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}