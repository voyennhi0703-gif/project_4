import 'package:flutter/material.dart';
import 'package:mac_store_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app/services/manage_http_response.dart';
import 'dart:convert';
import 'package:mac_store_app/views/screens/authentication_screens/login_screens.dart';
import 'package:mac_store_app/views/nav_screens/main_screen.dart';
class AuthController{
  AuthController();

  Future<void> signUpUsers({
    required context,
    required String email,
    required String fullName,
    required String password,
    required String uri,

  })async {
    try {
    User user = User(
        id: '',
        fullName: fullName,
        email: email,
        state: '', 
        city: '', 
        locality: '', 
        password: password,
        token: '');
    http.Response response = await http.post(Uri.parse('$uri/api/signup'),
      body: user
          .toJson(),// Covert the user object to json for the request body
      headers: {
      //Set headers for the request
      "Content-Type": 'application/json; charset=UTF-8', //specify the context type á Json
    },);

    manageHttpResponse(
      response: response, 
      context: context, 
      onSuccess: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()) );
        showSnackBar(context, 'Account has been Created for you');
    },);
    } catch (e){
      print("Error: $e ");
    }
  }

  ///signin user function
  Future<void> signInUsers({
    required context,
    required String email,
    required String password,
    required String uri,
  })async{
    try {
      http.Response response = await  http.post(Uri.parse("$uri/api/signin"),body:jsonEncode({
        'email':email,
        'password':password,
      },
      ), 
      headers:<String,String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }
    );
       print("STATUS CODE: ${response.statusCode}");
        print("RESPONSE BODY: ${response.body}");

    manageHttpResponse(response: response, context: context, onSuccess:(){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false);
      showSnackBar(context, 'Logged In');
    });
    } catch (e){
      print("Error: $e ");

    }
  }
}