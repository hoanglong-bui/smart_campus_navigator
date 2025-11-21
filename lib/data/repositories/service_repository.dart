import '../../core/database/database_helper.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final DatabaseHelper _dbHelper;

  ServiceRepository(this._dbHelper);

  // 1. Lấy danh sách Service theo Cluster và Category (Cho Home Screen)
  Future<List<ServiceModel>> getServices({
    required String languageCode,
    String? clusterId,
    String? category,
    bool openNow = false, // Todo: Xử lý logic Open Now sau
  }) async {
    final db = await _dbHelper.database;

    // Xây dựng câu query động
    String whereClause = "1=1"; // Mẹo: Luôn đúng, để dễ nối chuỗi AND
    List<dynamic> args = [];

    if (clusterId != null && clusterId != 'all') {
      whereClause += " AND s.cluster_id = ?";
      args.add(clusterId);
    }

    if (category != null) {
      whereClause += " AND s.category = ?";
      args.add(category);
    }

    // Câu lệnh JOIN thần thánh để lấy thông tin kèm bản dịch
    final String sql = '''
      SELECT 
        s.*, 
        t.name, t.description, t.address, t.hours_text, t.language_code
      FROM services s
      JOIN service_translations t ON s.service_id = t.service_id
      WHERE t.language_code = ? AND s.active = 1 AND $whereClause
    ''';

    // Thêm languageCode vào đầu danh sách args
    final List<dynamic> finalArgs = [languageCode, ...args];

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, finalArgs);

    return maps.map((e) => ServiceModel.fromSqlMap(e)).toList();
  }

  // 2. Tìm kiếm Full-Text (FTS5) - Cho Search Screen
  Future<List<ServiceModel>> searchServices({
    required String query,
    required String languageCode,
  }) async {
    final db = await _dbHelper.database;

    // FTS5 Query: Dùng bảng ảo service_translations_fts
    // Cú pháp MATCH: 'query*' để tìm kiếm prefix (ví dụ gõ "Lib" ra "Library")
    const String sql = '''
      SELECT 
        s.*, 
        t.name, t.description, t.address, t.hours_text, t.language_code
      FROM services s
      JOIN service_translations t ON s.service_id = t.service_id
      WHERE 
        t.language_code = ? 
        AND t.rowid IN (
          SELECT rowid FROM service_translations_fts 
          WHERE service_translations_fts MATCH ?
        )
    ''';

    // Xử lý chuỗi query cho FTS (thêm dấu * vào cuối mỗi từ)
    // Ví dụ: "cen lib" -> "cen* lib*"
    String ftsQuery = query.trim().split(' ').map((e) => '$e*').join(' ');

    final List<Map<String, dynamic>> maps =
        await db.rawQuery(sql, [languageCode, ftsQuery]);

    return maps.map((e) => ServiceModel.fromSqlMap(e)).toList();
  }
}
