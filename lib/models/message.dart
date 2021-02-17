import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageID;
  final String senderID;
  final String userName;
  final String messageBody;
  final String clubID;
  final String type;
  final sendTime;

  Message(
      {this.messageID,
      this.senderID,
      this.userName,
      this.messageBody,
      this.clubID,
      this.type,
      this.sendTime});

  static Message fromDocument(DocumentSnapshot documentSnapshot) {
    return Message(
      messageID: documentSnapshot.data()['messageID'],
      senderID: documentSnapshot.data()['senderID'],
      userName: documentSnapshot.data()['userName'],
      messageBody: documentSnapshot.data()['messageBody'],
      type: documentSnapshot.data()['type'],
      clubID: documentSnapshot.data()['clubID'],
      sendTime: documentSnapshot.data()['sendTime'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'messageID': messageID,
      'senderID': senderID,
      'userName': userName,
      'messageBody': messageBody,
      'clubID': clubID,
      'type': type,
      'sendTime': Timestamp.now(),
    };
    return map;
  }
}
