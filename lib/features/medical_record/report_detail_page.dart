import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> reportData;

  ReportDetailPage({required this.reportData});

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _hasSubmittedFeedback = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkExistingFeedback();
  }

  Future<void> _checkExistingFeedback() async {
    try {
      await Firebase.initializeApp();
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      var feedbackDoc = await firestore
          .collection('doctor_feedback')
          .where('report_id', isEqualTo: widget.reportData['report_id'])
          .get();

      setState(() {
        _hasSubmittedFeedback = feedbackDoc.docs.isNotEmpty;
        _isLoading = false;
      });

      if (_hasSubmittedFeedback) {
        var data = feedbackDoc.docs.first.data();
        setState(() {
          _rating = data['rating'] ?? 0;
          _feedbackController.text = data['feedback'] ?? '';
        });
      }
    } catch (e) {
      print('Error checking existing feedback: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Firebase.initializeApp();
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Prepare feedback data
      Map<String, dynamic> feedbackData = {
        'report_id': widget.reportData['report_id'],
        'doctor_id': widget.reportData['doctor_id'],
        'doctor_name': widget.reportData['doctor_name'],
        'patient_id': widget.reportData['patient_id'],
        'rating': _rating,
        'feedback': _feedbackController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Check if feedback already exists
      var existingFeedback = await firestore
          .collection('doctor_feedback')
          .where('report_id', isEqualTo: widget.reportData['report_id'])
          .get();

      if (existingFeedback.docs.isNotEmpty) {
        // Update existing feedback
        await firestore
            .collection('doctor_feedback')
            .doc(existingFeedback.docs.first.id)
            .update(feedbackData);
      } else {
        // Add new feedback
        await firestore.collection('doctor_feedback').add(feedbackData);
      }

      // Also update the doctor's average rating
      await _updateDoctorAverageRating(widget.reportData['doctor_id']);

      setState(() {
        _hasSubmittedFeedback = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
    } catch (e) {
      print('Error submitting feedback: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    }
  }

  Future<void> _updateDoctorAverageRating(String doctorId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get all feedback for this doctor
      var allFeedbacks = await firestore
          .collection('doctor_feedback')
          .where('doctor_id', isEqualTo: doctorId)
          .get();

      if (allFeedbacks.docs.isEmpty) return;

      // Calculate average rating
      double totalRating = 0;
      int count = 0;

      for (var doc in allFeedbacks.docs) {
        var data = doc.data();
        if (data['rating'] != null) {
          totalRating += data['rating'];
          count++;
        }
      }

      double averageRating = count > 0 ? totalRating / count : 0;

      // Update doctor's average rating in doctors collection
      await firestore.collection('doctors').doc(doctorId).update({
        'average_rating': averageRating,
        'feedback_count': count,
      });
    } catch (e) {
      print('Error updating doctor average rating: $e');
    }
  }

  Future<String> _generateAndSavePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Medical Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Doctor: ${widget.reportData['doctor_name']}'),
              pw.Text('Speciality: ${widget.reportData['speciality']}'),
              pw.SizedBox(height: 20),
              pw.Text('Diagnosis: ${widget.reportData['diagnosis']}'),
              pw.Text('Treatment: ${widget.reportData['treatment']}'),
              pw.Text('Medications: ${widget.reportData['medications']}'),
              pw.Text('Comments: ${widget.reportData['comments']}'),
              pw.Text(
                  'Date: ${DateFormat('MMMM d, yyyy').format(DateTime.parse(widget.reportData['date']))}'),
              pw.Text('Time Slot: ${widget.reportData['time_slot']}'),
              if (_hasSubmittedFeedback) ...[
                pw.SizedBox(height: 20),
                pw.Text('Rating: $_rating / 5'),
                pw.Text('Feedback: ${_feedbackController.text}'),
              ],
            ],
          );
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File(
        "${output.path}/medical_report_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  void _viewPDF(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(filePath: filePath),
      ),
    );
  }

  void _showSavedPDFs() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync()
        .where((file) => file.path.endsWith('.pdf'))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved PDFs'),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: files
                  .map((file) => ListTile(
                        title: Text(file.path.split('/').last),
                        onTap: () {
                          Navigator.pop(context);
                          _viewPDF(file.path);
                        },
                      ))
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final filePath = await _generateAndSavePDF();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF has been saved')),
              );
              _viewPDF(filePath);
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: _showSavedPDFs,
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 173, 205, 204),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 173, 205, 204),
                    Color.fromARGB(255, 180, 152, 225)
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDoctorCard(),
                    _buildReportCard(context),
                    _buildFeedbackCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDoctorCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 177, 238, 231),
              const Color.fromARGB(255, 50, 76, 74)
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.teal[700],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reportData['doctor_name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.reportData['speciality'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.local_hospital, 'Diagnosis',
                widget.reportData['diagnosis']),
            _buildDetailRow(Icons.medical_services, 'Treatment',
                widget.reportData['treatment']),
            _buildDetailRow(Icons.medication, 'Medications',
                widget.reportData['medications']),
            _buildDetailRow(
                Icons.comment, 'Comments', widget.reportData['comments']),
            _buildDetailRow(
              Icons.calendar_today,
              'Date',
              DateFormat('MMMM d, yyyy')
                  .format(DateTime.parse(widget.reportData['date'])),
            ),
            _buildDetailRow(
                Icons.access_time, 'Time Slot', widget.reportData['time_slot']),
            if (_hasSubmittedFeedback) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Your Feedback',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700]),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  RatingBarIndicator(
                    rating: _rating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 24.0,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_rating/5',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_feedbackController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _feedbackController.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
            ],
            if (widget.reportData['image_url'] != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Attached Document:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.reportData['image_url'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text('Error loading image'),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _hasSubmittedFeedback
                  ? 'Edit Your Feedback'
                  : 'Rate Your Experience',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rate your doctor and the consultation:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Additional Feedback (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _hasSubmittedFeedback ? 'Update Feedback' : 'Submit Feedback',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal[700], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.teal[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String filePath;

  PDFViewerPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        backgroundColor: const Color.fromARGB(255, 173, 205, 204),
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onRender: (_pages) {
          // You can add a loading indicator here if needed
        },
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
      ),
    );
  }
}
