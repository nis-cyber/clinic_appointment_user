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
          _rating = data['rating'];
          _feedbackController.text = data['feedback'];
        });
      }
    } catch (e) {
      print('Error checking existing feedback: $e');
      setState(() {
        _isLoading = false;
      });
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
      body: Container(
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
              _buildRatingAndFeedbackCard(),
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
              const Color.fromARGB(255, 177, 238, 231)!,
              const Color.fromARGB(255, 50, 76, 74)!
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

  Widget _buildRatingAndFeedbackCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
            ),
            const SizedBox(height: 10),
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
                  if (!_hasSubmittedFeedback) {
                    setState(() {
                      _rating = rating;
                    });
                  }
                },
                ignoreGestures: _hasSubmittedFeedback,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your feedback here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              readOnly: _hasSubmittedFeedback,
            ),
            const SizedBox(height: 20),
            Center(
              child: _hasSubmittedFeedback
                  ? Text(
                      'Thank you for your feedback!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _submitRatingAndFeedback,
                      child: const Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRatingAndFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating')),
      );
      return;
    }

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('doctor_feedback').add({
        'doctor_id': widget.reportData['doctor_id'],
        'report_id': widget.reportData['report_id'],
        'rating': _rating,
        'feedback': _feedbackController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _hasSubmittedFeedback = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    }
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
