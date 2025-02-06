// components/system_overview.dart
import 'package:flutter/material.dart';
import 'package:nofliesynck/disk_management/disk_management.dart';
import 'package:nofliesynck/memories/memories_info.dart';
import 'package:nofliesynck/monitoring/system_monitoring.dart';
import 'package:nofliesynck/network_reporting/network_reporting.dart';

class SystemOverviewSection extends StatelessWidget {
  const SystemOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "System Overview",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              SystemOverviewCard(
                title: "CPU Usage",
                value: "45%",
                icon: Icons.memory,
                color: Colors.blue,
                dialogBuilder: SystemMonitoring(),
              ),
              SystemOverviewCard(
                title: "Memory",
                value: "60%",
                icon: Icons.storage,
                color: Colors.green,
                dialogBuilder: MemoriesInfoDisplay(),
              ),
              SystemOverviewCard(
                title: "Disk Space",
                value: "75%",
                icon: Icons.disc_full,
                color: Colors.orange,
                dialogBuilder: DiskManagmentDisplay(),
              ),
              SystemOverviewCard(
                title: "Network",
                value: "32 Mb/s",
                icon: Icons.network_check,
                color: Colors.purple,
                dialogBuilder: NetworkReportingDisplay(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class SystemOverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Widget dialogBuilder;

  const SystemOverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.dialogBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => dialogBuilder,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues( alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 60,
                  height: 30,
                  child: CustomPaint(
                    painter: _MiniChartPainter(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.4, size.height * 0.9);
    path.lineTo(size.width * 0.6, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height * 0.8);
    path.lineTo(size.width, size.height * 0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
