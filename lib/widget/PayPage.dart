import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class PayPage extends StatefulWidget {
  PayPage({super.key, required this.stdId, required this.price});
  String stdId;
  String price;

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  PlatformFile? image;
  Image? img;
  UploadTask? uploadTask;
  String? imageUrl;
  bool isLoad = false;
  Future selectFile() async {
    final img = await FilePicker.platform.pickFiles();
    if (img == null) return;
    setState(() {
      image = img.files.first;
    });
  }

  Future getPay(String price) async {
    var url = "https://promptpay.io/0614948855/$price";
    return url;
  }

  void initState() {
    super.initState();
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
    await FirebaseFirestore.instance
        .collection("account")
        .doc(widget.stdId)
        .update({"status": "wait", "slips": imageUrl});
  }

  CollectionReference upload = FirebaseFirestore.instance.collection('account');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ชำระเงิน")),
      body: Center(
          child: isLoad
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder(
                        future: getPay(widget.price),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> text) {
                          return Image.network(
                            text.data ??
                                "https://promptpay.io/0614948855/${widget.price}",
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return CircularProgressIndicator();
                            },
                            fit: BoxFit.cover,
                          );
                        }),
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
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                        height: 40,
                        width: 200,
                        child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoad = true;
                              });
                              await uploadImage();
                              AlertDialog alert = AlertDialog(
                                title: Column(children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 50,
                                    color: Colors.greenAccent,
                                  ),
                                  Text("อัพโหลดสำเร็จ")
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
                            },
                            child: Text("อัพโหลดสลีป")))
                  ],
                )),
    );
  }
}
