import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/theme.dart';

class RfidMappingScreen extends StatefulWidget {
  const RfidMappingScreen({super.key});

  @override
  State<RfidMappingScreen> createState() => _RfidMappingScreenState();
}

class _RfidMappingScreenState extends State<RfidMappingScreen> {
  late FirebaseFirestore _firestore;
  String? selectedStudentId;
  final rfidCtrl = TextEditingController();

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
        title: const Text('RFID Mapping'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign RFID UID to Students',
              style: AppTheme.subHeadingStyle,
            ),
            const SizedBox(height: 16),

            // Student Dropdown
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('students').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final students = snapshot.data!.docs;

                return DropdownButton<String>(
                  hint: const Text('Select Student'),
                  value: selectedStudentId,
                  isExpanded: true,
                  items: students.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(data['studentName'] ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedStudentId = value);
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // RFID Input
            TextField(
              controller: rfidCtrl,
              decoration: InputDecoration(
                labelText: 'RFID UID',
                hintText: 'Enter RFID tag ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Assign Button
            ElevatedButton(
              style: AppTheme.primaryButtonStyle(),
              onPressed:
                  selectedStudentId == null ? null : _assignRfid,
              child: const Text('Assign RFID'),
            ),
            const SizedBox(height: 32),

            // List of Mappings
            Text(
              'Current Mappings',
              style: AppTheme.subHeadingStyle,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('students').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final students = snapshot.data!.docs
                      .where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['rfidUid'] != null &&
                            data['rfidUid'].toString().isNotEmpty;
                      })
                      .toList();

                  if (students.isEmpty) {
                    return Center(
                      child: Text(
                        'No RFID mappings yet',
                        style: AppTheme.bodyStyle,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final data =
                          student.data() as Map<String, dynamic>;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.nfc),
                          title: Text(data['studentName'] ?? 'N/A'),
                          subtitle:
                              Text('RFID: ${data['rfidUid']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _removeRfid(student.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _assignRfid() {
    final rfidValue = rfidCtrl.text.trim();

    if (rfidValue.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter RFID UID')));
      return;
    }

    _firestore
        .collection('students')
        .doc(selectedStudentId)
        .update({'rfidUid': rfidValue});

    rfidCtrl.clear();
    setState(() => selectedStudentId = null);

    ScaffoldMessenger.of(context)
        .showSnackBar(
          const SnackBar(content: Text('RFID assigned successfully')),
        );
  }

  void _removeRfid(String studentId) {
    _firestore
        .collection('students')
        .doc(studentId)
        .update({'rfidUid': ''});
  }

  @override
  void dispose() {
    rfidCtrl.dispose();
    super.dispose();
  }
}
