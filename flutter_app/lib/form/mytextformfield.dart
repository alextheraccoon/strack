import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final Function validator;
  final Function onSaved;
  final bool isPassword;
  final bool isEmail;


  MyTextFormField({
    this.hintText,
    this.validator,
    this.onSaved,
    this.isPassword = false,
    this.isEmail = false,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column (
        children: <Widget>[
          new Container(
            height: 10,
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: EdgeInsets.all(8.0),
              fillColor: Colors.white70,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(30.0),
                borderSide: new BorderSide(),
              ),
              filled: true,
            ),
            obscureText: isPassword ? true : false,
            validator: validator,
            onSaved: onSaved,
            keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          ),
        ],
      ),
    );

  }
}