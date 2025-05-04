import 'package:flutter/material.dart';
import 'package:fitup/components/textFieldSearchGymCustom.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/classes/GymNames.dart';
import 'package:fitup/services/storage.service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserSelectNearestGymPartner extends StatefulWidget {
  const UserSelectNearestGymPartner({super.key});

  @override
  State<UserSelectNearestGymPartner> createState() =>
      _userSelectNearestGymPartnerState();
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

Stream<List<GymNames>> getGymNames() {
  final databaseRef = FirebaseDatabase.instance.ref('gym_names');
  List<GymNames> listGymNames = [];

  return databaseRef.onValue.map((event) {
    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((id, data) {
      listGymNames.add(GymNames(
          gym_id: data['json'] ?? "",
          gym_name: data['gym_name'] ?? "",
          gym_photo_url: data['gym_photo_url'] ?? "",
          address: data['address'] ?? "",
          email: data['email'] ?? "",
          gym_phone: data['gym_phone'] ?? "",
          is_active: data['is_active'] ?? "",
          is_deleted: data['is_deleted'] ?? "",
          last_updated_by: data['last_updated_by'] ?? "",
          added_by: data['added_by'] ?? "",
          date_time_added: data['date_time_added'] ?? "",
          date_time_last_updated: data['date_time_last_updated'] ?? ""));
    });

    return listGymNames;
  });
} // getGymNames

class _userSelectNearestGymPartnerState
    extends State<UserSelectNearestGymPartner> {
  final textSearchGym = new TextEditingController();
  String? trainingVenue;

  void initState() {
    super.initState();
    getGymPartnerLogoImages();
    getTrainingVenue();
  }

  Future<void> getTrainingVenue() async {
    String? trainingVenueTemp = await getSession("training_venue");
    setState(() {
      trainingVenue = trainingVenueTemp;
    });
  } // getTrainingVenue

  Future<void> getGymPartnerLogoImages() async {
    Provider.of<StorageService>(context, listen: false).getPartnerLogos();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      SizedBox(height: 15),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              margin: const EdgeInsets.only(left: 5),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return const UserMainMenu(
                          selectedInitIndex: 1, subSelectedInitIndex: 21);
                    }));
                  },
                  child: Container(
                      child: Icon(Icons.arrow_back,
                          color: Color.fromARGB(199, 118, 10, 160)),
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  const Color.fromARGB(199, 118, 10, 160)))))),
          Center(child: Text("Training Setup: $trainingVenue")),
          Container(
            child: Icon(Icons.arrow_back, color: Colors.transparent),
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
          )
        ],
      ),
      Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: Offset(0, 0))
            ],
          ),
          child: TextFieldSearchGymCustom(
              textController: textSearchGym,
              obscure_text: false,
              hint_text_value: "Search Gym Partner Near You",
              iconPrefix: const Icon(Icons.search, color: Colors.black87),
              iconSuffix: const Icon(Icons.clear, color: Colors.black87))),
      SizedBox(height: 15),
      Container(
          height: MediaQuery.of(context).size.height * 0.60,
          child: StreamBuilder(
              stream: getGymNames(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Something went wrong, try again"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        childAspectRatio: 2.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index];

                      String urlImage = data.gym_photo_url;
                      String gymId = data.gym_id;
                      String gymName = data.gym_name;

                      return GestureDetector(
                        onTap: () {
                          setSession("gym_id", gymId);
                          setSession("gym_name", gymName);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return const UserMainMenu(
                                selectedInitIndex: 1, subSelectedInitIndex: 23);
                          }));
                        },
                        child: Container(
                            height: 50,
                            width: 50,
                            child: Image.network(urlImage)),
                      );
                    });
              }))
    ])));
  }
}
