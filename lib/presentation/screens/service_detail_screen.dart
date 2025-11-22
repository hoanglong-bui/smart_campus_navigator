import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Để gọi điện/mở web

import '../../data/models/service_model.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final translation = service.translations.first;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER
            Text(
              translation.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${service.category} • ${service.subCategory}",
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // 2. ACTION BUTTONS (Call, Directions, Website)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: Icons.call,
                  label: "Call",
                  onTap: () => _makePhoneCall(service.phone),
                  color: Colors.blue.shade50,
                  iconColor: Colors.blue,
                ),
                _ActionButton(
                  icon: Icons.directions,
                  label: "Directions",
                  onTap: () {
                    // TODO: Mở bản đồ (Sẽ làm ở Phase 4)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Opening Map... (Coming soon)")),
                    );
                  },
                  color: Colors.deepPurple.shade50,
                  iconColor: Colors.deepPurple,
                ),
                _ActionButton(
                  icon: Icons.language,
                  label: "Website",
                  onTap: () => _launchWebsite(service.website),
                  color: Colors.orange.shade50,
                  iconColor: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // 3. INFO BLOCKS
            _InfoBlock(
              title: "ADDRESS",
              content: translation.address ?? "N/A",
              icon: Icons.location_on_outlined,
            ),
            _InfoBlock(
              title: "HOURS",
              content: translation.hoursText ?? "See description",
              icon: Icons.access_time,
            ),
            _InfoBlock(
              title: "DESCRIPTION",
              content: translation.description ?? "No description available.",
              icon: Icons.info_outline,
            ),

            const SizedBox(height: 24),

            // 4. MAP PREVIEW (Placeholder cho Phase 4)
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Map Preview Loading...",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper: Gọi điện
  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  // Helper: Mở Web
  Future<void> _launchWebsite(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

// Widget con: Nút tròn
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700]),
          )
        ],
      ),
    );
  }
}

// Widget con: Khối thông tin
class _InfoBlock extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _InfoBlock(
      {required this.title, required this.content, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                      fontSize: 15, height: 1.4, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
