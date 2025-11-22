import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/service_model.dart';
import '../../logic/blocs/language_cubit.dart';
import '../../logic/blocs/search_bloc.dart';
import 'service_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = context.read<LanguageCubit>().state.languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. SEARCH BAR AREA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Ô nhập liệu
                  TextField(
                    autofocus: true, // Tự động bật bàn phím
                    onChanged: (query) {
                      // Gửi sự kiện tìm kiếm vào Bloc
                      context.read<SearchBloc>().add(SearchQueryChanged(
                          query: query, languageCode: langCode));
                    },
                    decoration: InputDecoration(
                      hintText: "Search service, places...",
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      suffixIcon: const Icon(Icons.close,
                          color: Colors.grey), // Nút xóa (Mock)
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Bar (Giao diện tĩnh, chưa có logic lọc)
                  const Row(
                    children: [
                      _FilterChip(
                          label: "All Clusters",
                          icon: Icons.keyboard_arrow_down),
                      SizedBox(width: 8),
                      _FilterChip(label: "Open Now", isActive: true),
                    ],
                  )
                ],
              ),
            ),

            // 2. RESULT LIST
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SearchLoaded) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final service = state.results[index];
                        return _SearchResultItem(
                          service: service,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ServiceDetailScreen(service: service),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else if (state is SearchEmpty) {
                    return _buildEmptyState();
                  } else if (state is SearchError) {
                    return Center(child: Text(state.message));
                  }
                  // Trạng thái ban đầu (Chưa gõ gì)
                  return _buildInitialState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("No results found", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.topCenter,
      child: const Text(
        "SUGGESTIONS\n\nTry searching for 'Library', 'Bank'...",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

// Widget con: Mục kết quả tìm kiếm (Gọn hơn ServiceCard)
class _SearchResultItem extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const _SearchResultItem({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final translation = service.translations.first;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.history, color: Colors.grey), // Icon đồng hồ
      ),
      title: Text(
        translation.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(service.clusterId.replaceAll('_', ' ').toUpperCase()),
      onTap: onTap,
    );
  }
}

// Widget con: Chip bộ lọc
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;

  const _FilterChip({required this.label, this.icon, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.white,
        border:
            Border.all(color: isActive ? Colors.green : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (isActive) ...[
            const Icon(Icons.circle, size: 8, color: Colors.green),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.black87 : Colors.grey[700],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: Colors.grey[600]),
          ],
        ],
      ),
    );
  }
}
