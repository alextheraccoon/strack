import 'package:flutter/material.dart';
import 'package:flutterapp/form/dialog/switchDrive_dialog.dart';
import 'package:flutterapp/form/dialog/googleDrive_dialog.dart';
import 'package:flutterapp/form/dialog/dropbox_dialog.dart';

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
    var _dialog = new DropboxDialog(onSubmit: widget.onSubmit);
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => _dialog
    );
  }

@override
  Widget build(BuildContext context) {

  final _switchDriveButton = FlatButton(
    onPressed: () {_uploadSwitch();},
    textColor: Colors.white,
    padding: const EdgeInsets.all(0.0),
    child: Container(
      width: 250,
        color: Colors.white,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              child: Image.asset('assets/images/switchDriveIcon.png'),
            ),
            new SizedBox(width: 20,),
            const Text('Switch Drive', style: TextStyle(fontSize: 25, color: Colors.black)),
        ],
      )
    ),
  );

  final _googleDriveButton = FlatButton(
      onPressed: () {_uploadGoogle();},
    textColor: Colors.white,
    padding: const EdgeInsets.all(0.0),
    child: Container(
        width: 250,
        color: Colors.white,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              child: Image.asset('assets/images/googleDriveIcon.png'),
            ),
            new SizedBox(width: 20,),
            const Text('Google Drive', style: TextStyle(fontSize: 25, color: Colors.black)),
          ],
        )
    ),
  );

  final _dropboxButton = FlatButton(
    onPressed: () {_uploadDropBox();},
    textColor: Colors.white,
    padding: const EdgeInsets.all(0.0),
    child: Container(
        width: 250,
        color: Colors.white,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Container(
                alignment: Alignment(0.0, 0.0),
                width: 50,
                height: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Image.asset('assets/images/dropboxIcon.png')],),
              ),
            ),

            new SizedBox(width: 20,),
            const Text('Dropbox', style: TextStyle(fontSize: 25, color: Colors.black)),
          ],
        )
    ),
  );


    return SimpleDialog(
      title: Text("Choose where to upload your data:"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      contentPadding: EdgeInsets.fromLTRB(5, 30, 0, 20),
      children: <Widget>[
        Center(
          child: Container(
            height: 300,
            width: 250,
            alignment: Alignment(0.0, 0.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Divider(height: 20.0, color: Colors.grey),
                  _switchDriveButton,
                  new Divider(height: 20.0, color: Colors.grey),
                  _googleDriveButton,
                  new Divider(height: 20.0, color: Colors.grey),
                  _dropboxButton,
                  new Divider(height: 20.0, color: Colors.grey),
                ]
            ),
          ),
        )

      ],
    );
  }
}