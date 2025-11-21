import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/models/service_model.dart'; // Import model đã tạo ở Bước 2.2
import '../database/database_helper.dart';

class DataImportService {
  final DatabaseHelper _dbHelper;

  DataImportService(this._dbHelper);

  // Hàm chính: Kiểm tra và chạy nhập liệu nếu cần
  Future<void> importDataIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    // Kiểm tra xem đã nhập liệu phiên bản 1 chưa
    bool isImported = prefs.getBool('is_data_imported_v1') ?? false;

    if (isImported) {
      print("Data already imported. Skipping.");
      return;
    }

    print("--- STARTING DATA IMPORT ---");
    final db = await _dbHelper.database;

    // Sử dụng Transaction: Nếu 1 lệnh lỗi, toàn bộ sẽ bị hủy để tránh dữ liệu rác
    await db.transaction((txn) async {
      await _importClusters(txn);
      await _importCategories(txn);
      await _importServices(txn);
      await _importGuides(txn);
    });

    // Đánh dấu đã nhập xong để lần sau không chạy lại
    await prefs.setBool('is_data_imported_v1', true);
    print("--- DATA IMPORT FINISHED SUCCESSFULLY ---");
  }

  // 1. Nhập Clusters
  Future<void> _importClusters(Transaction txn) async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/data/clusters.json');
      List<dynamic> data = jsonDecode(jsonString);

      for (var item in data) {
        await txn.insert('clusters', item,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      print("Imported ${data.length} clusters.");
    } catch (e) {
      print("Error importing clusters: $e");
      rethrow;
    }
  }

  // 2. Nhập Categories
  Future<void> _importCategories(Transaction txn) async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/data/categories.json');
      List<dynamic> data = jsonDecode(jsonString);

      for (var item in data) {
        await txn.insert('categories', item,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      print("Imported ${data.length} categories.");
    } catch (e) {
      print("Error importing categories: $e");
      rethrow;
    }
  }

  // 3. Nhập Services & Translations (Quan trọng nhất)
  Future<void> _importServices(Transaction txn) async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/data/services_data.json');
      List<dynamic> data = jsonDecode(jsonString);

      for (var item in data) {
        // Dùng Model (Bước 2.2) để parse JSON
        ServiceModel service = ServiceModel.fromJson(item);

        // Insert vào bảng 'services'
        await txn.insert('services', service.toSqlMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        // Insert vào bảng 'service_translations' (Lặp qua list bản dịch)
        for (var translation in service.translations) {
          await txn.insert(
              'service_translations',
              translation
                  .toSqlMap(service.serviceId), // Truyền ID của service cha vào
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      print("Imported ${data.length} services (with translations).");
    } catch (e) {
      print("Error importing services: $e");
      rethrow;
    }
  }

  // 4. Nhập Guides & Steps (Quy trình)
  Future<void> _importGuides(Transaction txn) async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/data/guides.json');
      List<dynamic> data = jsonDecode(jsonString);

      for (var guideJson in data) {
        // Tách phần steps ra khỏi phần guide chính
        List<dynamic> steps = guideJson['steps'];

        // Tạo map cho bảng 'guides' (bỏ key 'steps' đi vì bảng guides không có cột steps)
        Map<String, dynamic> guideMap = Map.from(guideJson);
        guideMap.remove('steps');

        await txn.insert('guides', guideMap,
            conflictAlgorithm: ConflictAlgorithm.replace);

        // Insert các bước vào bảng 'guide_steps'
        for (var step in steps) {
          Map<String, dynamic> stepMap = Map.from(step);
          stepMap['guide_id'] = guideJson['guide_id']; // Gắn khóa ngoại

          await txn.insert('guide_steps', stepMap,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      print("Imported ${data.length} guides.");
    } catch (e) {
      print("Error importing guides: $e");
      rethrow;
    }
  }
}
