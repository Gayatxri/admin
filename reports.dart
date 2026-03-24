import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late FirebaseFirestore _firestore;
  int totalStudents = 0;
  int totalBuses = 0;
  int totalRoutes = 0;
  int totalAttendance = 0;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    try {
      final studentsSnap = await _firestore
          .collection('students')
          .count()
          .get();
      final busesSnap = await _firestore
          .collection('buses')
          .count()
          .get();
      final routesSnap = await _firestore
          .collection('routes')
          .count()
          .get();
      final attendanceSnap = await _firestore
          .collection('attendance_events')
          .count()
          .get();

      if (mounted) {
        setState(() {
          totalStudents = studentsSnap.count ?? 0;
          totalBuses = busesSnap.count ?? 0;
          totalRoutes = routesSnap.count ?? 0;
          totalAttendance = attendanceSnap.count ?? 0;
        });
      }
    } catch (e) {
      print('Error loading report data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text('Reports'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReportData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Summary',
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 24),

              // Summary Cards
              _buildReportCard(
                title: 'Total Students',
                value: totalStudents.toString(),
                icon: Icons.person,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),

              _buildReportCard(
                title: 'Total Buses',
                value: totalBuses.toString(),
                icon: Icons.directions_bus,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),

              _buildReportCard(
                title: 'Total Routes',
                value: totalRoutes.toString(),
                icon: Icons.route,
                color: Colors.green,
              ),
              const SizedBox(height: 12),

              _buildReportCard(
                title: 'Total Attendance Events',
                value: totalAttendance.toString(),
                icon: Icons.event,
                color: Colors.purple,
              ),
              const SizedBox(height: 32),

              // Detailed Reports Section
              Text(
                'Detailed Reports',
                style: AppTheme.subHeadingStyle,
              ),
              const SizedBox(height: 16),

              _buildDetailedReport(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.cardTitleStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppTheme.cardValueStyle.copyWith(color: color),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedReport() {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: const Text('Student Statistics'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Students Registered: $totalStudents',
                      style: AppTheme.bodyStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'RFID Mapped: Fetching...',
                      style: AppTheme.bodyStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Active Today: Calculating...',
                      style: AppTheme.bodyStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: const Text('Bus Statistics'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Buses: $totalBuses',
                      style: AppTheme.bodyStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Active Routes: $totalRoutes',
                      style: AppTheme.bodyStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Utilization: Calculating...',
                      style: AppTheme.bodyStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: const Text('Attendance Statistics'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Events: $totalAttendance',
                      style: AppTheme.bodyStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check-ins Today: Calculating...',
                      style: AppTheme.bodyStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check-outs Today: Calculating...',
                      style: AppTheme.bodyStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
