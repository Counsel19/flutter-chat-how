import 'dart:io';

import 'package:chat_how/models/chat.dart';
import 'package:chat_how/models/message.dart';
import 'package:chat_how/models/user_profile.dart';
import 'package:chat_how/services/auth_service.dart';
import 'package:chat_how/services/database_service.dart';
import 'package:chat_how/services/media_service.dart';
import 'package:chat_how/services/storage_service.dart';
import 'package:chat_how/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:dash_chat_2/dash_chat_2.dart";
import 'package:get_it/get_it.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatUser? currentUser, otherUser;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  final GetIt _getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _authService = _getIt<AuthService>();
    _databaseService = _getIt<DatabaseService>();
    _mediaService = _getIt<MediaService>();
    _storageService = _getIt<StorageService>();

    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(
        id: widget.chatUser.uid!,
        firstName: widget.chatUser.name,
        profileImage: widget.chatUser.pfpURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUser.name!),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
        stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context, snapshot) {
          Chat? chat = snapshot.data?.data(); 
          List<ChatMessage> messages = [];

          if (chat != null && chat.messages != null) {
            messages = _generateChatMessageList(chat.messages!);
          }

          return DashChat(
              inputOptions: InputOptions(
                  alwaysShowSend: true, trailing: [_mediaMessageBtn()]),
              messageOptions: const MessageOptions(
                  showOtherUsersAvatar: true, showTime: true),
              currentUser: currentUser!,
              onSend: (message) {
                _sendMessage(message);
              },
              messages: messages);
        });
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias?.first.type == MediaType.image) {
        Message message = Message(
          senderId: currentUser!.id,
          content: chatMessage.medias?.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );

        await _databaseService.sendChatMessage(
            currentUser!.id, otherUser!.id, message);
      }
    } else {
      Message message = Message(
        senderId: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );

      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);
    }
  }

  List<ChatMessage> _generateChatMessageList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((message) {
      return ChatMessage(
        user: message.senderId == currentUser!.id ? currentUser! : otherUser!,
        text: message.messageType == MessageType.Text ? message.content! : "",
        medias: message.messageType == MessageType.Image
            ? [
                ChatMedia(
                    url: message.content!, fileName: "", type: MediaType.image)
              ]
            : [],
        createdAt: message.sentAt!.toDate(),
      );
    }).toList();

    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });

    return chatMessages;
  }

  Widget _mediaMessageBtn() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGalary();
        if (file != null) {
          String? downloadURL = await _storageService.uploadImageToChat(
            file: file,
            chatId: generateChatId(uid1: currentUser!.id, uid2: otherUser!.id),
          );

          if (downloadURL != null) {
            ChatMessage chatMessage = ChatMessage(
                user: currentUser!,
                createdAt: DateTime.now(),
                medias: [
                  ChatMedia(
                      url: downloadURL, fileName: "", type: MediaType.image)
                ]);

            _sendMessage(chatMessage);
          }
        }
      },
      icon: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
