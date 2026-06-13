class CareerModel {
  final String company;
  final String period;
  final String role;
  final List<String> bullets;

  const CareerModel({
    required this.company,
    required this.period,
    required this.role,
    required this.bullets,
  });

  factory CareerModel.fromMap(Map<String, dynamic> map) {
    return CareerModel(
      company: map['company'] as String,
      period: map['period'] as String,
      role: map['role'] as String,
      bullets: List<String>.from(map['bullets'] as List),
    );
  }
}
