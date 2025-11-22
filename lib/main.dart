import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus_navigator/data/repositories/guide_repository.dart';
import 'package:smart_campus_navigator/presentation/screens/home_screen.dart';

// Import các file cần thiết
import 'core/database/database_helper.dart';
import 'core/services/data_import_service.dart';
import 'data/repositories/service_repository.dart';
import 'logic/blocs/language_cubit.dart';
import 'logic/blocs/search_bloc.dart'; // Import mới
import 'logic/blocs/service_list_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();

  // --- INIT DATA ---
  await dbHelper.database;
  final importService = DataImportService(dbHelper);
  await importService.importDataIfNeeded();
  // -----------------

  final serviceRepo = ServiceRepository(dbHelper);
  final guideRepo =
      GuideRepository(dbHelper); // Khởi tạo GuideRepository cho ứng dụng.

  runApp(
    // Cung cấp Repository cho toàn App
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: serviceRepo),
        RepositoryProvider.value(
            value: guideRepo), // Cung cấp GuideRepository ở đây
      ],
      child: MultiBlocProvider(
        providers: [
          // Cung cấp LanguageCubit
          BlocProvider(create: (context) => LanguageCubit()),

          // Cung cấp ServiceListBloc (Cần repo để hoạt động)
          BlocProvider(
            create: (context) => ServiceListBloc(serviceRepo),
          ),

          // Cung cấp SearchBloc
          BlocProvider(create: (context) => SearchBloc(serviceRepo)),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder để lắng nghe thay đổi ngôn ngữ
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          title: 'Smart Campus Navigator',
          locale: locale, // Ngôn ngữ động
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          // Tạm thời để Placeholder, bước sau sẽ thay bằng HomeScreen thật
          home: const HomeScreen(),
        );
      },
    );
  }
}
