import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/theme.dart';

class BusManagementScreen extends StatefulWidget {
  const BusManagementScreen({super.key});

  @override
  State<BusManagementScreen> createState() => _BusManagementScreenState();
}

class _BusManagementScreenState extends State<BusManagementScreen> {
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text('Manage Buses'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () => _showAddBusDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('buses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No buses found',
                style: AppTheme.bodyStyle,
              ),
            );
          }

          final buses = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              final data = bus.data() as Map<String, dynamic>;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.directions_bus),
                  title: Text(
                    data['vehicleNumber'] ?? 'N/A',
                    style: AppTheme.cardTitleStyle,
                  ),
                  subtitle: Text(
                      'Driver: ${data['driverName'] ?? 'N/A'} | Route: ${data['route'] ?? 'N/A'}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () =>
                            _showEditBusDialog(context, bus.id, data),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                        onTap: () => _deleteBus(bus.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddBusDialog(BuildContext context) {
    final vehicleCtrl = TextEditingController();
    final driverCtrl = TextEditingController();
    final routeCtrl = TextEditingController();
    final statusCtrl = TextEditingController(text: 'Active');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bus'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vehicleCtrl,
                decoration:
                    const InputDecoration(labelText: 'Vehicle Number'),
              ),
              TextField(
                controller: driverCtrl,
                decoration: const InputDecoration(labelText: 'Driver Name'),
              ),
              TextField(
                controller: routeCtrl,
                decoration: const InputDecoration(labelText: 'Route'),
              ),
              TextField(
                controller: statusCtrl,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: AppTheme.smallButtonStyle(),
            onPressed: () {
              _firestore.collection('buses').add({
                'vehicleNumber': vehicleCtrl.text.trim(),
                'driverName': driverCtrl.text.trim(),
                'route': routeCtrl.text.trim(),
                'status': statusCtrl.text.trim(),
                'createdAt': DateTime.now(),
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditBusDialog(
    BuildContext context,
    String busId,
    Map<String, dynamic> data,
  ) {
    final vehicleCtrl =
        TextEditingController(text: data['vehicleNumber']);
    final driverCtrl =
        TextEditingController(text: data['driverName']);
    final routeCtrl = TextEditingController(text: data['route']);
    final statusCtrl = TextEditingController(text: data['status']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bus'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vehicleCtrl,
                decoration:
                    const InputDecoration(labelText: 'Vehicle Number'),
              ),
              TextField(
                controller: driverCtrl,
                decoration: const InputDecoration(labelText: 'Driver Name'),
              ),
              TextField(
                controller: routeCtrl,
                decoration: const InputDecoration(labelText: 'Route'),
              ),
              TextField(
                controller: statusCtrl,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: AppTheme.smallButtonStyle(),
            onPressed: () {
              _firestore.collection('buses').doc(busId).update({
                'vehicleNumber': vehicleCtrl.text.trim(),
                'driverName': driverCtrl.text.trim(),
                'route': routeCtrl.text.trim(),
                'status': statusCtrl.text.trim(),
                'updatedAt': DateTime.now(),
              });
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteBus(String busId) {
    _firestore.collection('buses').doc(busId).delete();
  }
}
