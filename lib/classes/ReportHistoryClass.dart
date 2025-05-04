class ReportHistoryClass {
  final String report_history_id;
  final String incident_report_id;
  final String date_time;
  final String status;
  final String is_done;

  ReportHistoryClass(
      {required this.report_history_id,
      required this.incident_report_id,
      required this.date_time,
      required this.status,
      required this.is_done});

  Map<String, dynamic> toMap() {
    return {
      report_history_id: report_history_id,
      incident_report_id: incident_report_id,
      date_time: date_time,
      status: status,
      is_done: is_done
    };
  }

  factory ReportHistoryClass.fromJson(Map<String, dynamic> json) {
    return ReportHistoryClass(
        report_history_id: json['report_history_id'],
        incident_report_id: json['incident_report_id'],
        date_time: json['date_time'],
        status: json['status'],
        is_done: json['is_done']);
  }
}
