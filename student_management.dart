import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/theme.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
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
        title: const Text('Manage Students'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () => _showAddStudentDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No students found',
                style: AppTheme.bodyStyle,
              ),
            );
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final data = student.data() as Map<String, dynamic>;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(
                    data['studentName'] ?? 'N/A',
                    style: AppTheme.cardTitleStyle,
                  ),
                  subtitle: Text(
                      'Roll: ${data['rollNumber'] ?? 'N/A'} | ID: ${student.id.substring(0, 8)}...'),
                  trailing: PopupMenuButton(
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () => _showEditStudentDialog(
                          context,
                          student.id,
                          data,
                        ),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                        onTap: () => _deleteStudent(student.id),
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

  void _showAddStudentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final rollCtrl = TextEditingController();
    final busIdCtrl = TextEditingController();
    final rfidCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Student Name'),
              ),
              TextField(
                controller: rollCtrl,
                decoration: const InputDecoration(labelText: 'Roll Number'),
              ),
              TextField(
                controller: busIdCtrl,
                decoration: const InputDecoration(labelText: 'Bus ID'),
              ),
              TextField(
                controller: rfidCtrl,
                decoration: const InputDecoration(labelText: 'RFID UID'),
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
              _firestore.collection('students').add({
                'studentName': nameCtrl.text.trim(),
                'rollNumber': rollCtrl.text.trim(),
                'busId': busIdCtrl.text.trim(),
                'rfidUid': rfidCtrl.text.trim(),
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

  void _showEditStudentDialog(
    BuildContext context,
    String studentId,
    Map<String, dynamic> data,
  ) {
    final nameCtrl = TextEditingController(text: data['studentName']);
    final rollCtrl = TextEditingController(text: data['rollNumber']);
    final busIdCtrl = TextEditingController(text: data['busId']);
    final rfidCtrl = TextEditingController(text: data['rfidUid']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Student Name'),
              ),
              TextField(
                controller: rollCtrl,
                decoration: const InputDecoration(labelText: 'Roll Number'),
              ),
              TextField(
                controller: busIdCtrl,
                decoration: const InputDecoration(labelText: 'Bus ID'),
              ),
              TextField(
                controller: rfidCtrl,
                decoration: const InputDecoration(labelText: 'RFID UID'),
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
              _firestore.collection('students').doc(studentId).update({
                'studentName': nameCtrl.text.trim(),
                'rollNumber': rollCtrl.text.trim(),
                'busId': busIdCtrl.text.trim(),
                'rfidUid': rfidCtrl.text.trim(),
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

  void _deleteStudent(String studentId) {
    _firestore.collection('students').doc(studentId).delete();
  }
}
