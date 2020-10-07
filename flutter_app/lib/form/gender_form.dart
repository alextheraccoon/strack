import 'package:flutter/material.dart';

typedef void MyFormCallback(String result);
class GenderForm extends StatefulWidget {
  final MyFormCallback onSubmit;

  GenderForm({this.onSubmit});

  @override
  _GenderFormState createState() => _GenderFormState();
}

class _GenderFormState extends State<GenderForm> {
  String value = "";
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("My form"),
      children: <Widget>[
        Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              onChanged: (value) => setState(() => this.value = value),
              value: "F",
            ),
            Text("Female"),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              onChanged: (value) => setState(() => this.value = value),
              value: "M",
            ),
            Text("Male"),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              onChanged: (value) => setState(() => this.value = value),
              value: "Other",
            ),
            Text("Other"),
          ],
        ),
        FlatButton(
          onPressed: () {
            if (this.value != ""){
              widget.onSubmit(value);
              Navigator.pop(context);
            }
          },
          child: new Text("Submit"),
        )
      ],
    );
  }
}