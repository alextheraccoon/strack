import 'package:flutter/material.dart';

typedef void MyFormCallback(String result);
class AgeForm extends StatefulWidget {
  final MyFormCallback onSubmit;

  AgeForm({this.onSubmit});

  @override
  _AgeFormState createState() => _AgeFormState();
}

class _AgeFormState extends State<AgeForm> {
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
              value: "10-19",
            ),
            Text("10-19"),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              onChanged: (value) => setState(() => this.value = value),
              value: "20-29",
            ),
            Text("20-29"),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              onChanged: (value) => setState(() => this.value = value),
              value: "30-39",
            ),
            Text("30-39"),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              onChanged: (value) => setState(() => this.value = value),
              value: "40-49",
            ),
            Text("40-49"),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              onChanged: (value) => setState(() => this.value = value),
              value: "50-59",
            ),
            Text("50-59"),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              onChanged: (value) => setState(() => this.value = value),
              value: "+60",
            ),
            Text("+60"),
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