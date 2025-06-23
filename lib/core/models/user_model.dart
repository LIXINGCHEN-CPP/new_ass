class UserModel {
  final String? id;
  final String name;
  final String phone;
  final String? email;
  final String? gender;
  final String? birthday;
  final String? profileImage;
  final String? address;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  UserModel({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.gender,
    this.birthday,
    this.profileImage,
    this.address,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle different ID formats from MongoDB
    String? modelId;
    if (json['_id'] is Map) {
      modelId = json['_id']['\$oid'];
    } else {
      modelId = json['_id']?.toString() ?? json['id']?.toString();
    }

    return UserModel(
      id: modelId,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] as String?,
      profileImage: json['profileImage'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'birthday': birthday,
      'profileImage': profileImage,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? gender,
    String? birthday,
    String? profileImage,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper methods
  String get displayName => name.isEmpty ? phone : name;
  String get initials {
    if (name.isNotEmpty) {
      List<String> nameParts = name.split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else {
        return name.substring(0, 1).toUpperCase();
      }
    } else {
      return phone.substring(0, 1);
    }
  }
}
