import 'package:firestoreuser/models/UsersModels.dart';
import 'package:firestoreuser/widget/Homepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? stdId;
  UserModels users = UserModels();
  final login = GlobalKey<FormState>();
  bool isload = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: isload
              ? CircularProgressIndicator()
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: const Color.fromARGB(132, 0, 0, 0),
                              offset: Offset(5, 5))
                        ]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 90.0,
                        width: 90.0,
                      ),
                    ),
                  ),
                  Form(
                      key: login,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        child: Column(
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.number,
                              onSaved: (String? id) {
                                users.id = id;
                              },
                              decoration:
                                  InputDecoration(label: Text("รหัสนักศึกษา")),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                                height: 40,
                                width: 300,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    login.currentState?.save();

                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .where("id", isEqualTo: users.id)
                                        .get()
                                        .then((value) {
                                      if (value.docs.isEmpty) {
                                        setState(() {
                                          isload = true;
                                        });
                                        AlertDialog alert = const AlertDialog(
                                          title: Column(children: [
                                            Icon(
                                              Icons.close_rounded,
                                              size: 50,
                                              color: Colors.redAccent,
                                            ),
                                            Text("เข้าสู่ระบบไม่สำเร็จ")
                                          ]),
                                        );
                                        setState(() {
                                          isload = false;
                                        });
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          },
                                        );
                                        return;
                                      }
                                      if (value.docs.isNotEmpty) {
                                        setState(() {
                                          isload = true;
                                        });
                                        for (var id in value.docs) {
                                          setState(() {
                                            stdId = id['id'];
                                          });
                                        }
                                        setState(() {
                                          isload = false;
                                        });

                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                      stdId: stdId.toString(),
                                                    )));
                                      }
                                    });
                                  },
                                  child: Text("เข้าสู่ระบบ"),
                                ))
                          ],
                        ),
                      ))
                ])),
    );
    ;
  }
}
