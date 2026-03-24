import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/theme.dart';

class RouteManagementScreen extends StatefulWidget {
  const RouteManagementScreen({super.key});

  @override
  State<RouteManagementScreen> createState() =>
      _RouteManagementScreenState();
}

class _RouteManagementScreenState extends State<RouteManagementScreen> {
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
        title: const Text('Manage Routes'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () => _showAddRouteDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('routes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No routes found',
                style: AppTheme.bodyStyle,
              ),
            );
          }

          final routes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              final data = route.data() as Map<String, dynamic>;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.route),
                  title: Text(
                    data['name'] ?? 'N/A',
                    style: AppTheme.cardTitleStyle,
                  ),
                  subtitle: Text(
                      'Stops: ${data['stops'] ?? '0'} | Distance: ${data['distance'] ?? 'N/A'} km'),
                  trailing: PopupMenuButton(
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () =>
                            _showEditRouteDialog(context, route.id, data),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                        onTap: () => _deleteRoute(route.id),
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

  void _showAddRouteDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final stopsCtrl = TextEditingController();
    final distanceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Route'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Route Name'),
              ),
              TextField(
                controller: stopsCtrl,
                decoration: const InputDecoration(labelText: 'Number of Stops'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: distanceCtrl,
                decoration:
                    const InputDecoration(labelText: 'Distance (km)'),
                keyboardType: TextInputType.number,
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
              _firestore.collection('routes').add({
                'name': nameCtrl.text.trim(),
                'stops': int.tryParse(stopsCtrl.text) ?? 0,
                'distance': distanceCtrl.text.trim(),
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

  void _showEditRouteDialog(
    BuildContext context,
    String routeId,
    Map<String, dynamic> data,
  ) {
    final nameCtrl = TextEditingController(text: data['name']);
    final stopsCtrl =
        TextEditingController(text: data['stops'].toString());
    final distanceCtrl =
        TextEditingController(text: data['distance']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Route'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Route Name'),
              ),
              TextField(
                controller: stopsCtrl,
                decoration: const InputDecoration(labelText: 'Number of Stops'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: distanceCtrl,
                decoration:
                    const InputDecoration(labelText: 'Distance (km)'),
                keyboardType: TextInputType.number,
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
              _firestore.collection('routes').doc(routeId).update({
                'name': nameCtrl.text.trim(),
                'stops': int.tryParse(stopsCtrl.text) ?? 0,
                'distance': distanceCtrl.text.trim(),
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

  void _deleteRoute(String routeId) {
    _firestore.collection('routes').doc(routeId).delete();
  }
}
