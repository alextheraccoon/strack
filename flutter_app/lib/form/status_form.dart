import 'package:flutter/material.dart';

typedef void MyFormCallback(String result);
class StatusForm extends StatefulWidget {
  final MyFormCallback onSubmit;

  StatusForm({this.onSubmit});

  @override
  _StatusFormState createState() => _StatusFormState();
}

class _StatusFormState extends State<StatusForm> {
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
              value: "High School Student",
            ),
            Text("High School Student"),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              onChanged: (value) => setState(() => this.value = value),
              value: "University Student",
            ),
            Text("University Student"),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              onChanged: (value) => setState(() => this.value = value),
              value: "Intern",
            ),
            Text("Intern"),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              groupValue: value,
              onChanged: (value) => setState(() => this.value = value),
              value: "Worker",
            ),
            Text("Worker"),
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