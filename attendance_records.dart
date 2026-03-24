import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/theme.dart';
import 'package:intl/intl.dart';

class AttendanceRecordsScreen extends StatefulWidget {
  const AttendanceRecordsScreen({super.key});

  @override
  State<AttendanceRecordsScreen> createState() =>
      _AttendanceRecordsScreenState();
}

class _AttendanceRecordsScreenState extends State<AttendanceRecordsScreen> {
  late FirebaseFirestore _firestore;
  DateTime selectedDate = DateTime.now();

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
        title: const Text('Attendance Records'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Date Picker
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                  style: AppTheme.cardTitleStyle,
                ),
                ElevatedButton(
                  style: AppTheme.smallButtonStyle(),
                  onPressed: () => _selectDate(context),
                  child: const Text('Change Date'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Attendance List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('attendance_events')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No attendance records',
                      style: AppTheme.bodyStyle,
                    ),
                  );
                }

                final records = snapshot.data!.docs
                    .where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final timestamp = data['timestamp'] as Timestamp?;
                      if (timestamp == null) return false;
                      final docDate = timestamp.toDate();
                      return docDate.year == selectedDate.year &&
                          docDate.month == selectedDate.month &&
                          docDate.day == selectedDate.day;
                    })
                    .toList();

                if (records.isEmpty) {
                  return Center(
                    child: Text(
                      'No records for this date',
                      style: AppTheme.bodyStyle,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final data = record.data() as Map<String, dynamic>;
                    final timestamp =
                        (data['timestamp'] as Timestamp).toDate();

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(
                          data['scanType'] == 'checkin'
                              ? Icons.login
                              : Icons.logout,
                          color: data['scanType'] == 'checkin'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        title: Text(
                          'ID: ${data['studentId'] ?? 'N/A'}',
                          style: AppTheme.cardTitleStyle,
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Type: ${data['scanType'] ?? 'N/A'}',
                            ),
                            Text(
                              'Time: ${DateFormat('hh:mm a').format(timestamp)}',
                            ),
                          ],
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
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() => selectedDate = pickedDate);
    }
  }
}
