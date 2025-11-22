import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus_navigator/presentation/screens/guide_timeline_screen.dart';
import 'package:smart_campus_navigator/presentation/screens/search_screen.dart';
import 'package:smart_campus_navigator/presentation/screens/service_detail_screen.dart';

import '../../logic/blocs/language_cubit.dart';
import '../../logic/blocs/service_list_bloc.dart';
import '../widgets/service_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi load dữ liệu ngay khi màn hình mở
    _loadData();
  }

  void _loadData() {
    final langCode = context.read<LanguageCubit>().state.languageCode;
    context.read<ServiceListBloc>().add(LoadServices(languageCode: langCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền nhẹ
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER: SEARCH & SETTINGS ---
            _buildHeader(context),

            // --- BODY: GUIDES & LIST ---
            Expanded(
              child: BlocBuilder<ServiceListBloc, ServiceListState>(
                builder: (context, state) {
                  if (state is ServiceListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ServiceListError) {
                    return Center(child: Text(state.message));
                  } else if (state is ServiceListLoaded) {
                    // Dùng CustomScrollView để cuộn cả trang mượt mà
                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // 1. Khu vực Guides (Không bị ẩn khi lọc)
                        const SliverToBoxAdapter(child: _GuidesSection()),

                        // 2. Tiêu đề danh sách
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "NEARBY SERVICES",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                      fontSize: 13),
                                ),
                                // Filter Chips giả (Trang trí)
                                const Row(
                                  children: [
                                    Icon(Icons.filter_list,
                                        size: 16, color: Colors.grey),
                                    Text(" Filter",
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),

                        // 3. Danh sách Dịch vụ
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final service = state.services[index];
                                return ServiceCard(
                                  service: service,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ServiceDetailScreen(
                                                service: service),
                                      ),
                                    );
                                  },
                                );
                              },
                              childCount: state.services.length,
                            ),
                          ),
                        ),

                        // Khoảng trống dưới cùng
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Header
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Thanh tìm kiếm giả
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Chuyển sang màn hình Search
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("Search services, places...",
                        style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nút Cài đặt
          Container(
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                // TODO: Navigate to Settings
                print("Open Settings");
              },
            ),
          )
        ],
      ),
    );
  }
}

// Widget con: Khu vực Guides
class _GuidesSection extends StatelessWidget {
  const _GuidesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "YOUR GUIDES",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildGuideCard(
                  context,
                  "ICCR Scholar",
                  "4 Steps",
                  Icons.school,
                  Colors.purple.shade50,
                  "intl_scholarship" // ID khớp với guides.json
                  ),
              const SizedBox(width: 12),
              _buildGuideCard(
                  context,
                  "Self-Financed",
                  "3 Steps",
                  Icons.person,
                  Colors.blue.shade50,
                  "intl_self_financed" // ID khớp với guides.json
                  ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGuideCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, String guideId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // Truyền ID tương ứng trong DB (intl_scholarship hoặc intl_self_financed)
            builder: (context) => GuideTimelineScreen(guideId: guideId),
          ),
        );
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle,
                style: TextStyle(color: Colors.grey[700], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
