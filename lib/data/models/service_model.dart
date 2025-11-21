class ServiceModel {
  final int serviceId;
  final String clusterId;
  final String category;
  final String subCategory;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? email;
  final String? website;
  final Map<String, String>? hoursJson; // Lưu raw JSON
  final List<ServiceTranslation> translations;

  // Metadata
  final bool active;
  final bool verified;

  ServiceModel({
    required this.serviceId,
    required this.clusterId,
    required this.category,
    required this.subCategory,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.email,
    this.website,
    this.hoursJson,
    required this.translations,
    this.active = true,
    this.verified = false,
  });

  // Factory: Tạo Object từ JSON (Đọc file assets)
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    var list = json['translations'] as List;
    List<ServiceTranslation> translationList =
        list.map((i) => ServiceTranslation.fromJson(i)).toList();

    return ServiceModel(
      serviceId: json['service_id'],
      clusterId: json['cluster_id'],
      category: json['category'],
      subCategory: json['sub_category'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      hoursJson: json['hours_json'] != null
          ? Map<String, String>.from(json['hours_json'])
          : null,
      translations: translationList,
      active: json['active'] ?? true,
      verified: json['verified'] ?? false,
    );
  }

  // Method: Chuyển Object thành Map để Insert vào SQLite (Bảng 'services')
  Map<String, dynamic> toSqlMap() {
    return {
      'service_id': serviceId,
      'cluster_id': clusterId,
      'category': category,
      'sub_category': subCategory,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      // SQLite không lưu Map, phải chuyển thành String
      'hours_json': hoursJson.toString(),
      'active': active ? 1 : 0,
      'verified': verified ? 1 : 0,
    };
  }
}

class ServiceTranslation {
  final String languageCode;
  final String name;
  final String? description;
  final String? address;
  final String? hoursText;

  ServiceTranslation({
    required this.languageCode,
    required this.name,
    this.description,
    this.address,
    this.hoursText,
  });

  factory ServiceTranslation.fromJson(Map<String, dynamic> json) {
    return ServiceTranslation(
      languageCode: json['language_code'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      hoursText: json['hours_text'],
    );
  }

  // Chuyển thành Map để Insert vào SQLite (Bảng 'service_translations')
  Map<String, dynamic> toSqlMap(int serviceId) {
    return {
      'service_id': serviceId,
      'language_code': languageCode,
      'name': name,
      'description': description,
      'address': address,
      'hours_text': hoursText,
    };
  }
}
