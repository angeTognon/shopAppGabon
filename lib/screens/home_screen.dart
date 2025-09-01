import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gabon_client_app/const.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdate;

  const HomeScreen({super.key, required this.user, required this.onUserUpdate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Nouvelle offre disponible',
      'message': '20% sur votre prochain achat',
      'type': 'offer'
    },
    {
      'id': 2,
      'title': 'Points à expirer',
      'message': '500 points expirent dans 7 jours',
      'type': 'warning'
    },
  ];

  User? _user;
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    // Rafraîchit toutes les 10 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchUser();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await fetchUserById(widget.user.id);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Génère le QR code avec l'id du user
  String _userToQrData(User user) {
    return user.id.toString();
  }

  static Future<User> fetchUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/get_clientt.php?id=$id'));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return User.fromJson(data['user']);
    } else {
      throw Exception(data['error'] ?? 'Erreur lors de la récupération');
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Erreur : $_error')),
      );
    }
    final user = _user!;

    final pointsToNextTier = _getPointsToNextTier(user.points);
    final progressPercentage = _getProgressPercentage(user.points);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchUser,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (animation une seule fois)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Store name (left)
                      Expanded(
                        child: Text(
                          user.storeName,
                          style: const TextStyle(
                            fontSize:  17,
                            fontFamily: "b",
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                      // Customer name (right)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Bonjour,',
                            style: TextStyle(
                              fontFamily: "r",
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: "b",
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(
                  target: _hasAnimated ? 0 : 1,
                  onComplete: (controller) {
                    setState(() {
                      _hasAnimated = true;
                    });
                  },
                ),

                // QR Code Card (pas d'animation répétée)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Mon QR Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "b",
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: QrImageView(
                            data: _userToQrData(user),
                            version: QrVersions.auto,
                            size: 140,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scannez pour voir mes infos',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "r",
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Points Card (pas d'animation répétée)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Mes Points',
                                style: TextStyle(
                                  fontFamily: "r",
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: _getTierColor(_getCurrentTier(user.points)),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getCurrentTier(user.points),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: "b",
                                        fontWeight: FontWeight.bold,
                                        color: _getTierColor(_getCurrentTier(user.points)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.points.toString(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontFamily: "b",
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Niveau actuel : ${_getCurrentTier(user.points)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: "b",
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pointsToNextTier > 0
                                ? '$pointsToNextTier points pour le niveau suivant'
                                : 'Niveau maximum atteint',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "r",
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Progress bar
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: progressPercentage / 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${progressPercentage.round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actions rapides',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "b",
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.card_giftcard,
                            label: 'Récompenses',
                            color: const Color(0xFF3B82F6),
                            onTap: () {},
                          ),
                          _buildActionButton(
                            icon: Icons.history,
                            label: 'Historique',
                            color: const Color(0xFF8B5CF6),
                            onTap: () {},
                          ),
                          _buildActionButton(
                            icon: Icons.star,
                            label: 'Mes Bonus',
                            color: const Color(0xFFF59E0B),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Notifications
                if (_notifications.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "b",
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._notifications.map((notification) => _buildNotificationCard(notification)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],

                // Recent Activity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activité récente',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "b",
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
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
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '3 achats ce mois-ci',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: "b",
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Continuez pour gagner plus de points !',
                              style: TextStyle(
                                fontSize: 13,
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: "r",
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "b",
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: const TextStyle(
                    fontFamily: "r",
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: notification['type'] == 'offer'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// Retourne le nombre de points restant pour atteindre le prochain palier.
  int _getPointsToNextTier(int userPoints) {
    if (_user?.rewards != null && _user!.rewards is List) {
      final rewards = List<Map<String, dynamic>>.from(_user!.rewards as List)
        ..sort((a, b) => int.parse(a['value'].toString()).compareTo(int.parse(b['value'].toString())));
      for (final reward in rewards) {
        final tierValue = int.tryParse(reward['value'].toString()) ?? 0;
        if (tierValue > userPoints) {
          return tierValue - userPoints;
        }
      }
      // Si tous les paliers sont <= userPoints, il n'y a plus de niveau suivant
      return 0;
    }
    return 0;
  }

  /// Retourne dynamiquement le niveau actuel selon les points et rewards.
    String _getCurrentTier(int userPoints) {
    if (_user?.rewards != null && _user!.rewards is List) {
      final rewards = List<Map<String, dynamic>>.from(_user!.rewards as List)
        ..sort((a, b) => int.parse(a['value'].toString()).compareTo(int.parse(b['value'].toString())));
      if (rewards.isEmpty) {
        return _user?.tier ?? '';
      }
      String currentTier = rewards.first['type'] ?? '';
      for (final reward in rewards) {
        final tierValue = int.tryParse(reward['value'].toString()) ?? 0;
        if (userPoints >= tierValue) {
          currentTier = reward['type'] ?? '';
        } else {
          break;
        }
      }
      return currentTier;
    }
    return _user?.tier ?? '';
  }
  /// Retourne le pourcentage de progression vers le prochain palier.
  double _getProgressPercentage(int userPoints) {
    if (_user?.rewards != null && _user!.rewards is List) {
      final rewards = List<Map<String, dynamic>>.from(_user!.rewards as List)
        ..sort((a, b) => int.parse(a['value'].toString()).compareTo(int.parse(b['value'].toString())));
      int previous = 0;
      for (final reward in rewards) {
        final tierValue = int.tryParse(reward['value'].toString()) ?? 0;
        if (tierValue > userPoints) {
          final range = tierValue - previous;
          final progress = userPoints - previous;
          return range > 0 ? (progress / range * 100).clamp(0, 100) : 100;
        }
        previous = tierValue;
      }
      // Déjà au max
      return 100;
    }
    return 0;
  }

  /// Couleur dynamique selon le niveau (ordre dans rewards ou clé color)
  Color _getTierColor(String tier) {
    if (_user?.rewards != null && _user!.rewards is List) {
      final rewards = List<Map<String, dynamic>>.from(_user!.rewards as List);
      final reward = rewards.firstWhere(
        (r) => (r['type']?.toString().toLowerCase() ?? '') == tier.toLowerCase(),
        orElse: () => {},
      );
      if (reward['color'] != null) {
        final hex = reward['color'].toString().replaceAll('#', '');
        return Color(int.parse('0xFF$hex'));
      }
      // fallback palette selon l'ordre
      final List<Color> palette = [
        const Color.fromARGB(255, 255, 225, 195),
        const Color(0xFFC0C0C0),
        const Color(0xFFFFD700),
        const Color(0xFF3B82F6),
      ];
      final idx = rewards.indexWhere((r) =>
        (r['type']?.toString().toLowerCase() ?? '') == tier.toLowerCase()
      );
      if (idx != -1 && idx < palette.length) {
        return palette[idx];
      }
    }
    return const Color.fromARGB(255, 190, 201, 218);
  }
}