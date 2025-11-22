import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/guide_model.dart';
import '../../data/repositories/guide_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../../logic/blocs/language_cubit.dart';
import 'service_detail_screen.dart';

class GuideTimelineScreen extends StatefulWidget {
  final String guideId; // Nhận vào ID (ví dụ 'intl_scholarship')

  const GuideTimelineScreen({super.key, required this.guideId});

  @override
  State<GuideTimelineScreen> createState() => _GuideTimelineScreenState();
}

class _GuideTimelineScreenState extends State<GuideTimelineScreen> {
  GuideModel? guide;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuide();
  }

  // Hàm load dữ liệu trực tiếp (Không cần tạo thêm Bloc cho đơn giản)
  Future<void> _loadGuide() async {
    final langCode = context.read<LanguageCubit>().state.languageCode;
    final repo = context.read<GuideRepository>();

    final result = await repo.getGuideDetail(widget.guideId, langCode);

    if (mounted) {
      setState(() {
        guide = result;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(isLoading ? "" : (guide?.targetUser ?? "Guide"),
            style: TextStyle(color: Colors.grey[800], fontSize: 16)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : guide == null
              ? const Center(child: Text("Guide not found"))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // HEADER
                    Text(
                      guide!.title,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      guide!.description ?? "",
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 32),

                    // TIMELINE LIST
                    ...guide!.steps
                        .map((step) => _buildStepItem(context, step)),
                  ],
                ),
    );
  }

  Widget _buildStepItem(BuildContext context, GuideStep step) {
    final isLast = step == guide!.steps.last;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột bên trái: Số thứ tự + Đường kẻ
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${step.stepOrder}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Cột bên phải: Nội dung
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 40), // Khoảng cách giữa các bước
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description ?? "",
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  // Nút liên kết Service (Nếu có)
                  if (step.linkedServiceId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _navigateToService(context, step.linkedServiceId!),
                        icon: const Icon(Icons.place, size: 18),
                        label: const Text("View Location"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                        ),
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Hàm xử lý khi bấm nút "View Location"
  Future<void> _navigateToService(BuildContext context, int serviceId) async {
    // 1. Lấy thông tin service từ ID
    final langCode = context.read<LanguageCubit>().state.languageCode;
    final serviceRepo = context.read<ServiceRepository>();

    // Note: Đây là cách lấy nhanh (hơi thủ công), đúng ra nên viết hàm getById trong Repo
    // Nhưng ta có thể tận dụng hàm search hoặc getServices
    final allServices = await serviceRepo.getServices(languageCode: langCode);

    try {
      final service = allServices.firstWhere((s) => s.serviceId == serviceId);

      // 2. Chuyển sang màn hình chi tiết
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(service: service)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Service not found (ID: $serviceId)")),
      );
    }
  }
}
