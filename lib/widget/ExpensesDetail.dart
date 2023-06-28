import 'package:firestoreuser/widget/ShowImage.dart';
import 'package:flutter/material.dart';

class ExpensesDetail extends StatefulWidget {
  ExpensesDetail(
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
  State<ExpensesDetail> createState() => _ExpensesDetailState();
}

class _ExpensesDetailState extends State<ExpensesDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("รายระเอียด")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: "${widget.acname}",
              decoration: InputDecoration(label: Text("ชื่อรายการขอเบิก")),
              readOnly: true,
              style: TextStyle(fontSize: 20),
            ),
            TextFormField(
              initialValue: "${widget.by}",
              decoration: InputDecoration(label: Text("ขอเบิกโดย")),
              readOnly: true,
              style: TextStyle(fontSize: 20),
            ),
            TextFormField(
              initialValue: "${widget.price} บาท",
              decoration: InputDecoration(label: Text("จำนวนเงินที่ขอเบิก")),
              readOnly: true,
              style: TextStyle(fontSize: 20),
            ),
            TextFormField(
              initialValue: "${widget.detail}",
              decoration: InputDecoration(label: Text("รายละเอียดการใช้จ่าย")),
              readOnly: true,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Text("กดเพื่อดูหลักฐาน", style: TextStyle(fontSize: 16)),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ShowImage(imgUrl: widget.image)));
                    },
                    icon: Icon(
                      Icons.image,
                      color: Colors.lightBlue,
                      size: 30,
                    ))
              ],
            )
          ],
        )),
      ),
    );
  }
}
