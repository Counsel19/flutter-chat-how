import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import "package:path/path.dart" as pth;

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  StorageService() {}

  Future<String?> uploadUserPfp(
      {required File file, required String uid}) async {
    Reference fileRef = _firebaseStorage
        .ref("users/pfps")
        .child("$uid${pth.extension(file.path)}");

    UploadTask task = fileRef.putFile(file);

    return task.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }

  Future<String?> uploadImageToChat(
      {required File file, required String chatId}) async {
    Reference fileRef = _firebaseStorage.ref("chats/$chatId").child(
        '${DateTime.now().toIso8601String()}${pth.extension(file.path)}');

    UploadTask task = fileRef.putFile(file);

    return task.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }
}
