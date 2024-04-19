
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message{
  String? senderId;
  String? content;
  MessageType? messageType;
  Timestamp? sentAt;

  Message({ 
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.sentAt
  });

  Message.fromJson(Map<String, dynamic> json){
    senderId = json["senderId"];
    content = json["content"];
    messageType = MessageType.values.byName(json["messageType"]);
    sentAt = json["sentAt"];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};

    data["senderId"] = senderId;
    data["content"] = content;
    data["messageType"] = messageType!.name;
    data["sentAt"] = sentAt;

    return data;
  }
}