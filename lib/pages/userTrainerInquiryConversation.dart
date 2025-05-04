import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitup/classes/messages.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserTrainerInquiryConversation extends StatefulWidget {
  const UserTrainerInquiryConversation({super.key});

  @override
  State<UserTrainerInquiryConversation> createState() =>
      _userTrainerInquiryConversationState();
}

Future<String?> getSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  return ref.getString(key);
} // getSession

void sendMessagePush(
    String messageContent, senderId, receiverId, isClientRequest) async {
  final messageRef = FirebaseDatabase.instance.ref('messages').push();
  await messageRef.set({
    'message_id': messageRef.key,
    'message_content': messageContent,
    'message_session_id': senderId + '_' + receiverId,
    'sender': senderId,
    'receiver': receiverId,
    'date_time': DateTime.now().toIso8601String(),
    'is_seen': '0',
    'is_client_request': isClientRequest,
    'is_deleted': '0'
  });
}

class _userTrainerInquiryConversationState
    extends State<UserTrainerInquiryConversation> {
  String? firebaseUIDValue;
  String? roleId;
  String? receiverIdValue;
  String? receiverName;
  String?
      isClientRequest; // check if the message is the first one from user to trainer
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

  Stream<List<Messages>> getMessagesStream(
      String userFirebaseUID, String trainerId) {
    final databaseRef = FirebaseDatabase.instance.ref('messages');

    return databaseRef.onValue.map((event) {
      final List<Messages> listMsg = [];
      final extractedData =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      extractedData.forEach((messageId, messageData) {
        if (userFirebaseUID == messageData['sender'] &&
                trainerId == messageData['receiver'] ||
            userFirebaseUID == messageData['receiver'] &&
                trainerId == messageData['sender']) {
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
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text("" + error.toString())));

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
    String? receiverNameValue = await getSession("receiverName");
    String? rID = await getSession("receiverId");
    setState(() {
      receiverName = receiverNameValue;
      receiverIdValue = rID;
    });
  }

  Widget build(BuildContext context) {
    final textMessageController = TextEditingController();

    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // roleId = await getUserRole(firebaseUIDValue!);

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return UserMainMenu(
                        selectedInitIndex: 1, subSelectedInitIndex: 26);
                  }));
                }),
            centerTitle: true,
            title: Text(receiverName ?? "[Trainer Name]"),
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
                    _makePhoneCall("09927073923");
                  })
            ]),
        body: Stack(children: [
          SafeArea(
              child: StreamBuilder<List<Messages>>(
                  stream: getMessagesStream(
                      firebaseUIDValue ?? "", receiverIdValue ?? ""),
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

                    return ListView.builder(
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
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
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
              bottom: 2,
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
                      onTap: () async {
                        isClientRequest = '1';

                        var messageContent = textMessageController.text;
                        textMessageController.text = "";

                        sendMessagePush(
                            messageContent,
                            firebaseAuth!.uid.toString(),
                            receiverIdValue,
                            isClientRequest);
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
