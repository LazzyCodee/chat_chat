// auth_firebase.dart
import 'package:chat_chat/bloc/home_bloc.dart';
import 'package:chat_chat/pages/home.dart';
import 'package:chat_chat/services/database.dart';
import 'package:chat_chat/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Выход из текущего аккаунта перед входом, чтобы можно было выбрать другой
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        return; // Пользователь отменил вход
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? userDetails = userCredential.user;

      if (userDetails != null) {
        String username = userDetails.email!.replaceAll("@gmail.com", "");
        String searchKey = username.substring(0, 1).toUpperCase();

        Map<String, dynamic> userData = {
          "uid": userDetails.uid,
          "email": userDetails.email,
          "displayName": userDetails.displayName,
          "photoUrl": userDetails.photoURL ?? "",
          "username": username.toUpperCase(),
          "SearchKey": searchKey,
        };

        // Сохранение данных в SharedPreferences
        await SharedPreferencesHelper()
            .setUsername(userDetails.displayName ?? "");
        await SharedPreferencesHelper().setPhotoUrl(userDetails.photoURL ?? "");
        await SharedPreferencesHelper().setEmail(userDetails.email ?? "");
        await SharedPreferencesHelper().setUserId(userDetails.uid);
        await SharedPreferencesHelper()
            .setUserNameUpper(username.toUpperCase());

        // Проверяем, есть ли уже этот пользователь в Firestore
        bool userExists =
            await DatabaseMethods().checkUserExists(userDetails.uid);

        if (!userExists) {
          await DatabaseMethods().addUserInfo(userData, userDetails.uid);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: const Text(
              "Вы вошли в аккаунт",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );

        // Перенаправление на главную страницу
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider<HomeBloc>(
              create: (context) => HomeBloc(),
              child: const Home(),
            ),
          ),
        );
      }
    } catch (e) {
      print("Ошибка входа: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Ошибка входа: $e",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}
