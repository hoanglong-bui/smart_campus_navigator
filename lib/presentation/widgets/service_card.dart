import 'package:flutter/material.dart';
import 'package:smart_campus_navigator/data/models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Lấy bản dịch đầu tiên (vì query SQL đã lọc theo ngôn ngữ rồi)
    final translation = service.translations.first;

    // Logic đơn giản kiểm tra giờ mở cửa (để hiển thị màu)
    // Lưu ý: Đây chỉ là UI, logic chính xác cần xử lý kỹ hơn
    final bool isOpen = service.active;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 1. Icon (Bên trái)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForCategory(service.subCategory),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),

              // 2. Thông tin (Ở giữa)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translation.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            translation.address ?? "No address",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Trạng thái (Bên phải)
              Column(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: isOpen ? Colors.green : Colors.red,
                  ),
                  Text(
                    isOpen ? "Open" : "Closed",
                    style: TextStyle(
                      fontSize: 10,
                      color: isOpen ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Hàm phụ trợ chọn icon (Tạm thời hardcode, sau này lấy từ DB Categories)
  IconData _getIconForCategory(String subCat) {
    switch (subCat.toLowerCase()) {
      case 'library':
        return Icons.menu_book;
      case 'bank':
        return Icons.account_balance;
      case 'frro':
        return Icons.badge;
      case 'hostel':
        return Icons.bed;
      case 'iccr':
        return Icons.school;
      case 'fsr':
        return Icons.how_to_reg;
      default:
        return Icons.place;
    }
  }
}
