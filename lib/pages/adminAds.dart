import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitup/classes/AdsClass.dart';
import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class AdminAds extends StatefulWidget {
  const AdminAds({super.key});

  State<AdminAds> createState() => _adminAdsState();
}

Stream<List<AdsClass>> getAds() {
  final List<AdsClass> list_ads = [];

  final databaseRef = FirebaseDatabase.instance.ref('ads');

  return databaseRef.onValue.map((event) {
    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);
    extractedData.forEach((dataId, json) {
      list_ads.add(AdsClass(
          ads_id: json['ads_id'],
          ads_image_url: json['ads_image_url'],
          ads_title: json['ads_title'],
          ads_description: json['ads_description'],
          date_time_added: json['date_time_added'],
          added_by: json['added_by'],
          date_time_last_updated: json['date_time_last_updated'],
          last_updated_by: json['last_updated_by'],
          status: json['status']));
    });

    list_ads.shuffle();

    return list_ads;
  });
} // getAds()

class _adminAdsState extends State<AdminAds> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: Icon(Icons.arrow_back_ios, color: Colors.transparent),
            centerTitle: true,
            title:
                Text("Ads on User Home Page", style: TextStyle(fontSize: 14))),
        body: SafeArea(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                  stream: getAds(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: const Text("Loading ..."));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: const CircularProgressIndicator());
                    }

                    final data = snapshot.data;

                    return Scaffold(
                      body: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final imageURL = data![index].ads_image_url;
                            String title = data![index].ads_title;
                            String description = data![index].ads_description;

                            return Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 20),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.withOpacity(0.1)),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                          child: Image.network(imageURL,
                                              loadingBuilder: (context,
                                                  Widget child,
                                                  ImageChunkEvent?
                                                      loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Container(
                                            margin: const EdgeInsets.all(10),
                                            child: Center(
                                                child: CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            (loadingProgress
                                                                    .expectedTotalBytes ??
                                                                1)
                                                        : null)),
                                          );
                                        }
                                      }, fit: BoxFit.cover)),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      Visibility(
                                                        visible: false,
                                                        child: Icon(
                                                            Icons.location_pin,
                                                            color:
                                                                Color.fromARGB(
                                                                    199,
                                                                    118,
                                                                    10,
                                                                    160)),
                                                      ),
                                                      Text(title,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ]),
                                                  ]),
                                              SizedBox(height: 8),
                                              Text(description,
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                              SizedBox(height: 8),
                                              Visibility(
                                                visible: false,
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text("Php 500/Day",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(
                                                          "Discounted if booked early",
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300)),
                                                    ]),
                                              ),
                                            ]),
                                      )
                                    ]));
                          }),
                    );
                  })),
        ));
  }
}
