import 'dart:convert';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final int points;
  final String tier;
  final String memberSince;
  final String storeName;
  final List<dynamic>? rewards;
  final Map<String, dynamic>? tierColors;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.points,
    required this.tier,
    required this.memberSince,
    required this.storeName,
    this.rewards,
    this.tierColors,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      phone: json['phone'],
      points: int.tryParse(json['points'].toString()) ?? 0,
      tier: json['tier'] ?? '',
      memberSince: json['memberSince'] ?? json['member_since']?.toString() ?? '',
      storeName: json['storeName'] ?? json['store_name'] ?? '',
      rewards: json['rewards'] is String
          ? (json['rewards']?.isNotEmpty == true ? List<dynamic>.from(jsonDecode(json['rewards'])) : null)
          : json['rewards'],
      tierColors: json['tier_colors'] is String
          ? (json['tier_colors']?.isNotEmpty == true ? Map<String, dynamic>.from(jsonDecode(json['tier_colors'])) : null)
          : json['tier_colors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'points': points,
      'tier': tier,
      'memberSince': memberSince,
      'storeName': storeName,
      'rewards': rewards,
      'tier_colors': tierColors,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    int? points,
    String? tier,
    String? memberSince,
    String? storeName,
    List<dynamic>? rewards,
    Map<String, dynamic>? tierColors,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      points: points ?? this.points,
      tier: tier ?? this.tier,
      memberSince: memberSince ?? this.memberSince,
      storeName: storeName ?? this.storeName,
      rewards: rewards ?? this.rewards,
      tierColors: tierColors ?? this.tierColors,
    );
  }
}


class Purchase {
  final int id;
  final String date;
  final double amount;
  final int points;
  final String store;
  final List<String> items;
  final String status;

  Purchase({
    required this.id,
    required this.date,
    required this.amount,
    required this.points,
    required this.store,
    required this.items,
    required this.status,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      date: json['date'] ?? '',
      amount: (json['amount'] is double)
          ? json['amount']
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      points: int.tryParse(json['points'].toString()) ?? 0,
      store: json['store'] ?? '',
      items: (json['items'] is List)
          ? List<String>.from(json['items'])
          : [],
      status: json['status'] ?? '',
    );
  }
}

class Reward {
  final int id;
  final String title;
  final String description;
  final int points;
  final String category;
  final bool available;
  final String iconName;
  final String color;
  final String store;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.category,
    required this.available,
    required this.iconName,
    required this.color,
    required this.store,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      points: int.tryParse(json['points'].toString()) ?? 0,
      category: json['category'] ?? '',
      available: json['available'] ?? false,
      iconName: json['iconName'] ?? 'card_giftcard',
      color: json['color'] ?? '0xFF3B82F6',
      store: json['store'] ?? '',
    );
  }
}

class Bonus {
  final int id;
  final String title;
  final String description;
  final int points;
  final String dateEarned;
  final String type;
  final String iconName;
  final String color;

  Bonus({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.dateEarned,
    required this.type,
    required this.iconName,
    required this.color,
  });

  factory Bonus.fromJson(Map<String, dynamic> json) {
    return Bonus(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      points: int.tryParse(json['points'].toString()) ?? 0,
      dateEarned: json['dateEarned'] ?? '',
      type: json['type'] ?? '',
      iconName: json['iconName'] ?? 'star',
      color: json['color'] ?? '0xFF3B82F6',
    );
  }
}