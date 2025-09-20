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
  List<Map<String, dynamic>> _notifications = [];
  late User _user;
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user; // Initialiser avec l'utilisateur passé en paramètre
    _fetchUser();
    // Rafraîchit toutes les 10 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
      final notifications = await fetchNotifications(user.id);
      setState(() {
        _user = user;
        _notifications = notifications;
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

  Future<List<Map<String, dynamic>>> fetchNotifications(String clientId) async {
    final response = await http.get(Uri.parse('$baseUrl/get_notifications.php?client_id=$clientId'));
    final data = jsonDecode(response.body);
    print('Notifications après suppression: $data'); // Ajoute ce print
    if (response.statusCode == 200 && data['success'] == true) {
      return List<Map<String, dynamic>>.from(data['notifications']);
    } else {
      return [];
    }
  }

  // Ajoute une notification côté serveur
  Future<void> addNotification({
    required String clientId,
    required String title,
    required String message,
    String type = 'info',
  }) async {
    await http.post(
      Uri.parse('$baseUrl/add_notification.php'),
      body: {
        'client_id': clientId,
        'title': title,
        'message': message,
        'type': type,
      },
    );
  }

  // Ajoute des points et gère la logique de reset + notification
  Future<void> addPoints(int points) async {
    final pointsToNextTier = _getPointsToNextTier(_user.points);
    if (pointsToNextTier <= 0) {
      // Niveau max atteint, reset points et notifie
      await resetUserPoints(_user.id);
      await addNotification(
        clientId: _user.id,
        title: "Cycle de points terminé",
        message: "Vous avez atteint le niveau maximum, vos points repartent à zéro.",
        type: "info",
      );
      setState(() {
        _user = _user.copyWith(points: 0);
      });
      await _fetchUser();
    } else {
      // Ajoute normalement les points (exemple d'appel API)
      await addPointsToUser(_user.id, points);
      await addNotification(
        clientId: _user.id,
        title: "Points ajoutés",
        message: "$points points ajoutés. Il vous reste $pointsToNextTier points pour le prochain niveau.",
        type: "info",
      );
      await _fetchUser();
    }
  }

  // Exemple d'appel API pour reset points
  Future<void> resetUserPoints(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset_points.php'),
      body: {'id': id},
    );
    final data = jsonDecode(response.body);
    if (data['success'] != true) {
      throw Exception('Erreur lors de la remise à zéro des points');
    }
  }

  // Exemple d'appel API pour ajouter des points
  Future<void> addPointsToUser(String id, int points) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_points.php'),
      body: {'id': id, 'points': points.toString()},
    );
    final data = jsonDecode(response.body);
    if (data['success'] != true) {
      throw Exception('Erreur lors de l\'ajout de points');
    }
  }

  bool _isMaxLevel(int userPoints) {
    if (_user.rewards != null && _user.rewards is List) {
      final rewards = List<Map<String, dynamic>>.from(_user.rewards as List)
        ..sort((a, b) => int.parse(a['value'].toString()).compareTo(int.parse(b['value'].toString())));
      if (rewards.isEmpty) return false;
      final maxValue = int.tryParse(rewards.last['value'].toString()) ?? 0;
      return userPoints >= maxValue;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }
    // if (_error != null) {
    //   return Scaffold(
    //     body: Center(child: Text('Erreur : $_error')),
    //   );
    // }
    final user = _user;

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

                                // Après le QrImageView et le Text "Scannez pour voir mes infos"
                if (user.storeName.isNotEmpty && user.customMessage != null && user.customMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.15)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              user.customMessage!,
                              style: const TextStyle(
                                fontFamily: "r",
                                fontSize: 14,
                                color: Color(0xFF1F2937),
                              ),
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

                // Notifications dynamiques
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
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Text(
                //         'Activité récente',
                //         style: TextStyle(
                //           fontSize: 16,
                //           fontFamily: "b",
                //           fontWeight: FontWeight.bold,
                //           color: Color(0xFF1F2937),
                //         ),
                //       ),
                //       const SizedBox(height: 16),
                //       Container(
                //         width: double.infinity,
                //         padding: const EdgeInsets.all(20),
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(12),
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.black.withOpacity(0.1),
                //               blurRadius: 8,
                //               offset: const Offset(0, 2),
                //             ),
                //           ],
                //         ),
                //         child: const Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               '3 achats ce mois-ci',
                //               style: TextStyle(
                //                 fontSize: 14,
                //                 fontFamily: "b",
                //                 fontWeight: FontWeight.w600,
                //                 color: Color(0xFF1F2937),
                //               ),
                //             ),
                //             SizedBox(height: 4),
                //             Text(
                //               'Continuez pour gagner plus de points !',
                //               style: TextStyle(
                //                 fontSize: 13,
                //                 fontFamily: "r",
                //                 color: Color(0xFF6B7280),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

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
    String dateStr = '';
    if (notification['created_at'] != null) {
      final date = DateTime.tryParse(notification['created_at']);
      if (date != null) {
        dateStr = '${date.day.toString().padLeft(2, '0')}/'
                  '${date.month.toString().padLeft(2, '0')}/'
                  '${date.year} '
                  '${date.hour.toString().padLeft(2, '0')}:'
                  '${date.minute.toString().padLeft(2, '0')}';
      }
    }
  
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
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: notification['type'] == 'offer'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Icône de suppression
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
            tooltip: "Supprimer",
                        onPressed: () async {
              print('Suppression notification id: ${notification['id']}');
              await _deleteNotification(notification['id'].toString());
              await _fetchUser();
                            setState(() {
                _notifications.removeWhere((n) => n['id'].toString() == notification['id'].toString());
              });
            },
          ),
        ],
      ),
    );
  }
  
    Future<void> _deleteNotification(String notificationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_notification.php'),
      body: {'id': notificationId}, // <-- PAS de headers ici
    );
    print('Delete response: ${response.body}');
  }

  /// Retourne le nombre de points restant pour atteindre le prochain palier.
  int _getPointsToNextTier(int userPoints) {
    if (_user.rewards != null && _user.rewards is List) {
      final rewards = List<Map<String, dynamic>>.from(_user.rewards as List)
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
    if (_user.rewards != null && _user.rewards is List) {
      final rewards = List<Map<String, dynamic>>.from(_user.rewards as List)
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
    if (_user.rewards != null && _user.rewards is List) {
      final rewards = List<Map<String, dynamic>>.from(_user.rewards as List)
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
    if (_user.rewards != null && _user.rewards is List) {
      final rewards = List<Map<String, dynamic>>.from(_user.rewards as List);
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