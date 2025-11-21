import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton Pattern: Đảm bảo chỉ có 1 kết nối CSDL duy nhất trong toàn App
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Getter: Lấy CSDL, nếu chưa có thì khởi tạo
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Hàm khởi tạo CSDL
  Future<Database> _initDatabase() async {
    // 1. Lấy đường dẫn thư mục lưu CSDL trên điện thoại
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_campus.db');

    print("Database Path: $path"); // In ra để debug

    // 2. Mở kết nối (Tự động tạo file nếu chưa có)
    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure, // Cấu hình trước khi tạo bảng
      onCreate: _onCreate, // Chạy khi cài App lần đầu
    );
  }

  // Cấu hình: Bật tính năng Khóa ngoại (Foreign Key)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

// Tạo bảng: Đọc file SQL từ assets và chạy lệnh
  Future<void> _onCreate(Database db, int version) async {
    print("Creating Database Tables...");
    try {
      // Đọc file SQL thành chuỗi String
      String script =
          await rootBundle.loadString('assets/db/create_schema.sql');

      // --- SỬA ĐOẠN NÀY ---
      // Tách chuỗi dựa trên từ khóa '--SPLIT' mà chúng ta đã thêm vào file SQL
      List<String> statements = script.split('--SPLIT');
      // --------------------

      // Chạy từng lệnh một
      for (var statement in statements) {
        if (statement.trim().isNotEmpty) {
          // In ra câu lệnh đang chạy để debug nếu cần
          // print("Executing: ${statement.trim()}");
          await db.execute(statement.trim());
        }
      }
      print("Tables created successfully!");
    } catch (e) {
      print("Error creating tables: $e");
      rethrow;
    }
  }

  // Hàm phụ trợ: Xóa sạch dữ liệu (Dùng khi muốn reset app)
  Future<void> deleteDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_campus.db');
    await deleteDatabase(path);
    _database = null;
    print("Database deleted!");
  }
}
