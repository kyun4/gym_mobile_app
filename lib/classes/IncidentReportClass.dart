class IncidentReportClass {
  final String incident_report_id;
  final String report_content;
  final String report_date_time;
  final String report_by;
  final String report_by_role;
  final String report_to;
  final String report_to_role;
  final String report_type;
  final String status;
  final String admin_handled_by;
  final String admin_handled_date_time;

  IncidentReportClass(
      {required this.incident_report_id,
      required this.report_content,
      required this.report_date_time,
      required this.report_by,
      required this.report_by_role,
      required this.report_to,
      required this.report_to_role,
      required this.report_type,
      required this.status,
      required this.admin_handled_by,
      required this.admin_handled_date_time});

  Map<String, dynamic> toMap() {
    return {
      incident_report_id: incident_report_id,
      report_content: report_content,
      report_date_time: report_date_time,
      report_by: report_by,
      report_by_role: report_by_role,
      report_to: report_to,
      report_to_role: report_to_role,
      report_type: report_type,
      status: status,
      admin_handled_by: admin_handled_by,
      admin_handled_date_time: admin_handled_date_time
    };
  }

  factory IncidentReportClass.fromJson(Map<String, dynamic> json) {
    return IncidentReportClass(
        incident_report_id: json['incident_report_id'],
        report_content: json['report_content'],
        report_date_time: json['report_date_time'],
        report_by: json['report_by'],
        report_by_role: json['report_by_role'],
        report_to: json['report_to'],
        report_to_role: json['report_to_role'],
        report_type: json['report_type'],
        status: json['status'],
        admin_handled_by: json['admin_handled_by'],
        admin_handled_date_time: json['admin_handled_date_time']);
  }
}
