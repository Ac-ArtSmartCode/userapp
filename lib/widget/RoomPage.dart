import 'package:firestoreuser/widget/AddExpend.dart';
import 'package:firestoreuser/widget/ExpensesDetail.dart';
import 'package:firestoreuser/widget/UpdateExpense.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomPage extends StatefulWidget {
  RoomPage({super.key, required this.stdId});
  String stdId;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

CollectionReference expenses =
    FirebaseFirestore.instance.collection("expenses");

class _RoomPageState extends State<RoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: expenses.where("id", isEqualTo: widget.stdId).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('ไม่พบข้อมูลขอเบิก'));
              }
              if (snapshot.hasData) {
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
                                  color: snapshot.data!.docs[index]
                                              .get("status") ==
                                          "active"
                                      ? Colors.green
                                      : Colors.amber,
                                  borderRadius: BorderRadius.circular(20)),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ExpensesDetail(
                                                acname: snapshot
                                                    .data?.docs[index]
                                                    .get("acname"),
                                                price: snapshot
                                                    .data?.docs[index]
                                                    .get("price"),
                                                detail: snapshot
                                                    .data?.docs[index]
                                                    .get("detail"),
                                                image: snapshot
                                                        .data?.docs[index]
                                                        .get("slips") ??
                                                    "",
                                                by: snapshot.data?.docs[index]
                                                    .get("by"),
                                              )));
                                },
                                title: Text(
                                  "${snapshot.data!.docs[index]['acname']}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "ขอเบิกเมื่อวันที่  ${snapshot.data!.docs[index]['date']}"),
                                      Text(
                                        "จำนวนเงิน ${snapshot.data!.docs[index]['price']} บาท",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ]),
                                leading: Icon(
                                  Icons.watch_outlined,
                                  size: 30,
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => UpdateExpense(
                                                acname: snapshot.data!
                                                    .docs[index]['acname'],
                                                price: snapshot
                                                    .data!.docs[index]['price'],
                                                detail: snapshot.data!
                                                    .docs[index]['detail'],
                                                image: snapshot.data!
                                                        .docs[index]['slips'] ??
                                                    "",
                                                by: snapshot
                                                    .data!.docs[index].id)));
                                  },
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
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Expand(
                          stdId: widget.stdId,
                        )));
          },
        ));
  }
}
