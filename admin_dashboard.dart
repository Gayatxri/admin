import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/theme.dart';
import 'student_management.dart';
import 'bus_management.dart';
import 'rfid_mapping.dart';
import 'attendance_records.dart';
import 'route_management.dart';
import 'reports.dart';
import '../fourth.dart'; // Parent login

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int totalStudents = 0;
  int totalBuses = 0;
  int activeTrips = 0;
  int attendanceEvents = 0;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      // Get total students
      final studentsSnap = await FirebaseFirestore.instance
          .collection('students')
          .count()
          .get();
      
      // Get total buses
      final busesSnap = await FirebaseFirestore.instance
          .collection('buses')
          .count()
          .get();
      
      // Get attendance events
      final attendanceSnap = await FirebaseFirestore.instance
          .collection('attendance_events')
          .count()
          .get();

      if (mounted) {
        setState(() {
          totalStudents = studentsSnap.count ?? 0;
          totalBuses = busesSnap.count ?? 0;
          activeTrips = totalBuses; // You can customize this
          attendanceEvents = attendanceSnap.count ?? 0;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Text
              Text(
                'Welcome, Admin',
                style: AppTheme.headingStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'System Overview',
                style: AppTheme.bodyStyle,
              ),
              const SizedBox(height: 24),

              // Summary Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildSummaryCard(
                    title: 'Total Students',
                    value: totalStudents.toString(),
                    icon: Icons.person,
                    color: Colors.blue,
                  ),
                  _buildSummaryCard(
                    title: 'Total Buses',
                    value: totalBuses.toString(),
                    icon: Icons.directions_bus,
                    color: Colors.orange,
                  ),
                  _buildSummaryCard(
                    title: 'Active Trips',
                    value: activeTrips.toString(),
                    icon: Icons.navigation,
                    color: Colors.green,
                  ),
                  _buildSummaryCard(
                    title: 'Attendance Events',
                    value: attendanceEvents.toString(),
                    icon: Icons.event,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTheme.subHeadingStyle,
              ),
              const SizedBox(height: 16),

              // Action Buttons Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildActionButton(
                    context,
                    title: 'Manage Students',
                    icon: Icons.person_add,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentManagementScreen(),
                      ),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    title: 'Manage Buses',
                    icon: Icons.bus_alert,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BusManagementScreen(),
                      ),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    title: 'RFID Mapping',
                    icon: Icons.nfc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RfidMappingScreen(),
                      ),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    title: 'Attendance Records',
                    icon: Icons.checklist,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AttendanceRecordsScreen(),
                      ),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    title: 'Manage Routes',
                    icon: Icons.route,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RouteManagementScreen(),
                      ),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    title: 'View Reports',
                    icon: Icons.assessment,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: AppTheme.cardValueStyle.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.bodyStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.cardTitleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.admin_panel_settings,
                    size: 48, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Students'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_bus),
            title: const Text('Buses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BusManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.nfc),
            title: const Text('RFID Mapping'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RfidMappingScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Attendance'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AttendanceRecordsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.route),
            title: const Text('Routes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RouteManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
