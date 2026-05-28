class Client {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String cases;
  final DateTime createdAt;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    this.address = '',
    this.cases = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
