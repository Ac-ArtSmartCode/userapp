import 'package:firestoreuser/widget/ActivityPage.dart';
import 'package:firestoreuser/widget/ExpandPage.dart';
import 'package:firestoreuser/widget/NotiPage.dart';
import 'package:firestoreuser/widget/RoomPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.stdId});
  String stdId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? std;
  String? fullname;
  double money = 0;
  double expens = 0;
  double exTotal = 0;
  double exRoom = 0;
  double result = 0;
  String? profile;
  double room = 0;
  Future<void> getExpenses() async {
    CollectionReference expenses =
        FirebaseFirestore.instance.collection("expenses");
    await expenses.get().then((value) {
      for (var element in value.docs) {
        expens = double.parse(element.get("price"));
        if (mounted) {
          setState(() {
            element.get("status") == "room"
                ? exRoom += expens
                : element.get("status") == "active"
                    ? exTotal += expens
                    : 0;
          });
        }
      }
    });
  }

  Future<void> getTotal() async {
    CollectionReference price =
        FirebaseFirestore.instance.collection("account");

    await price.get().then((value) {
      for (var element in value.docs) {
        if (element.exists) {
          money = double.parse(element['price']);
          if (mounted) {
            setState(() {
              element['room'] ? room += money : result += money;
            });
          }
        }
      }
    });
  }

  void initState() {
    super.initState();

    getTotal();
    getExpenses();
    getUser();
    setState(() {
      std = widget.stdId.toString();
    });
  }

  int? _select = 0;
  late List<Widget> page = [
    ActivityPage(
      stdId: "$std",
    ),
    RoomPage(
      stdId: "$std",
    ),
    ExpandPage(
      stdId: "$std",
    )
  ];
  void setPage(int index) {
    setState(() {
      _select = index;
    });
  }

  Future getUser() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where("id", isEqualTo: widget.stdId)
        .get()
        .then((value) {
      for (var element in value.docs) {
        setState(() {
          fullname = "${element['first_name']}  ${element['last_name']}";
          profile = element.get("profile");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text(
          "เหลือ${NumberFormat('#,###.##').format((room + result) - (exRoom + exTotal))}บาท",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.notifications_active),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotiPage(
                          stdId: widget.stdId,
                          activity: result,
                          expenses: exTotal,
                          room: room,
                        )));
          },
        ),
        actions: [
          Container(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$fullname",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${widget.stdId}",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(4.0),
                  child: profile == null
                      ? CircleAvatar(
                          child: Icon(Icons.person),
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(profile.toString()),
                        ))
            ]),
          )
        ],
      ),
      body: page.elementAt(_select!),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'กิจกรรม',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'เบิกรายจ่าย',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.price_change_outlined),
            label: 'รายจ่าย',
          ),
        ],
        currentIndex: _select!,
        onTap: setPage,
      ),
    );
  }
}
