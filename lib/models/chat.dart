import 'package:chat_how/models/message.dart';

class Chat {
  String? id;
  List<String>? participants;
  List<Message>? messages;

  Chat({required this.id, required this.participants, required this.messages});

  Chat.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    participants = List<String>.from(json["participants"]);
    messages = List.from(json["messages"])
        .map((item) => Message.fromJson(item))
        .toList();
  }

  // .map((item) => Message.fromJson(item))

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["participants"] = participants;
    data["messages"] = messages;

    return data;
  }
}
