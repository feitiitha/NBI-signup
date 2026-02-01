import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference _jobseekers = FirebaseFirestore.instance.collection(
    'jobseekers',
  );

  // Add a new jobseeker
  Future<void> addJobseeker(Map<String, dynamic> data) async {
    await _jobseekers.add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  // Delete a jobseeker by Document ID
  Future<void> deleteJobseeker(String docId) async {
    return await _jobseekers.doc(docId).delete();
  }

  // Stream of jobseekers for the list view
  Stream<QuerySnapshot> getJobseekers() {
    return _jobseekers.orderBy('createdAt', descending: true).snapshots();
  }
}
