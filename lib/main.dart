import 'package:flutter/material.dart';
import 'package:smart_campus_navigator/core/database/database_helper.dart';

void main() async {
  // Đảm bảo Flutter binding đã sẵn sàng trước khi gọi code bất đồng bộ
  WidgetsFlutterBinding.ensureInitialized();

  // --- TEST CSDL ---
  print("--- STARTING APP ---");
  final dbHelper = DatabaseHelper();

  // Thử xóa DB cũ (để test tạo mới từ đầu, sau này sẽ bỏ dòng này)
  await dbHelper.deleteDb();

  // Gọi database để kích hoạt hàm _onCreate
  await dbHelper.database;
  print("--- DATABASE INITIALIZED ---");
  // -----------------

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Campus Navigator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Smart Campus Navigator - Ready to Code!'),
        ),
      ),
    );
  }
}
