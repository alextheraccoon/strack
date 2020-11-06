import 'package:flutter/material.dart';
import 'package:flutterapp/form/dialog/switchDrive_dialog.dart';
import 'package:flutterapp/form/dialog/googleDrive_dialog.dart';

typedef void MyFormCallback(bool result);

class PlatformDialog extends StatefulWidget {

  final MyFormCallback onSubmit;

  PlatformDialog({this.onSubmit});

  @override
  PlatformDialogState createState() => PlatformDialogState();
}

class PlatformDialogState extends State<PlatformDialog>{
  bool switchDrive = false;
  bool googleDrive = false;
  bool dropbox = false;


  _uploadSwitch(){
    var _dialog = new SwitchDriveDialog(onSubmit: widget.onSubmit);
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => _dialog
    );

  }

  _uploadGoogle(){
    var _dialog = new GoogleDriveDialog(onSubmit: widget.onSubmit);
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => _dialog
    );

  }

  _uploadDropBox(){

  }

@override
  Widget build(BuildContext context) {

  final _switchDriveButton = FlatButton(
    onPressed: () {_uploadSwitch();},
    textColor: Colors.white,
    padding: const EdgeInsets.all(0.0),
    child: Container(
      alignment: Alignment.center,
      color: Colors.white,
      padding: const EdgeInsets.all(10.0),
      child:
      const Text('Switch Drive', style: TextStyle(fontSize: 20, color: Colors.black)),
    ),
  );

  final _googleDriveButton = FlatButton(
      onPressed: () {_uploadGoogle();},
      textColor: Colors.white,
      padding: const EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
        color: Colors.white,
        padding: const EdgeInsets.all(10.0),
        child:
        const Text('Google Drive', style: TextStyle(fontSize: 20, color: Colors.black)),
      ),
  );

  final _dropboxButton = FlatButton(
    onPressed: () {_uploadDropBox();},
    textColor: Colors.white,
    padding: const EdgeInsets.all(0.0),
    child: Container(
      alignment: Alignment.center,
      color: Colors.white,
      padding: const EdgeInsets.all(10.0),
      child:
      const Text('Dropbox', style: TextStyle(fontSize: 20, color: Colors.black)),
    ),
  );


    return SimpleDialog(
      title: Text("Choose where to upload your data"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      contentPadding: EdgeInsets.fromLTRB(5, 30, 0, 20),
      children: <Widget>[
        Container(
          height: 300,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 30),
                _switchDriveButton,
                const SizedBox(height: 30),
                _googleDriveButton,
                const SizedBox(height: 30),
                _dropboxButton
              ]
          ),
        )
      ],
    );
  }
}