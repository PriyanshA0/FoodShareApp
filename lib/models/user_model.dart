// lib/models/user_model.dart

class User {
  final String id;
  final String email;
  final String role;
  final String status;

  final String? name;
  final String? contactNumber;
  final String? address;
  final String? verificationDetail;
  final int? volunteersCount;
  final String? contactPerson;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.name,
    this.contactNumber,
    this.address,
    this.verificationDetail,
    this.volunteersCount,
    this.contactPerson,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // The PHP backend is designed to return a flattened structure, so we look directly at the top level

    // Logic to handle different naming conventions from PHP backend
    final verificationDetail =
        json['license_proof'] ?? json['registration_certificate'];

    // Safely retrieve contact person/owner name
    final contactPerson = json['owner_name'] ?? json['contact_person'];

    return User(
      id: json['id']?.toString() ?? '0',
      email: json['email'] ?? 'N/A',
      role: json['role'] ?? 'N/A',
      status: json['status'] ?? 'N/A',
      name: json['name'],
      contactNumber: json['contact_number'],
      address: json['address'],
      verificationDetail: verificationDetail,
      volunteersCount: int.tryParse(json['volunteers_count']?.toString() ?? ''),
      contactPerson: contactPerson,
    );
  }
}
