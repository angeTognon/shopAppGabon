import 'dart:convert';
import 'dart:async'; // <-- Ajoute ceci
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../const.dart';

class HistoryScreen extends StatefulWidget {
  final User user;

  const HistoryScreen({super.key, required this.user});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<NotificationClient> _notifications = [];
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer; // <-- Ajoute ceci

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchNotifications();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // <-- Ajoute ceci
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notifications = await fetchNotifications(widget.user.id);
      setState(() {
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

  Future<List<NotificationClient>> fetchNotifications(String clientId) async {
    final response = await http.get(Uri.parse('$baseUrl/get_notifications.php?client_id=$clientId'));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true && data['notifications'] != null) {
      return List<Map<String, dynamic>>.from(data['notifications'])
          .map((json) => NotificationClient.fromJson(json))
          .toList();
    } else {
      return [];
    }
  }
Future<void> _deleteNotification(int notificationId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_notification.php'),
      body: {'id': notificationId.toString()},
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      setState(() {
        _notifications.removeWhere((n) => n.id == notificationId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['error'] ?? 'Erreur lors de la suppression')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erreur réseau')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const Scaffold(
    //     backgroundColor: Color(0xFFF8FAFC),
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(child: Text('Erreur : $_error')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleTextStyle: TextStyle(
          fontFamily: "b",
          fontSize: 20,
          color: const Color(0xFF1F2937),
        ),
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text(
                "Aucune notification.",
                style: TextStyle(
                  fontFamily: "r",
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return _buildNotificationCard(notif);
              },
            ),
    );
  }

    Widget _buildNotificationCard(NotificationClient notif) {
    String dateStr = '';
    if (notif.createdAt.isNotEmpty) {
      final date = DateTime.tryParse(notif.createdAt);
      if (date != null) {
        dateStr = '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year} '
            '${date.hour.toString().padLeft(2, '0')}:'
            '${date.minute.toString().padLeft(2, '0')}';
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
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
                  notif.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "b",
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notif.message,
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
              color: notif.type == 'offer'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
            tooltip: "Supprimer",
            onPressed: () => _deleteNotification(notif.id),
          ),
        ],
      ),
    );
  }
}

// Modèle NotificationClient à placer dans models/notification_client.dart ou ici si besoin
class NotificationClient {
  final int id;
  final String title;
  final String message;
  final String type;
  final String createdAt;

  NotificationClient({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  factory NotificationClient.fromJson(Map<String, dynamic> json) {
    return NotificationClient(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}