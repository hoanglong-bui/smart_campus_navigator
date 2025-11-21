import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import các file cần thiết
import 'core/database/database_helper.dart';
import 'core/services/data_import_service.dart';
import 'data/repositories/service_repository.dart';
import 'logic/blocs/language_cubit.dart';
import 'logic/blocs/service_list_bloc.dart';
// import 'presentation/screens/home_screen.dart'; // Sẽ tạo ở bước sau

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();

  // --- INIT DATA ---
  await dbHelper.database;
  final importService = DataImportService(dbHelper);
  await importService.importDataIfNeeded();
  // -----------------

  final serviceRepo = ServiceRepository(dbHelper);

  runApp(
    // Cung cấp Repository cho toàn App
    RepositoryProvider.value(
      value: serviceRepo,
      child: MultiBlocProvider(
        providers: [
          // Cung cấp LanguageCubit
          BlocProvider(create: (context) => LanguageCubit()),

          // Cung cấp ServiceListBloc (Cần repo để hoạt động)
          BlocProvider(
            create: (context) => ServiceListBloc(serviceRepo),
          ),
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
          home: const HomeScreenPlaceholder(),
        );
      },
    );
  }
}

// Widget tạm để test chạy App không bị lỗi
class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    // Test thử gọi sự kiện LoadServices
    // Lấy ngôn ngữ hiện tại từ Cubit
    final currentLang = context.read<LanguageCubit>().state.languageCode;

    // Ra lệnh cho Bloc tải dữ liệu
    context
        .read<ServiceListBloc>()
        .add(LoadServices(languageCode: currentLang));

    return Scaffold(
      appBar: AppBar(title: const Text("Ready for UI")),
      body: BlocBuilder<ServiceListBloc, ServiceListState>(
        builder: (context, state) {
          if (state is ServiceListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ServiceListLoaded) {
            return Center(
              child: Text("Loaded ${state.services.length} services from DB!"),
            );
          } else if (state is ServiceListError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("Waiting..."));
        },
      ),
    );
  }
}
