import 'dart:ffi';

import 'package:firestoreuser/widget/PayPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityPage extends StatefulWidget {
  ActivityPage({super.key, required this.stdId});
  String stdId;
  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String? docId;
  String? price;
  String? status;
  String? sets;
  CollectionReference activity =
      FirebaseFirestore.instance.collection("activity");

  Future<String> getUser(String id) async {
    String? statusIn;
    CollectionReference user = FirebaseFirestore.instance.collection("account");
    await user
        .where("ac_id", isEqualTo: id)
        .where('id', isEqualTo: widget.stdId)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        status = element['status'];
      });
    });
    return status!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: activity.orderBy("date", descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.lightBlue),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () async {
                              FirebaseFirestore.instance
                                  .collection("account")
                                  .where("ac_id",
                                      isEqualTo: snapshot.data!.docs[index].id)
                                  .where("id", isEqualTo: widget.stdId)
                                  .get()
                                  .then((value) {
                                for (var element in value.docs) {
                                  print(element.id);
                                  setState(() {
                                    docId = element.id;
                                    price = element['price'];
                                  });
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PayPage(
                                              stdId: docId.toString(),
                                              price: price.toString(),
                                            )));
                              });
                            },
                            trailing: FutureBuilder(
                                future: getUser(snapshot.data!.docs[index].id),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> text) {
                                  return Icon(
                                    Icons.monetization_on_rounded,
                                    color: text.data == "active"
                                        ? Colors.green
                                        : text.data == 'inactive'
                                            ? Colors.red
                                            : text.data == 'wait'
                                                ? Colors.amber
                                                : Colors.redAccent,
                                    size: 35,
                                  );
                                }),
                            title: Text(
                              "${snapshot.data?.docs[index].get("acname")}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "จำนวนเงิน/คน ${snapshot.data?.docs[index].get("price")} บาท",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                Text(
                                  "เรียกเก็บเมื่อวันที่ ${snapshot.data?.docs[index].get("date")}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              });
        });
  }
}
