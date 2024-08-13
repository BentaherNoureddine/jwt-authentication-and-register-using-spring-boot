

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget{

  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();


}

class _AdminHomePageState  extends State<AdminHomePage>{


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("hello admin"),),
    );
  }
}