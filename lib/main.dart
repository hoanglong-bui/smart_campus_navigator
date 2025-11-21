import 'package:flutter/material.dart';

import 'core/database/database_helper.dart';
import 'core/services/data_import_service.dart'; // Import Service mới

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("--- STARTING APP ---");
  final dbHelper = DatabaseHelper();

  // LƯU Ý: Dòng deleteDb này chỉ dùng để Test.
  // Nó sẽ xóa DB cũ đi để chúng ta test chức năng Import lại từ đầu.
  // Sau khi test xong, hãy comment dòng này lại.
  await dbHelper.deleteDb();

  // 1. Khởi tạo DB
  await dbHelper.database;

  // 2. Chạy Import Dữ liệu
  final importService = DataImportService(dbHelper);
  await importService.importDataIfNeeded();

  // 3. KIỂM TRA KẾT QUẢ (QUAN TRỌNG)
  // Thử query lấy dữ liệu ra xem có chưa
  final db = await dbHelper.database;
  final count =
      await db.rawQuery('SELECT count(*) as count FROM service_translations');
  print(">>> TEST QUERY: Total translations found: ${count.first['count']}");

  // Thử in ra tên của dịch vụ đầu tiên (Tiếng Việt)
  final result = await db.rawQuery(
      "SELECT name FROM service_translations WHERE language_code = 'vi' LIMIT 1");
  if (result.isNotEmpty) {
    print(">>> TEST DATA: First VI name found: ${result.first['name']}");
  }

  print("--- INITIALIZATION COMPLETE ---");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Campus Navigator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Data Import Success! Check Console.'),
        ),
      ),
    );
  }
}
