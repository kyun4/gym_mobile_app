import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/pages/instructorMainMenu.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitup/classes/messages.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserMessageConversation extends StatefulWidget {
  const UserMessageConversation({super.key});

  @override
  State<UserMessageConversation> createState() =>
      _userMessageConversationState();
}

Future<void> setSession(String key, String value) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.setString(key, value);
} //

Future<String?> getSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  return ref.getString(key);
} // getSession

Future<void> removeSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.remove(key);
} // removeSession

void sendMessagePush(
    String messageContent, messageSessionId, senderId, receiverId) async {
  final messageRef = FirebaseDatabase.instance.ref('messages').push();
  await messageRef.set({
    'message_id': messageRef.key,
    'message_content': messageContent,
    'message_session_id': messageSessionId,
    'sender': senderId,
    'receiver': receiverId,
    'date_time': DateTime.now().toIso8601String(),
    'is_seen': '0',
    'is_client_request': '0',
    'is_deleted': ''
  });
}

void sendMessage(String message, String sender_id, String receiver_id) async {
  var messageID_value = Uuid();
  var messageID = messageID_value.v4();
  var date_time = DateTime.now().toUtc();
  var formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  var date_time_formatted = formatter.format(date_time);

  var url = dbUrl + "messages/$messageID.json";

  try {
    final response = await http.put(Uri.parse(url),
        body: json.encode({
          'message_id': messageID,
          'message_session_id': sender_id + '_' + receiver_id,
          'message_content': message,
          'sender': sender_id,
          'receiver': receiver_id,
          'date_time': date_time_formatted,
          'is_seen': '0',
          'is_client_request': '0',
          'is_deleted': '0'
        }));
  } catch (error) {
    throw error;
  }
}

class _userMessageConversationState extends State<UserMessageConversation> {
  String? firebaseUIDValue;
  String? roleId;
  String? receiverId;
  String? receiverName;
  String? receiverMessageId;
  String? receiverIsClientRequest;
  String? receiverPhone;
  String? messageSessionId;
  List<Messages> listMsgPush = [];

  _makePhoneCall(String phoneNumber) async {
    // Check if the permission is granted
    if (await Permission.phone.request().isGranted) {
      // The permission is granted, initiate the call
      final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        //throw 'Could not launch $phoneNumber';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not launch')));
      }
    } else {
      // If permission is denied
      print("Phone call permission denied");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone call permission denied')));
    }
  }

  Future<String> getUserRole(String firebaseUID) async {
    String roleId = "";

    var url = dbUrl + "users.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (response.body == null || response.body.isEmpty) {
        return "";
      }

      extractedData.forEach((userId, userData) {
        if (firebaseUID == userData['firebase_uid']) {
          roleId = userData['role'];
        }
      });
    } catch (error) {
      throw error;
    }

    return roleId;
  } // getUserRole

  Stream<List<Messages>> getMessagesStream(
      String userFirebaseUID, String messageSessionID) {
    final databaseRef = FirebaseDatabase.instance.ref('messages');

    return databaseRef.onValue.map((event) {
      final List<Messages> listMsg = [];
      final extractedData =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      extractedData.forEach((messageId, messageData) {
        if (messageSessionID == messageData['message_session_id']) {
          listMsg.add(Messages(
              message_id: messageData['message_id'],
              message_session_id: messageData['message_session_id'],
              message_content: messageData['message_content'],
              sender: messageData['sender'],
              receiver: messageData['receiver'],
              date_time: messageData['date_time'],
              is_seen: messageData['is_seen'],
              is_client_request: messageData['is_client_request'],
              is_deleted: messageData['is_deleted']));
        }
      });

      final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

      listMsg.sort((a, b) =>
          DateTime.parse(a.date_time).compareTo(DateTime.parse(b.date_time)));

      //listMsg.reversed.toList();

      return listMsg;
    });
  }

  Stream<List<Messages>> getMessages() async* {
    List<Messages> listMsg = [];

    var url = dbUrl + "messages.json";

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body);

      if (response.body == null || response.body.isEmpty) {
        print("No data returned from server");
        yield [];
        return;
      }

      if (extractedData is! Map<String, dynamic>) {
        yield [];
        return;
      }

      (extractedData as Map<String, dynamic>).forEach((messageId, messageData) {
        Messages getMessageData = Messages(
            message_id: messageData['message_id'],
            message_session_id: messageData['message_session_id'],
            message_content: messageData['message_content'],
            sender: messageData['sender'],
            receiver: messageData['receiver'],
            date_time: messageData['date_time'],
            is_seen: messageData['is_seen'],
            is_client_request: messageData['is_client_request'],
            is_deleted: messageData['is_deleted']);

        listMsg.add(getMessageData);
      });

      yield listMsg;
    } catch (error) {
      yield [];
      throw error;
    }
  }

  final firebaseAuth = FirebaseAuth.instance.currentUser;

  void initState() {
    super.initState();

    setState(() {
      firebaseUIDValue = FirebaseAuth.instance.currentUser!.uid.toString();
    });

    getReceiverDetails();
  }

  Future<void> getReceiverDetails() async {
    String? messageId = await getSession("messageId");
    String? isClientRequest = await getSession("is_client_request");
    String? receiverIdValue = await getSession("receiverId");
    String? messageSessionIdValue = await getSession("message_session_id");
    String? receiverNameValue = await getSession("receiverName");
    String? receiverPhoneNumber = await getSession("receiver_phone");
    setState(() {
      receiverId = receiverIdValue;
      messageSessionId = messageSessionIdValue;
      receiverName = receiverNameValue;
      receiverMessageId = messageId;
      receiverIsClientRequest = isClientRequest;
      receiverPhone = receiverPhoneNumber;
    });
  }

  void updateMessageDataClientRequest(String messageId) {
    String url = dbUrl + "messages/$messageId.json";
    try {
      final response = http.patch(Uri.parse(url),
          body: json.encode({"is_client_request": "0"}));
    } catch (error) {
      throw error;
    }
  } // updateMessageDataClientRequest

  Widget build(BuildContext context) {
    final textMessageController = TextEditingController();
    final ScrollController _scrollController = ScrollController();

    void _scrollToEnd() {
      // Wait for the build method to complete before scrolling
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () async {
                  roleId = await getUserRole(firebaseUIDValue!);
                  removeSession("receiverId");
                  removeSession("receiverName");
                  removeSession("message_session_id");
                  removeSession("is_client_request");
                  removeSession("messageId");
                  removeSession("receiver_phone");
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return roleId == "1"
                        ? UserMainMenu(
                            selectedInitIndex: 3, subSelectedInitIndex: 0)
                        : InstructorMainMenu(
                            selectedInitIndex: 1, subSelectedInitIndex: 0);
                  }));
                }),
            centerTitle: true,
            title: Text(receiverName ?? ""),
            actions: <Widget>[
              IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Video Call")));
                  },
                  icon: Icon(Icons.video_call)),
              IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    // ScaffoldMessenger.of(context)
                    //     .showSnackBar(SnackBar(content: Text("Call")));
                    _makePhoneCall(receiverPhone ?? "");
                  })
            ]),
        body: Stack(children: [
          Container(
              padding: const EdgeInsets.only(bottom: 35),
              height: MediaQuery.of(context).size.height - 130,
              child: StreamBuilder<List<Messages>>(
                  stream: getMessagesStream(
                      firebaseUIDValue ?? "", messageSessionId ?? ""),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("No new messages"));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No messsages available"));
                    }

                    final messagesValue = snapshot.data!;
                    String firebaseUID = firebaseAuth!.uid.toString();

                    _scrollToEnd();

                    return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 60),
                        controller: _scrollController,
                        itemCount: messagesValue.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          final messageObject = messagesValue[index];
                          return Align(
                            alignment: firebaseUID == messageObject.sender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.7),
                                margin: const EdgeInsets.only(
                                    top: 5, bottom: 5, left: 5, right: 5),
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10, left: 15, right: 15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: firebaseUID == messageObject.sender
                                        ? Color.fromARGB(199, 116, 10, 180)
                                        : Colors.grey.withOpacity(0.2)),
                                child: Text(messageObject.message_content,
                                    style: TextStyle(
                                        color:
                                            firebaseUID == messageObject.sender
                                                ? Colors.white
                                                : Colors.black87))),
                          );
                        });
                  })),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                  color: Color.fromARGB(255, 244, 243, 244),
                  child: Row(children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      margin:
                          const EdgeInsets.only(left: 15, top: 5, bottom: 5),
                      child: TextField(
                          controller: textMessageController,
                          obscureText: false,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 244, 243, 244),
                              suffixIcon: Container(child: Icon(Icons.add)),
                              contentPadding: const EdgeInsets.all(15),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color:
                                          Color.fromARGB(199, 116, 80, 160))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      BorderSide(color: Colors.black54)),
                              hintText: 'Type message here',
                              hintStyle: TextStyle(color: Colors.grey))),
                    ),
                    GestureDetector(
                      onTap: () {
                        var messageContent = textMessageController.text;
                        textMessageController.text = "";

                        if (messageContent.trim() != "") {
                          sendMessagePush(messageContent, messageSessionId,
                              firebaseAuth!.uid.toString(), receiverId);

                          if (receiverIsClientRequest == "1") {
                            updateMessageDataClientRequest(
                                receiverMessageId ?? "");
                          }
                        }

                        //_scrollToEnd();
                      },
                      child: Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          padding: const EdgeInsets.all(15),
                          child: Icon(Icons.send,
                              color: Colors.black87, size: 32)),
                    )
                  ])))
        ]));
  }
}
