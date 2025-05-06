import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitup/pages/instructorMainMenu.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/components/instructorInboxMode.dart';
import 'package:fitup/classes/messages.dart';
import 'package:fitup/classes/UserImagesClass.dart';
import 'package:fitup/classes/users.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserMessages extends StatefulWidget {
  const UserMessages({super.key});

  @override
  State<UserMessages> createState() => _userMessagesState();
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

class _userMessagesState extends State<UserMessages> {
  String? firebaseUIDValue;
  String? roleId;
  bool clientRequestMode = false;
  List<Users> listUsers = [];
  List<UserImagesClass> listUserImages = [];

  void toggleClientRequestTab() {
    setState(() {
      clientRequestMode = !clientRequestMode;
    });
  } // toggleClientRequestTab

  Future<void> getClientRequestMode() async {
    String? clientRequestModeString = await getSession("client_request_mode");
    setState(() {
      if (clientRequestModeString != "") {
        clientRequestMode = clientRequestModeString == "1" ? true : false;
      }
    });
  } // getClientRequestMode

  void getUsersData() {
    try {
      final databaseRef = FirebaseDatabase.instance.ref('users');

      databaseRef.onValue.map((event) {
        final extractedData =
            Map<String, dynamic>.from(event.snapshot.value as Map);

        extractedData.forEach((userId, usersData) {
          listUsers.add(usersData);
        });
      });
    } catch (error) {
      throw error;
    }
  } // getUsersData

  List<Messages> groupMessagesBySender(List<Messages> listMsg) {
    // Create a map to group messages by sender
    Map<String, Messages> uniqueSessions = {};

    for (var message in listMsg) {
      // If the message_session_id is not yet in the map, add it
      if (!uniqueSessions.containsKey(message.message_session_id)) {
        uniqueSessions[message.message_session_id] = message;
      }
    }

    uniqueSessions.values.toList().sort((a, b) =>
        DateTime.parse(b.date_time).compareTo(DateTime.parse(a.date_time)));

    return uniqueSessions.values.toList();
  }

  Future<List<UserImagesClass>> getUsersImageData() async {
    final List<UserImagesClass> listUserImages = [];

    String url = dbUrl + "user_images.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((id, data) {
        if (data['status'] == "1") {
          listUserImages.add(UserImagesClass(
              date_time_added: data['date_time_added'] ?? "",
              image_url: data['image_url'] ?? "",
              user_id: data['user_id'] ?? "",
              status: data['status'] ?? ""));
        }
      });
    } catch (error) {
      throw error;
    }

    return listUserImages;
  } // getUsersImageData

  Future<List<Messages>> getInbox(
      String firebaseUID, String roleId, bool clientRequestMode) async {
    List<Messages> listMsgGrouped = [];
    List<Messages> listMsgGroupedFiltered = [];
    final List<Messages> listMsg = [];

    String url = dbUrl + "messages.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((messageId, messageData) {
        if (firebaseUID == messageData['sender'] ||
            firebaseUID == messageData['receiver']) {
          listMsg.add(Messages(
              message_id: messageData['message_id'] ?? "",
              message_session_id: messageData['message_session_id'] ?? "",
              message_content: messageData['message_content'] ?? "",
              sender: messageData['sender'] ?? "",
              receiver: messageData['receiver'] ?? "",
              date_time: messageData['date_time'] ?? "",
              is_seen: messageData['is_seen'] ?? "",
              is_client_request: messageData['is_client_request'] ?? "",
              is_deleted: messageData['is_deleted'] ?? ""));
        }
      });
    } catch (error) {
      throw error;
    }

    listMsg.sort((a, b) =>
        DateTime.parse(b.date_time).compareTo(DateTime.parse(a.date_time)));

    if (roleId == '2') {
      if (clientRequestMode == false) {
        listMsgGroupedFiltered = listMsg
            .where((messageData) => messageData.is_client_request == '0')
            .toList();
      } else {
        listMsgGroupedFiltered = listMsg
            .where((messageData) => messageData.is_client_request == '1')
            .toList();
      }
    } else {
      listMsgGroupedFiltered = listMsg;
    }

    listMsgGrouped = groupMessagesBySender(listMsgGroupedFiltered);

    return listMsgGrouped;
  }

  final firebaseAuth = FirebaseAuth.instance.currentUser;

  Future<List<Users>> getAllUsers() async {
    String url = dbUrl + "users.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((userId, userData) {
        listUsers.add(Users(
            firebase_uid: userData['firebase_uid'] ?? '',
            username: userData['username'] ?? '',
            firstname: userData['firstname'] ?? '',
            middlename: userData['middlename'] ?? '',
            lastname: userData['lastname'] ?? '',
            ext: userData['ext'] ?? '',
            role: userData['role'] ?? '',
            phone: userData['phone'] ?? '',
            email: userData['email'] ?? '',
            otp: userData['otp'] ?? '',
            email_verified: userData['email_verified'] ?? '',
            occupation: userData['occupation'] ?? '',
            title: userData['title'] ?? '',
            date_time_registered: userData['date_time_registered'] ?? '',
            date_time_premium_activated: userData['date_time_activated'] ?? '',
            date_time_membership: userData['date_time_membership'] ?? ''));
      });
    } catch (error) {
      throw error;
    }

    return listUsers;
  }

  Future<List<Users>> getUsersDataJson() async {
    var url = dbUrl + "users.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (response.body == null || response.body.isEmpty) {
        return [];
      } else {
        extractedData.forEach((userId, userData) {
          listUsers.add(Users(
              firebase_uid: userData['firebase_uid'] ?? '',
              username: userData['username'] ?? '',
              firstname: userData['firstname'] ?? '',
              middlename: userData['middlename'] ?? '',
              lastname: userData['lastname'] ?? '',
              ext: userData['ext'] ?? '',
              role: userData['role'] ?? '',
              phone: userData['phone'] ?? '',
              email: userData['email'] ?? '',
              otp: userData['otp'] ?? '',
              email_verified: userData['email_verified'] ?? '',
              occupation: userData['occupation'] ?? '',
              title: userData['title'] ?? '',
              date_time_registered: userData['date_time_registered'] ?? '',
              date_time_premium_activated:
                  userData['date_time_activated'] ?? '',
              date_time_membership: userData['date_time_membership'] ?? ''));
        });
      }
    } catch (error) {
      throw error;
    }

    return listUsers;
  } // getUsersDataJson

  void initState() {
    super.initState();

    loadAllRecords();

    setState(() {
      firebaseUIDValue = FirebaseAuth.instance.currentUser!.uid.toString();
    });

    getAllUsersFuture();
    getClientRequestMode();
  }

  Future<void> loadAllRecords() async {
    List<UserImagesClass>? listUserImagesTemp = await getUsersImageData();

    setState(() {
      listUserImages = listUserImagesTemp;
    });
  } // loadAllRecords()

  void getAllUsersFuture() async {
    List<Users> listUserData = await getUsersDataJson();
    setState(() {
      listUsers = listUserData;
    });
  }

  Widget build(BuildContext context) {
    roleId = listUsers
                .where((userData) => userData.firebase_uid == firebaseUIDValue)
                .toList()
                .length >
            0
        ? listUsers
            .where((userData) => userData.firebase_uid == firebaseUIDValue)
            .toList()[0]
            .role
        : "1";

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(roleId == "2" ? "Client List" : "Inbox"),
            leading: Container(
                child: Icon(Icons.arrow_back, color: Colors.transparent))),
        body: SafeArea(
            child: Column(
          children: [
            Visibility(
              visible: roleId == "2" ? true : false,
              child: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          clientRequestMode = true;
                        });
                      },
                      child: InstructorInboxMode(
                          clientRequestMode: clientRequestMode,
                          inboxModeLabel: "Client Request"),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          clientRequestMode = false;
                        });
                      },
                      child: InstructorInboxMode(
                          clientRequestMode: clientRequestMode,
                          inboxModeLabel: "Your Clients"),
                    ),
                  ])),
            ),
            Container(
              height: MediaQuery.of(context).size.height - 200,
              child: StreamBuilder(
                  stream: getInbox(firebaseUIDValue ?? "", roleId ?? "",
                          clientRequestMode)
                      .asStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No new conversations"));
                    }

                    if (snapshot.hasError) {
                      return Center(
                          child: Text("${snapshot.error.toString()}"));
                    }

                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final messagesContent = snapshot.data!;
                          final messagesData = messagesContent[index];

                          String userSenderId = messagesData.sender;
                          String userReceiverId = messagesData.receiver;
                          String messageSessionId =
                              messagesData.message_session_id;
                          String messageId = messagesData.message_id;
                          String isClientRequest =
                              messagesData.is_client_request;

                          String? receiverName;
                          String? profileImage;

                          receiverName = listUsers
                                      .where((userdata) =>
                                          userdata.firebase_uid !=
                                              firebaseUIDValue &&
                                          userdata.firebase_uid == userSenderId)
                                      .toList()
                                      .length >
                                  0
                              ? listUsers
                                  .where((userdata) =>
                                      userdata.firebase_uid !=
                                          firebaseUIDValue &&
                                      userdata.firebase_uid == userSenderId)
                                  .toList()[0]
                                  .username
                              : "";

                          receiverName = receiverName == ""
                              ? listUsers
                                          .where((userdata) =>
                                              userdata.firebase_uid !=
                                                  firebaseUIDValue &&
                                              userdata.firebase_uid ==
                                                  userReceiverId)
                                          .toList()
                                          .length >
                                      0
                                  ? listUsers
                                      .where((userdata) =>
                                          userdata.firebase_uid !=
                                              firebaseUIDValue &&
                                          userdata.firebase_uid ==
                                              userReceiverId)
                                      .toList()[0]
                                      .username
                                  : "Loading User ..."
                              : listUsers
                                  .where((userdata) =>
                                      userdata.firebase_uid !=
                                          firebaseUIDValue &&
                                      userdata.firebase_uid == userSenderId)
                                  .toList()[0]
                                  .username;

                          String receiverIDValue = listUsers
                                      .where((data) =>
                                          data.username == receiverName)
                                      .length >
                                  0
                              ? listUsers
                                  .where(
                                      (data) => data.username == receiverName)
                                  .first
                                  .firebase_uid
                              : "";

                          profileImage = listUserImages
                                      .where((imageData) =>
                                          imageData.user_id == receiverIDValue)
                                      .toList()
                                      .length >
                                  0
                              ? listUserImages
                                  .where((imageData) =>
                                      imageData.user_id == receiverIDValue)
                                  .toList()[0]
                                  .image_url
                              : "";

                          return Visibility(
                            visible: true,
                            child: GestureDetector(
                              onTap: () {
                                String receiverID = listUsers
                                    .where((userdata) =>
                                        userdata.username == receiverName)
                                    .toList()[0]
                                    .firebase_uid;

                                roleId = listUsers
                                    .where((userData) =>
                                        userData.firebase_uid ==
                                        firebaseUIDValue)
                                    .toList()[0]
                                    .role;

                                String receiverPhone = listUsers
                                    .where((userData) =>
                                        userData.firebase_uid ==
                                        firebaseUIDValue)
                                    .toList()[0]
                                    .phone;

                                setSession(
                                    "message_session_id", messageSessionId);
                                setSession("messageId", messageId);
                                setSession(
                                    "is_client_request", isClientRequest);
                                setSession("receiver_phone", receiverPhone);
                                setSession("receiverId",
                                    receiverID); // reply to sender (user), receiverId will be the previous userSenderId value
                                setSession("receiverName", receiverName ?? "");
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return roleId == "1"
                                      ? UserMainMenu(
                                          selectedInitIndex: 3,
                                          subSelectedInitIndex: 7)
                                      : InstructorMainMenu(
                                          selectedInitIndex: 1,
                                          subSelectedInitIndex: 7);
                                }));
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 20),
                                margin:
                                    const EdgeInsets.only(bottom: 5, top: 5),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.withOpacity(0.3),
                                            width: 1))),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          margin: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(70),
                                              color: Colors.grey),
                                          child: ClipOval(
                                              child: Image.network(
                                                  height: 70,
                                                  width: 70,
                                                  profileImage ?? "",
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      StackTrace) {
                                            return Center(
                                                child: Icon(Icons.person));
                                          }, loadingBuilder: (context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Center(
                                                  child: CircularProgressIndicator(
                                                      value: loadingProgress !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              (loadingProgress
                                                                      .expectedTotalBytes ??
                                                                  1)
                                                          : null));
                                            }
                                          }))),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(receiverName,
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(messagesData.message_content,
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400))
                                            ]),
                                      ),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
                                              child: Icon(Icons.circle_rounded,
                                                  color: Colors.purpleAccent,
                                                  size: 16),
                                            ),
                                            SizedBox(height: 7),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Text(
                                                  messagesData.date_time,
                                                  style: TextStyle(
                                                      fontSize: 7,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            )
                                          ])
                                    ]),
                              ),
                            ),
                          );
                        });
                  }),
            ),
          ],
        )));
  }
}
