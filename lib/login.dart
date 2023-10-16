// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginPage> {
  bool isLoading = true;

  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text("Incorrect username and password"),
        ),
      );
    }
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
          child: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          height: 500,
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome back",
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  height: 50,
                  child: TextField(
                    decoration:
                        const InputDecoration(hintText: "Email Address"),
                    keyboardType: TextInputType.emailAddress,
                    maxLines: 1,
                    controller: emailController,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  height: 50,
                  child: TextField(
                    obscureText: true,
                    decoration: const InputDecoration(hintText: "Password"),
                    maxLines: 1,
                    controller: passwordController,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                    child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                )),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  height: 55,
                  width: 300,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue),
                  child: CupertinoButton(
                      child: const Text(
                        "Sign in",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: signUserIn),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 300,
                  height: 55,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey),
                  child: CupertinoButton(
                      child: const Text(
                        "Sign up",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {}),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
