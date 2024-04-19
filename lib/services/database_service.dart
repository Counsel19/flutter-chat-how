import 'package:chat_how/models/chat.dart';
import 'package:chat_how/models/message.dart';
import 'package:chat_how/models/user_profile.dart';
import 'package:chat_how/services/auth_service.dart';
import 'package:chat_how/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference? _usersCollection;
  CollectionReference? _chatCollection;

  late AuthService _authService;
  final GetIt _getIt = GetIt.instance;

  DatabaseService() {
    _authService = _getIt<AuthService>();
    setUpCollectionReferences();
  }

  void setUpCollectionReferences() {
    _usersCollection =
        _firebaseFirestore.collection("users").withConverter<UserProfile>(
              fromFirestore: (snapshots, _) => UserProfile.fromJson(
                snapshots.data()!,
              ),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
    _chatCollection =
        _firebaseFirestore.collection("chats").withConverter<Chat>(
              fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
              toFirestore: (chat, _) => chat.toJson(),
            );
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUsersProfile() {
    return _usersCollection
        ?.where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExist(String uid1, String uid2) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);

    final result = await _chatCollection?.doc(chatId).get();

    if (result != null) {
      return result.exists;
    }

    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);

    final docRef = _chatCollection!.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid1, uid2], messages: []);

    await docRef.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);

    final docRef = _chatCollection!.doc(chatId);

    await docRef.update({
      "messages": FieldValue.arrayUnion([message.toJson()])
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);

    return _chatCollection!.doc(chatId).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
