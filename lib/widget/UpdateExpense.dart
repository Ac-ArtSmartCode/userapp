import 'dart:io';
import 'dart:math';

import 'package:firestoreuser/models/ExpenesesModels.dart';
import 'package:firestoreuser/widget/ShowImage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateExpense extends StatefulWidget {
  UpdateExpense(
      {super.key,
      required this.acname,
      required this.price,
      required this.detail,
      required this.image,
      required this.by});
  String acname;
  String by;
  String price;
  String detail;
  String image;

  @override
  State<UpdateExpense> createState() => _UpdateExpenseState();
}

class _UpdateExpenseState extends State<UpdateExpense> {
  CollectionReference expenese =
      FirebaseFirestore.instance.collection("expenses");
  ExpenesesModels expenesesModels = ExpenesesModels();
  final formKey = GlobalKey<FormState>();
  PlatformFile? image;
  UploadTask? uploadTask;
  String? imageUrl;
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
  }

  Future selectFile() async {
    final img = await FilePicker.platform.pickFiles();
    if (img == null) return;
    setState(() {
      image = img.files.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("รายระเอียด")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
            child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                onSaved: (String? exName) {
                  expenesesModels.exName = exName;
                },
                initialValue: "${widget.acname}",
                decoration: InputDecoration(label: Text("ชื่อรายการขอเบิก")),
                style: TextStyle(fontSize: 20),
              ),
              TextFormField(
                onSaved: (String? price) {
                  double p = double.parse(price!);
                  String total = p.toStringAsFixed(2);
                  expenesesModels.price = total;
                },
                initialValue: "${widget.price} ",
                decoration: InputDecoration(label: Text("จำนวนเงินที่ขอเบิก")),
                style: TextStyle(fontSize: 20),
              ),
              TextFormField(
                onSaved: (String? detail) {
                  expenesesModels.detail = detail;
                },
                initialValue: "${widget.detail}",
                decoration:
                    InputDecoration(label: Text("รายละเอียดการใช้จ่าย")),
                style: TextStyle(fontSize: 20),
              ),
              Row(
                children: [
                  Text("เลือกรูปภาพ", style: TextStyle(fontSize: 16)),
                  IconButton(
                      onPressed: () {
                        selectFile();
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.lightBlue,
                        size: 30,
                      )),
                ],
              ),
              ElevatedButton(
                  onPressed: () async {
                    formKey.currentState?.save();

                    await uploadImage();
                    await expenese.doc(widget.by).update({
                      "acname": expenesesModels.exName,
                      "price": expenesesModels.price,
                      "detail": expenesesModels.detail,
                      "slips": imageUrl
                    });
                    Navigator.pop(context);
                  },
                  child: Text("แก้ไขรายการขอเบิก"))
            ],
          ),
        )),
      ),
    );
  }
}
