import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/report.service.dart';
import 'package:performance_tracker/src/features/Coach/models/report.model.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final reportService = locator<ReportService>();
  List<Report> reports = [];
  @override
  void initState() {
    super.initState();
    reports = reportService.fetchAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports ${reports.length}')),
      body: reports.isEmpty
          ? const Center(child: Text('No reports available.'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    ...reports.map((report) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text('Report for Entity: ${report.entityId}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Generated: ${report.generatedAt}'),
                              Text('Last Updated: ${report.entityLastUpdated}'),
                              Text('Data: ${report.reportData}'),
                            ],
                          ),
                        ),
                      );
                    }),
                    Row(children: [ElevatedButton(onPressed: ()async{
                      await reportService.clearAllReports();
                      reports = [];
                      setState(() {
                        
                      });
                    }, child: Text("Remove all"))],)
                  ],
                ),
              ),
            ),
    );
  }
}
