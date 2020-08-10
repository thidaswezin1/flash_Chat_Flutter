import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;
class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  String message;
  final messageTextController = TextEditingController();

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
                _auth.signOut();
                Navigator.pop(context);
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
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
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

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('messages').snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final messages = snapshot.data.documents.reversed;
          List<Widget> messageWidgets = [];
          for(var message in messages){
            final text = message.data['text'];
            final sender = message.data['sender'];
            final currentUser = loggedInUser.email;

            messageWidgets.add(
                MessageBubble(
                  text: text,
                  sender: sender,
                  isMe: currentUser==sender,)
            );
          }
          return Expanded(
            child: ListView(
              reverse: true,
              children: messageWidgets,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 20
              ),
            ),
          );
        }
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    @required this.text,
    @required this.sender,
    this.isMe
  });

  final String text;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black
            ),
          ),
          Material(
              elevation: 6.0,
              color: isMe?Colors.lightBlueAccent:Colors.white,
              borderRadius:
              isMe?BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)
              ):
              BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)
              ),
                child: Padding(
                   padding: const EdgeInsets.symmetric(
                       vertical: 10,horizontal: 30),
                    child: Text(
                          text,
                          style: TextStyle(
                            color: isMe?Colors.white:Colors.black
                         ),
                      ),
                  ),
           )
        ],
      ),
    );
  }
}
