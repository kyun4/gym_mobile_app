class MessagesClass {
  final String message_id;
  final String message_content;
  final String date_time;
  final String sender;
  final String receiver;
  final String is_seen;
  final String is_client_request;

  MessagesClass(
      {required this.message_id,
      required this.message_content,
      required this.date_time,
      required this.sender,
      required this.receiver,
      required this.is_seen,
      required this.is_client_request});
}
