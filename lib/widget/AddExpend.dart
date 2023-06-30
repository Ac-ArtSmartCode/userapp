import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firestoreuser/models/ActivityModels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Expand extends StatefulWidget {
  Expand({super.key, required this.stdId});
  String stdId;

  @override
  State<Expand> createState() => _ExpandState();
}

class _ExpandState extends State<Expand> {
  bool isLoad = false;
  PlatformFile? image;
  UploadTask? uploadTask;
  String? imageUrl;
  final formKey = GlobalKey<FormState>();
  final ActivityModels activityModels = ActivityModels();

  Future selectFile() async {
    final img = await FilePicker.platform.pickFiles();
    if (img == null) return;
    setState(() {
      image = img.files.first;
    });
  }

  String? fullname;
  void initState() {
    super.initState();
    getUser();
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
        });
      }
    });
  }

  Future uploadImage() async {
    if (image == null) return;
    final path = "slips/${image?.name}";
    final file = File(image!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask?.whenComplete(() {});
    final imgUrl = await snapshot!.ref.getDownloadURL();
    setState(() {
      imageUrl = imgUrl.toString();
    });
    var now = DateTime.now();
    var dfm = DateFormat('dd-MM-yyyy');
    String dateFormat = dfm.format(now);

    await FirebaseFirestore.instance.collection("expenses").add({
      "acname": activityModels.acName,
      "price": activityModels.price,
      "date": dateFormat,
      "detail": activityModels.detail,
      "by": fullname,
      "slips": imageUrl,
      "status": "inactive",
      "id": widget.stdId
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ขอเบิก")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoad
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration:
                          InputDecoration(label: Text("ชื่อรายการขอเบิก")),
                      onSaved: (String? acName) {
                        activityModels.acName = acName;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(label: Text("จำนวนเงินที่ขอเบิก")),
                      onSaved: (String? price) {
                        double p = double.parse(price!);
                        String total = p.toStringAsFixed(2);
                        activityModels.price = total;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          label: Text("รายระเอียดรายการขอเบิก")),
                      onSaved: (String? detail) {
                        activityModels.detail = detail;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white)),
                          onPressed: selectFile,
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.lightBlue,
                          )),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          formKey.currentState?.save();
                          if (image == null) {
                            setState(() {
                              isLoad = true;
                            });
                            AlertDialog alert = const AlertDialog(
                              title: Column(children: [
                                Icon(
                                  Icons.close_rounded,
                                  size: 50,
                                  color: Colors.redAccent,
                                ),
                                Text("สร้างรายการไม่สำเร็จ")
                              ]),
                            );
                            setState(() {
                              isLoad = false;
                            });
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          } else {
                            setState(() {
                              isLoad = true;
                            });
                            await uploadImage();
                            setState(() {
                              isLoad = false;
                            });
                            AlertDialog alert = const AlertDialog(
                              title: Column(children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 50,
                                  color: Colors.greenAccent,
                                ),
                                Text("สร้างรายการสำเร็จ")
                              ]),
                            );
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          }
                        },
                        child: Text("สร้างรายการขอเบิก"))
                  ],
                )),
      ),
    );
  }
}
