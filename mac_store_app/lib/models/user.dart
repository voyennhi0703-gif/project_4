import 'dart:convert';
class User{
  //Define Fields
   final String id;
   final String fullName;
   final String email;
   final String state;
   final String city;
   final String locality;
   final String password;
   final String token;

  User({required this.id, required this.fullName, required this.email, required this.state, required this.city, required this.locality, required this.password, required this.token });

//serialization:covert user object to a map
//map: a map is a collection of key-value pairs
//why: coverting to a map is an intermediate step that makes it easier to serialize
//the object to formates like json for storage or transmission.

 Map<String, dynamic> toMap(){
  return <String, dynamic>{
    "id":id,
    'fullName': fullName,
    'email': email,
    'state': state,
    'city': city,
    'locality': locality,
    'password': password,
    'token': token,
  };
 }
 //Serialization:Covert Map to a Json String
 //This method directly encodes the data from the Map into a Json String

  //The json.encode() function converts a Dart object (such as Map or list)
  //into a Json String reprensentation, making it suitable for communication
  //between different system 
  String toJson() => json.encode(toMap());


  //Deserialization: Covert a Map to a User Object
  //purpose - Manipulation and user : Once the data is coverted a to a User object
  //it can be easily manipuated and use within the application . For example 
  //we might want to display the user's fullname, email etc on the Ui. or we might 
  //want to save the data locally.

  //the factory contructor takes a Map (usually obtained from a json object)
  // and coverts it into a user object.if a field is not pressend in the 
  /// it defaults to an empty String.
  //fromMap:This contructor take a Map<String,dynamic> and coverts into a user object
  //. its usefull when you already have the data in map format
  factory User.fromMap(Map<String,dynamic>map){
    return User(
      id : map ['id'] as String? ??"",
      fullName : ['fullName'] as String? ??"",
      email : ['email'] as String? ??"",
      state : ['state'] as String? ??"",
      city : ['city'] as String? ??"",
      locality: ['locality'] as String? ??"",
      password: ['password'] as String? ??"", 
      token: ['token'] as String? ?? "",  
    );
  }

  //fromJson: This factory contructor takes json String, and decodes into a Map<String,dynamic>
  //and then user fromMap to covert that Map into a User  Obtaint

  factory User.fromJson(String source) => 
    User.fromMap(json.decode(source) as Map<String,dynamic>);

}