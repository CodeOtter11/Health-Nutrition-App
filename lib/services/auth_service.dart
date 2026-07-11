import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/api_config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // ================= GOOGLE SIGN IN =================
  Future<bool> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      // 🌐 WEB
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _auth.signInWithPopup(provider);
      }
      // 📱 ANDROID / IOS
      else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return false;

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return false;

      final idToken = await firebaseUser.getIdToken();

      // ✅ FIXED BASE URL
      final baseUrl = await ApiConfig.getBaseUrl();

      final response = await http.post(
        Uri.parse("$baseUrl/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      );

      if (response.statusCode != 200) {
        print("Backend Google auth failed: ${response.body}");
        return false;
      }

      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("auth_token", data["token"]);
      await prefs.setString("username", data["user"]["name"]);
      await prefs.setString("email", data["user"]["email"]);

      return true;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return false;
    }
  }

  // ================= REGISTER =================
  Future<String?> register(
      String name,
      String email,
      String phone,
      String password,
      ) async {
    try {
      print("REGISTER START");

      // ✅ FIXED BASE URL
      final baseUrl = await ApiConfig.getBaseUrl();
      print("URL: $baseUrl/auth/register");

      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("auth_token", data["token"]);
        await prefs.setString("userId", data["user"]["id"]);   // ⭐ ADD
        await prefs.setString("username", data["user"]["name"]);
        await prefs.setString("email", data["user"]["email"]);

        return null;
      }

      return data["message"];
    } catch (e) {
      print("REGISTER ERROR: $e");
      return "Connection error";
    }
  }

  // ================= LOGIN =================
  Future<bool> login(String email, String password) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();

      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {

        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");

        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();


        await prefs.setString("auth_token", data["token"]);
        await prefs.setString("userId", data["user"]["id"]);   // ⭐ IMPORTANT
        await prefs.setString("username", data["user"]["name"]);
        await prefs.setString("email", data["user"]["email"]);

        print("✅ UserId saved: ${data["user"]["id"]}");

        return true;
      }

      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }

    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
  }
}