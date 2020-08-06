import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _fireStore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String message;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{
    try{
      final _user = await _auth.currentUser();
      if(_user!=null){
        loggedInUser = _user;
      }
    } on Exception catch(e){
      print(e);
    }
  }
  void getMessage() async{
    final messages = await _fireStore.collection('messages').getDocuments();
    for(var message in messages.documents){
      print(message.data);
    }
  }

  void messageStream() async{
    await for(var snapshot in _fireStore.collection('messages').snapshots()){
      for(var message in snapshot.documents){
        print(message.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.lock_open),
              onPressed: () {
                //getMessage();
                messageStream();
                /*_auth.signOut();
                Navigator.pop(context);*/
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _fireStore.collection('messages').add(
                        {
                          'text':message,
                          'sender':loggedInUser.email
                        }
                      );
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
