// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Queue Management',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: QueueManagementScreen(),
//     );
//   }
// }

// class QueueManagementScreen extends StatefulWidget {
//   @override
//   _QueueManagementScreenState createState() => _QueueManagementScreenState();
// }

// class _QueueManagementScreenState extends State<QueueManagementScreen> {
//   final DatabaseReference _queueRef =
//       FirebaseDatabase.instance.ref().child('queue');
//   int _queuePosition = 0;
//   int _estimatedWaitTime = 0;
//   bool _inQueue = false;

//   @override
//   void initState() {
//     super.initState();
//     _listenToQueueChanges();
//   }

//   void _listenToQueueChanges() {
//     _queueRef.onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         Map<dynamic, dynamic> queueData =
//             event.snapshot.value as Map<dynamic, dynamic>;
//         setState(() {
//           _queuePosition = queueData['position'] ?? 0;
//           _estimatedWaitTime = _calculateWaitTime(_queuePosition);
//           _inQueue = _queuePosition > 0;
//         });
//       }
//     });
//   }

//   int _calculateWaitTime(int position) {
//     // Assume each person takes 5 minutes, cap at 30 minutes
//     return (position * 5).clamp(0, 30);
//   }

//   void _joinQueue() async {
//     await _queueRef.set({
//       'position': 5, // Simulating joining the queue
//       'timestamp': ServerValue.timestamp,
//     });
//   }

//   void _leaveQueue() async {
//     await _queueRef.set(null);
//   }

//   void _showNotification(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Queue Management'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (_inQueue) ...[
//               Text(
//                 'Your position in queue:',
//                 style: TextStyle(fontSize: 18),
//               ),
//               Text(
//                 '$_queuePosition',
//                 style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Estimated wait time:',
//                 style: TextStyle(fontSize: 18),
//               ),
//               Text(
//                 '$_estimatedWaitTime minutes',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 40),
//               ElevatedButton(
//                 onPressed: _leaveQueue,
//                 child: Text('Leave Queue'),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               ),
//             ] else
//               ElevatedButton(
//                 onPressed: _joinQueue,
//                 child: Text('Join Virtual Queue'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
