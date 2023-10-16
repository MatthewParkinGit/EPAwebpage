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
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailResetController.dispose();
    super.dispose();
  }

  bool isLoading = true;
  int stackIndex = 0;

  void signUp() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: newEmailController.text.trim(),
          password: newPasswordController.text);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text("Missing fields"),
        ),
      );
    }
  }

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

  void resetPassword() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailResetController.text.trim());
      Navigator.pop(context);
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => Center(
            child: Container(
                height: 55,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: const Text("Password reset link sent."))),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => Center(
            child: Text(
                "No account under with the email ${emailController.text} exists.")),
      );
    }
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailResetController = TextEditingController();

  TextEditingController newEmailController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

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
          child: IndexedStack(
            index: stackIndex,
            children: [
              Scaffold(
                appBar: AppBar(
                    centerTitle: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    title: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.black),
                    )),
                body: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
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
                          decoration:
                              const InputDecoration(hintText: "Password"),
                          maxLines: 1,
                          controller: passwordController,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Password Reset"),
                                content: SizedBox(
                                  width: 200,
                                  height: 100,
                                  child: Column(
                                    children: [
                                      TextField(
                                        decoration: const InputDecoration(
                                            hintText: "Email Address"),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        maxLines: 1,
                                        controller: emailResetController,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  CupertinoButton(
                                      child: Text("Send"),
                                      onPressed: () {
                                        if (emailResetController.text
                                            .trim()
                                            .isNotEmpty) {
                                          resetPassword();
                                        } else {}
                                      })
                                ],
                              ),
                            );
                          },
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
                            onPressed: signUserIn,
                            child: const Text(
                              "Sign in",
                              style: TextStyle(color: Colors.white),
                            )),
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
                            onPressed: () {
                              setState(() {
                                stackIndex = 1;
                              });
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    leading: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          stackIndex = 0;
                        });
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.blue,
                      ),
                    ),
                    title: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 50,
                          child: TextField(
                            decoration: const InputDecoration(
                                hintText: "Email Address"),
                            keyboardType: TextInputType.emailAddress,
                            maxLines: 1,
                            controller: newEmailController,
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          height: 50,
                          child: TextField(
                            obscureText: true,
                            decoration:
                                const InputDecoration(hintText: "Password"),
                            maxLines: 1,
                            controller: newPasswordController,
                          ),
                        ),
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
                              onPressed: signUp,
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      )),
    );
  }
}
