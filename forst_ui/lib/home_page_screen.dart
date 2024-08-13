

import 'package:flutter/material.dart';
import 'package:forst_ui/core/network/network_info.dart';
import 'package:forst_ui/features/auth/pages/login_screen.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class HomeScreen extends StatefulWidget{

  const HomeScreen({Key? key}) : super(key: key);


  @override
 _HomeScreenState createState() => _HomeScreenState() ;

}

class _HomeScreenState extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {
    return
        Scaffold(
          appBar: AppBar(
            title: Text("welcome authenticated user"),
          ),
          body: Container(
            child: MaterialButton(
              onPressed: () =>{Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()))},
              color: Colors.green,
              child: const Text("Login"),
              height: 20,
              focusColor: Colors.red,
            ),
          ) ,
        );
  }






}