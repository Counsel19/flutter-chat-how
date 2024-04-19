import 'dart:io';

import 'package:chat_how/consts.dart';
import 'package:chat_how/models/user_profile.dart';
import 'package:chat_how/services/alert_service.dart';
import 'package:chat_how/services/auth_service.dart';
import 'package:chat_how/services/database_service.dart';
import 'package:chat_how/services/media_service.dart';
import 'package:chat_how/services/naviagation_service.dart';
import 'package:chat_how/services/storage_service.dart';
import 'package:chat_how/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  File? _selectedImage;

  final GetIt _getIt = GetIt.instance;

  late MediaService _mediaQuery;
  late NavigationService _navigationService;
  late AuthService _authService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;

  String? email, password, name;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaQuery = _getIt<MediaService>();
    _navigationService = _getIt<NavigationService>();
    _authService = _getIt<AuthService>();
    _storageService = _getIt<StorageService>();
    _databaseService = _getIt<DatabaseService>();
    _alertService = _getIt<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _headerText(),
            if (!isLoading) _registerForm(),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.09,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello! Good to have you here...",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),
          ),
          Text(
            "Register using the form below",
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.05),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pfpSelectionField(),
            const SizedBox(
              height: 20,
            ),
            CustomFormField(
              height: MediaQuery.sizeOf(context).height * 0.1,
              hintText: "Name",
              validationRegEx: NAME_VALIdATION_REGEX,
              onSaved: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            CustomFormField(
              height: MediaQuery.sizeOf(context).height * 0.1,
              hintText: "Email",
              validationRegEx: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            CustomFormField(
              height: MediaQuery.sizeOf(context).height * 0.1,
              hintText: "Password",
              validationRegEx: PASSWORD_VALIdATION_REGEX,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            _registerButton(),
            _loginAccountLink()
          ],
        ),
      ),
    );
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaQuery.getImageFromGalary();
        if (file != null) {
          setState(() {
            _selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.18,
        backgroundImage: _selectedImage != null
            ? FileImage(_selectedImage!)
            : const NetworkImage(PLACEHOLDER_IMAGE) as ImageProvider,
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          "Register",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if ((_registerFormKey.currentState?.validate() ?? false) &&
                _selectedImage != null) {
              _registerFormKey.currentState!.save();
              bool result = await _authService.signup(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.uploadUserPfp(
                    file: _selectedImage!, uid: _authService.user!.uid);

                if (pfpURL != null) {
                  await _databaseService.createUserProfile(
                    userProfile: UserProfile(
                      name: name,
                      pfpURL: pfpURL,
                      uid: _authService.user?.uid,
                    ),
                  );

                  _alertService.showToast(
                      text: "User Registered Succesfully", icon: Icons.check);

                  _navigationService.pushReplacementNamed("/home");
                } else {
                  throw Exception("Unable to Register User");
                }
              } else {
                throw Exception("Unable to Register User");
              }
            }
          } catch (e) {
            _alertService.showToast(
                text: "Failed to register! Please try again latter",
                icon: Icons.info);
          }
          setState(() {
            isLoading = false;
          });
        },
      ),
    );
  }

  Widget _loginAccountLink() {
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "Already have an account? ",
        ),
        GestureDetector(
          onTap: () => {_navigationService.goBack()},
          child: const Text(
            "Login",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        )
      ],
    ));
  }
}
