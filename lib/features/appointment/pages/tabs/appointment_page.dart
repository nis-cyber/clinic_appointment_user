import 'package:clinic_users/features/appointment/data/appointment_provider.dart';
import 'package:clinic_users/features/appointment/pages/tabs/accepted_appointment_page.dart';
import 'package:clinic_users/features/appointment/pages/tabs/pending_appointment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentPage extends ConsumerStatefulWidget {
  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends ConsumerState<AppointmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(appointmentNotifierProvider, (previous, next) {
      // When an appointment is accepted, switch to the Accepted tab
      _tabController.animateTo(1);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PendingAppointmentTab(),
          AcceptedAppointmentTab(),
        ],
      ),
    );
  }
}
