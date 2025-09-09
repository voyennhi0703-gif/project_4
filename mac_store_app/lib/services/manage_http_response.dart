import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void manageHttpResponse({
  required http.Response response, // the Http resonse from the request
  required BuildContext context, // the context is to show snackbar
  required VoidCallback onSuccess, // the callback to excute on a successfull response
  }) {
  print("MANAGE RESPONSE STATUS: ${response.statusCode}");
  print("MANAGE RESPONSE BODY: ${response.body}");
  print("Decoded Response: ${json.decode(response.body)}");


    //switch statement to handle different http satatus codes
    switch(response.statusCode){
      case 200: //status code 200 indicates a successfull request 
      onSuccess();
      break;
      case 400:
      try {
        final data = json.decode(response.body);
        final msg = data['msg'] ?? data['error'] ?? response.body;
        showSnackBar(context, msg.toString());
      } catch (e) {
        showSnackBar(context, "Error decoding response: $e");
      }
      break;
      case 500: // status code 500 indicates a server  error
      showSnackBar(context, json.decode(response.body)['error']);
      break;
      case 201: // status code 201 indicates a resource was created successfully
      onSuccess();
      break;
      default:
      try {
        final data = json.decode(response.body);
        final msg = data['msg'] ?? data['error'] ?? 'Unexpected error';
        showSnackBar(context, msg);
      } catch (_) {
        showSnackBar(context, 'Unexpected error occurred');
      }
    }
}

void showSnackBar(BuildContext context, String title){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
}