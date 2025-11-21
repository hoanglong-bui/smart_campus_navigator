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

  // MỚI: Factory để đọc dữ liệu phẳng từ câu lệnh SQL SELECT JOIN
  factory ServiceModel.fromSqlMap(Map<String, dynamic> map) {
    return ServiceModel(
      serviceId: map['service_id'],
      clusterId: map['cluster_id'],
      category: map['category'],
      subCategory: map['sub_category'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      phone: map['phone'],
      email: map['email'],
      website: map['website'],
      // Parse lại chuỗi JSON giờ làm việc
      hoursJson:
          map['hours_json'] != null ? _parseHours(map['hours_json']) : null,
      active: map['active'] == 1,
      verified: map['verified'] == 1,
      // Tạo list translation chứa đúng 1 ngôn ngữ hiện tại
      translations: [
        ServiceTranslation(
          languageCode: map['language_code'],
          name: map['name'],
          description: map['description'],
          address: map['address'],
          hoursText: map['hours_text'],
        )
      ],
    );
  }

  // Helper nhỏ để parse chuỗi "{Mon: ...}" thành Map
  static Map<String, String> _parseHours(String str) {
    // Cắt bỏ dấu { và } rồi tách chuỗi đơn giản (Regex cơ bản)
    // Lưu ý: Đây là parse đơn giản, nếu chuỗi phức tạp nên dùng jsonDecode
    String content = str.replaceAll('{', '').replaceAll('}', '');
    Map<String, String> result = {};
    List<String> pairs = content.split(',');
    for (var pair in pairs) {
      List<String> kv = pair.split(':');
      if (kv.length == 2) {
        result[kv[0].trim()] = kv[1].trim();
      }
    }
    return result;
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
