import 'package:chat_how/models/user_profile.dart';
import 'package:chat_how/pages/chat_page.dart';
import 'package:chat_how/services/alert_service.dart';
import 'package:chat_how/services/auth_service.dart';
import 'package:chat_how/services/database_service.dart';
import 'package:chat_how/widgets/chat_tile.dart';
import 'package:chat_how/services/naviagation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;

  late NavigationService _navigationService;
  late AuthService _authService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt<NavigationService>();
    _authService = _getIt<AuthService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            color: Colors.red,
            onPressed: () async {
              bool result = await _authService.logout();
              if (result) {
                _alertService.showToast(
                    text: "Successfully logged out", icon: Icons.check);
                _navigationService.pushReplacementNamed("/login");
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: _chatsList(),
      ),
    );
  }

  Widget _chatsList() {
    return StreamBuilder(
      stream: _databaseService.getUsersProfile(),
      builder: (context, snapshots) {
        final users = snapshots.data?.docs;
        if (snapshots.hasError) {
          return const Center(
            child: Text("Unable to Load Data"),
          );
        }

        if (snapshots.hasData && snapshots.data != null && users != null) {
          return ListView.builder(
            itemBuilder: (context, index) {
              UserProfile user = users[index].data();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ChatTile(
                  onTap: () async {
                    final chatExist = await _databaseService.checkChatExist(
                        _authService.user!.uid, user.uid!);

                    if (!chatExist) {
                      await _databaseService.createNewChat(
                          _authService.user!.uid, user.uid!);
                    }
                    _navigationService
                        .push(MaterialPageRoute(builder: (context) {
                      return ChatPage(chatUser: user);
                    }));
                  },
                  userProfile: user,
                ),
              );
            },
            itemCount: users.length,
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
