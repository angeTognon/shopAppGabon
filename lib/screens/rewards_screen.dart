import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../const.dart';

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

  List<String> _stores = ['Toutes'];
  List<String> _categories = ['Tous'];
  List<Reward> _rewards = [];
  bool _isLoading = true;
  String? _error;

  int _clientPoints = 0;
  String _clientTier = '';
  List<Map<String, dynamic>> _tiers = [];
  Timer? _refreshTimer;

  // ...tes variables et méthodes...
   @override
  void initState() {
    super.initState();
    _fetchTiers();
    _fetchRewards();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchTiers();
      _fetchRewards();
    });
  }

@override
void dispose() {
  _refreshTimer?.cancel();
  super.dispose();
}
  Future<void> _fetchTiers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_client_tiers.php?client_id=${widget.user.id}'));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final client = data['client'];
        final tiers = List<Map<String, dynamic>>.from(data['tiers'] ?? []);
        setState(() {
          _clientPoints = int.tryParse(client['points'].toString()) ?? 0;
          _clientTier = client['tier'] ?? '';
          _tiers = tiers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['error'] ?? 'Erreur inconnue';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('ERROR: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRewards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final rewards = await fetchRewards();
      final stores = ['Toutes', ...{...rewards.map((r) => r.store)}];
      final categories = ['Tous', ...{...rewards.map((r) => r.category)}];
      setState(() {
        _rewards = rewards;
        _stores = stores;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<Reward>> fetchRewards() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rewarded_status_client.php?client_id=${widget.user.id}'),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true && data['rewards'] != null) {
      return List<Map<String, dynamic>>.from(data['rewards'])
          .map((json) => Reward.fromJson(json))
          .toList();
    } else {
      return [];
    }
  }
  Future<void> _updateRewardStatus(Reward reward, String status) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_reward_status.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': widget.user.id,
        'merchant_id': reward.store, // ou adapte selon ta logique
        'reward_label': reward.title,
          'statut_by_client': status, // ou la valeur voulue

      }),
    );
    if (response.statusCode == 200) {
      _fetchRewards();
    }

  }

Future<void> _updateRewardStatusByClient(Reward reward, String statutByClient) async {
  final body = {
    'client_id': widget.user.id,
    'merchant_id': reward.merchantId,
    'reward_label': reward.title,
    'status': reward.rewardStatus,
    'statut_by_client': statutByClient,
  };
  print('POST update_reward_status.php: $body');
  final response = await http.post(
    Uri.parse('$baseUrl/update_reward_status.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );
  print('RESPONSE: ${response.body}');
  if (response.statusCode == 200) {
    _fetchRewards();
  }
}

  @override
  Widget build(BuildContext context) {
    final filteredRewards = _rewards.where((reward) {
      final matchesSearch = reward.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          reward.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Tous' || reward.category == _selectedCategory;
      final matchesStore = _selectedStore == 'Toutes' || reward.store == _selectedStore;
      return matchesSearch && matchesCategory && matchesStore;
    }).toList();

    // if (_isLoading) {
    //   return const Scaffold(
    //     backgroundColor: Color(0xFFF8FAFC),
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }
    // if (_error != null) {
    //   return Scaffold(
    //     backgroundColor: const Color(0xFFF8FAFC),
    //     body: Center(child: Text('Erreur : $_error')),
    //   );
    // }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
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
                    onPressed: () {
                      _fetchTiers();
                      _fetchRewards();
                    },
                    icon: const Icon(Icons.refresh, color: Color(0xFF3B82F6)),
                  ),
                ],
              ),
            ),
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
            // Palier/tier du client
            const SizedBox(height: 15),
            if (_tiers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Text(
                        'Statut de vos paliers de récompenses',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: "b",
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 14),
                    ..._tiers.map((tier) {
                       final int value = int.tryParse(tier['value'].toString()) ?? 0;
  final bool reached = _clientPoints >= value;
  final int maxReachedIndex = _tiers.lastIndexWhere((t) =>
    _clientPoints >= (int.tryParse(t['value'].toString()) ?? 0)
  );
  final bool isCurrent = _tiers.indexOf(tier) == maxReachedIndex && maxReachedIndex != -1;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: reached ? const Color(0xFF10B981).withOpacity(0.12) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF3B82F6)
                                : reached
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFE5E7EB),
                            width: isCurrent ? 2.2 : 1.3,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: reached
                                ? const Color(0xFF10B981)
                                : const Color(0xFFE5E7EB),
                            child: Icon(
                              reached ? Icons.emoji_events : Icons.lock_outline,
                              color: reached ? Colors.white : const Color(0xFF9CA3AF),
                            ),
                          ),
                          title: Text(
                            tier['type'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "b",
                              color: isCurrent
                                  ? const Color(0xFF3B82F6)
                                  : reached
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF6B7280),
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              if ((tier['reward'] ?? '').toString().isNotEmpty)
                                Flexible(
                                  child: Text(
                                    tier['reward'],
                                    style: const TextStyle(
                                      fontFamily: "r",
                                      color: Color(0xFF6B7280),
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if ((tier['reward'] ?? '').toString().isNotEmpty)
                                const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${tier['value']} pts',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: "b",
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: isCurrent
                              ? const Icon(Icons.check_circle, color: Color(0xFF3B82F6), size: 28)
                              : null,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                          'Vos récompenses',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: "b",
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
            ),
            // (Filtres boutiques et catégories désactivés ici)
            const SizedBox(height: 20),
            // Rewards list
            Expanded(
              child: filteredRewards.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucune récompense atteinte pour l'instant.",
                        style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredRewards.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final reward = filteredRewards[index];
                        final status = reward.rewardStatus;
                        final color = status == 'octroyee'
                            ? Colors.green
                            : status == 'en_attente'
                                ? Colors.orange
                                : Colors.red;

                                                return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Color(0xFF10B981).withOpacity(0.2),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Color(0xFF10B981),
                                    child: Icon(
                                      Icons.card_giftcard,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reward.store,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "b",
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Récompense : ${reward.title}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontFamily: "r",
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          status == 'octroyee'
                                              ? "Récompense encaissée"
                                              : status == 'en_attente'
                                                  ? "En attente d'encaissement"
                                                  : "En attente d'encaissement",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: color,
                                            fontFamily: "r",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
    SizedBox(
      width: double.infinity,
      child: reward.statutByClient != 'confirmé'
          ? ElevatedButton.icon(
              icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
              label: const Text(
                "Je confirme avoir encaissé",
                style: TextStyle(
                  fontFamily: "b",
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _updateRewardStatusByClient(reward, 'confirmé'),
            )
          : ElevatedButton.icon(
              icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
              label: const Text(
                "Déjà confirmé",
                style: TextStyle(
                  fontFamily: "b",
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: null,
            ),)
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}