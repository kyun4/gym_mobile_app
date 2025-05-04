class Messages {
  final String message_id;
  final String message_session_id;
  final String message_content;
  final String date_time;
  final String sender;
  final String receiver;
  final String is_seen;
  final String is_client_request;
  final String is_deleted;

  Messages(
      {required this.message_id,
      required this.message_session_id,
      required this.message_content,
      required this.date_time,
      required this.sender,
      required this.receiver,
      required this.is_seen,
      required this.is_client_request,
      required this.is_deleted});

  Map<String, dynamic> toMap() {
    return {
      message_id: message_id,
      message_session_id: message_session_id,
      message_content: message_content,
      date_time: date_time,
      sender: sender,
      receiver: receiver,
      is_seen: is_seen,
      is_client_request: is_client_request,
      is_deleted: is_deleted
    };
  }

  factory Messages.fromJson(Map<String, dynamic> json) {
    return Messages(
        message_id: json['message_id'],
        message_session_id: json['message_session_id'],
        message_content: json['message_content'],
        date_time: json['date_time'],
        sender: json['sender'],
        receiver: json['receiver'],
        is_seen: json['is_seen'],
        is_client_request: json['is_client_request'],
        is_deleted: json['is_deleted']);
  }
}
