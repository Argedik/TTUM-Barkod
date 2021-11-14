import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Barkod extends StatefulWidget {
  const Barkod({Key? key}) : super(key: key);

  @override
  _BarkodState createState() => _BarkodState();
}

class _BarkodState extends State<Barkod> {
  var veriTb =
      FirebaseFirestore.instance.collection("veri_tabani").doc("Peynir");
  // UserCredential userCredential =
  //     await FirebaseAuth.instance.signInAnonymously();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("absürt"),
        ),
        body: Center(
            child: ElevatedButton(
                onPressed: () {
                  print(veriTb);
                  print(veriTb.snapshots());
                  print(veriTb.snapshots().first);
                  print(veriTb.snapshots().last);
                  print(veriTb.snapshots().map((event) => event.data()));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              AddUser("fullName", "company", 15)));
                },
                child: const Text("deneme"))));
  }
}

class AddUser extends StatelessWidget {
  final String fullName;
  final String company;
  final int age;

  AddUser(this.fullName, this.company, this.age);

  @override
  Widget build(BuildContext context) {
    // Create a CollectionReference called users that references the firestore collection
    CollectionReference users =
        FirebaseFirestore.instance.collection('veri_tabani');

    Future<void> addUser() {
      // Call the user's CollectionReference to add a new user
      print("absürt");
      return users
          .add({
            'full_name': fullName, // John Doe
            'company': company, // Stokes and Sons
            'age': age // 42
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("absürt"),
      ),
      body: Center(
        child: TextButton(
          onPressed: addUser,
          child: const Text(
            "Add User",
          ),
        ),
      ),
    );
  }
}
