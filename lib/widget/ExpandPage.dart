import 'package:firestoreuser/widget/AddExpend.dart';
import 'package:firestoreuser/widget/ExpensesDetail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpandPage extends StatefulWidget {
  ExpandPage({super.key, required this.stdId});
  String stdId;

  @override
  State<ExpandPage> createState() => _ExpandPageState();
}

CollectionReference expenses =
    FirebaseFirestore.instance.collection("expenses");

class _ExpandPageState extends State<ExpandPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream:
              expenses.where("status", isNotEqualTo: "inactive").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('ไม่พบข้อมูลรายจ่าย'));
            }
            if (snapshot!.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ExpensesDetail(
                                              acname: snapshot.data?.docs[index]
                                                  .get("acname"),
                                              price: snapshot.data?.docs[index]
                                                  .get("price"),
                                              detail: snapshot.data?.docs[index]
                                                  .get("detail"),
                                              image: snapshot.data?.docs[index]
                                                      .get("slips") ??
                                                  "",
                                              by: snapshot.data?.docs[index]
                                                  .get("by"),
                                            )));
                              },
                              title: Text(
                                "${snapshot.data!.docs[index]['acname']}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ขอเบิกเมื่อวันที่  ${snapshot.data!.docs[index]['date']}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "จำนวนเงิน -${snapshot.data!.docs[index]['price']} บาท",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ]),
                              leading: Icon(
                                Icons.outbound,
                                size: 30,
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  });
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
