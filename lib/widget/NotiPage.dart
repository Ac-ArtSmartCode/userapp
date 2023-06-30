import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotiPage extends StatefulWidget {
  NotiPage(
      {super.key,
      required this.activity,
      required this.room,
      required this.expenses,
      required this.stdId});
  double room;
  double expenses;
  String stdId;

  double activity;

  @override
  State<NotiPage> createState() => _NotiPageState();
}

class _NotiPageState extends State<NotiPage> {
  CollectionReference account =
      FirebaseFirestore.instance.collection("account");

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("การแจ้งเตือน")),
        body: StreamBuilder(
            stream: account.where("id", isEqualTo: widget.stdId).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color:
                                    snapshot.data!.docs[index].get("status") ==
                                            "wait"
                                        ? Colors.amber
                                        : snapshot.data!.docs[index]
                                                    .get("status") ==
                                                "active"
                                            ? Colors.green
                                            : snapshot.data!.docs[index]
                                                        .get("status") ==
                                                    "inactive"
                                                ? Colors.redAccent
                                                : Colors.black),
                            child: ListTile(
                              title: Text(
                                snapshot.data!.docs[index].get('room')
                                    ? "เงินห้อง"
                                    : "เงินกิจกรรม",
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: Text(
                                  snapshot.data!.docs[index].get("status") ==
                                          "wait"
                                      ? "รอดำเนินการ"
                                      : snapshot.data!.docs[index]
                                                  .get("status") ==
                                              "active"
                                          ? "ชำระเงินจำเร็จ"
                                          : snapshot.data!.docs[index]
                                                      .get("status") ==
                                                  "inactive"
                                              ? "ชำระเงินไม่สำเร็จ"
                                              : "ตรวจพบปัญหา",
                                  style: TextStyle(color: Colors.white)),
                            )),
                      );
                    });
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
