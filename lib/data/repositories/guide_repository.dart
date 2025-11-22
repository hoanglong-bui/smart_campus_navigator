import '../../core/database/database_helper.dart';
import '../models/guide_model.dart';

class GuideRepository {
  final DatabaseHelper _dbHelper;

  GuideRepository(this._dbHelper);

  // Lấy thông tin chi tiết của một Quy trình (kèm các bước)
  Future<GuideModel?> getGuideDetail(String guideId, String langCode) async {
    final db = await _dbHelper.database;

    // 1. Lấy thông tin Guide cha
    // Chọn cột tiêu đề/mô tả dựa trên ngôn ngữ hiện tại
    // Ví dụ: Nếu lang='vi', lấy title_vi AS title
    String titleCol = 'title_$langCode';
    String descCol = 'description_$langCode';

    // Fallback: Nếu ngôn ngữ không phải vi/hi thì dùng en
    if (!['en', 'vi', 'hi'].contains(langCode)) {
      titleCol = 'title_en';
      descCol = 'description_en';
    }

    final List<Map<String, dynamic>> guideMaps = await db.rawQuery('''
      SELECT guide_id, target_user, $titleCol as title, $descCol as description 
      FROM guides 
      WHERE guide_id = ?
    ''', [guideId]);

    if (guideMaps.isEmpty) return null;

    final guideMap = guideMaps.first;

    // 2. Lấy danh sách các Bước (Steps)
    final List<Map<String, dynamic>> stepMaps = await db.rawQuery('''
      SELECT step_id, step_order, linked_service_id, $titleCol as title, $descCol as description
      FROM guide_steps
      WHERE guide_id = ?
      ORDER BY step_order ASC
    ''', [guideId]);

    // 3. Map dữ liệu vào Model
    final steps = stepMaps
        .map((s) => GuideStep(
              stepId: s['step_id'],
              stepOrder: s['step_order'],
              title: s['title'],
              description: s['description'],
              linkedServiceId: s['linked_service_id'],
            ))
        .toList();

    return GuideModel(
      guideId: guideMap['guide_id'],
      targetUser: guideMap['target_user'],
      title: guideMap['title'],
      description: guideMap['description'],
      steps: steps,
    );
  }
}
