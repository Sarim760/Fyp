class Doctor_model {
  final String id;
  final String name;
  final String specialization;
  final int experience;
  final List<dynamic> ratings;
  final String chatId;
  final DateTime createdAt;

  Doctor_model({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.ratings,
    required this.chatId,
    required this.createdAt,
  });

  factory Doctor_model.fromJson(Map<String, dynamic> json) => Doctor_model(
        id: json['_id'] ?? json['id'],
        name: json['name'],
        specialization: json['specialization'],
        experience: json['experience'],
        ratings: List<dynamic>.from(json['ratings'] ?? []),
        chatId: json['chatId'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
