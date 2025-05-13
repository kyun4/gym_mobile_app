import 'package:flutter/material.dart';
import 'package:fitup/classes/IncidentReportClass.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class AdminReport extends StatefulWidget {
  const AdminReport({super.key});

  State<AdminReport> createState() => _adminReportState();
}

String getReportStatus(String IdValue) {
  String valueLabel = "";
  switch (IdValue) {
    case "0":
      valueLabel = "New";
    case "1":
      valueLabel = "Resolved";
    case "2":
      valueLabel = "On-process";
    case "3":
      valueLabel = "Unresolved but Done";
  }
  return valueLabel;
} // getReportStatus

String getReportType(String IdValue) {
  String valueLabel = "";
  switch (IdValue) {
    case "0":
      valueLabel = "Others";
    case "1":
      valueLabel = "Client Payment for Gym Session";
    case "2":
      valueLabel = "Client dispute with Trainer";
    case "3":
      valueLabel = "Client report on Gym Class";
    case "4":
      valueLabel = "Report on Misleading Ads";
    case "5":
      valueLabel = "Trainer dispute on Payment Remittance";
    case "6":
      valueLabel = "Trainer dispute with Client Payment";
    case "7":
      valueLabel = "Trainer dispute with Client";
    case "8":
      valueLabel = "Client Payment for Gym Membership";
  }
  return valueLabel;
} // getReportType

Future<List<IncidentReportClass>> getIncidentReports() async {
  List<IncidentReportClass> listIncidentReportData = [];
  String url = dbUrl + "incident_reports.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((key, json) {
      listIncidentReportData.add(IncidentReportClass(
          incident_report_id: json['incident_report_id'] ?? "",
          report_content: json['report_content'] ?? "",
          report_date_time: json['report_date_time'] ?? "",
          report_by: json['report_by'] ?? "",
          report_by_role: json['report_by_role'] ?? "",
          report_to: json['report_to'] ?? "",
          report_to_role: json['report_to_role'] ?? "",
          report_type: json['report_type'] ?? "",
          status: json['status'] ?? "",
          admin_handled_by: json['admin_handled_by'] ?? "",
          admin_handled_date_time: json['admin_handled_date_time'] ?? ""));
    });
  } catch (error) {
    throw error;
  }

  return listIncidentReportData;
} // getIncidentReports

class _adminReportState extends State<AdminReport> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: Icon(Icons.arrow_back_ios_new),
            centerTitle: true,
            title: Text("Incident Reports", style: TextStyle(fontSize: 14))),
        body: SafeArea(
            child: Container(
                child: Column(children: [
          Container(
              height: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                  stream: getIncidentReports().asStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("No data available"));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var rawdata = snapshot.data!;
                    final deduplicated = <String, dynamic>{};

                    for (var item in rawdata) {
                      deduplicated[item.incident_report_id] = item;
                    }

                    final uniqueList = deduplicated.values.toList();

                    return ListView.builder(
                        itemCount: uniqueList.length,
                        itemBuilder: (context, index) {
                          final dataContent = uniqueList[index];
                          String reportContent = dataContent.report_content;

                          String reportTypeId = dataContent.report_type;
                          String reportType = getReportType(reportTypeId);

                          String reportStatusId = dataContent.status;
                          String reportStatus = getReportStatus(reportStatusId);

                          String reportDateTime = dataContent.report_date_time;

                          String reportSubmittedBy = "";

                          return Container(
                              width: MediaQuery.of(context).size.width,
                              child: Row(children: [
                                Container(
                                    margin: const EdgeInsets.all(10),
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.grey.withOpacity(0.3)),
                                    child: Icon(Icons.report)),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 220,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(reportType,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(reportStatus)
                                      ]),
                                ),
                                Container(
                                    width: 150,
                                    height: 50,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("by $reportSubmittedBy",
                                              style: TextStyle(fontSize: 12)),
                                          Text(reportDateTime,
                                              style: TextStyle(fontSize: 12))
                                        ]))
                              ]));
                        });
                  }))
        ]))));
  }
}
