

import 'package:flutter/material.dart';
import 'package:forst_ui/features/auth/pages/login_screen.dart';


class HomeScreen extends StatefulWidget{

  const HomeScreen({super.key});


  @override
 _HomeScreenState createState() => _HomeScreenState() ;

}

class _HomeScreenState extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {
    return
        Scaffold(
          appBar: AppBar(
            title: const Text("welcome authenticated user"),
          ),
          body: MaterialButton(
            onPressed: () =>{Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()))},
            color: Colors.green,
            height: 20,
            focusColor: Colors.red,
            child: const Text("Login"),
          ) ,
        );
  }






}