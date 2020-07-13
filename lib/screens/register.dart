import 'package:dive/repository/questions_repo.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../utils/auth.dart';

class RegisterScreen extends StatefulWidget {
  final BaseAuth auth;

  RegisterScreen({this.auth});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void validateAndRegister() {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    if (_formKey.currentState.validate()) {
      widget.auth.signUp(email, password, name).then((value) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => ChatListScreen(
                      auth: widget.auth,
                      questionsRepository:
                          GetIt.instance<QuestionsRepository>(),
                    )),
            (Route<dynamic> route) => false);
      }).catchError((error) {
        String errorMessage;
        switch (error.code) {
          case "ERROR_WEAK_PASSWORD":
            errorMessage =
                "Your password is weak. Please enter at least six characters";
            break;
          case "ERROR_INVALID_EMAIL":
            errorMessage = "The email address is malformed. Please try again.";
            break;
          case "ERROR_EMAIL_ALREADY_IN_USE":
            errorMessage =
                "Email already in use. Please try with a different email.";
            break;
          default:
            errorMessage =
                "An error occurred while trying to register. Please try again.";
        }

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Error',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text('$errorMessage'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: ReusableWidgets.getAppBar('Register', context),
      body: Center(
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'images/logo.png',
                  width: 150,
                  height: 150,
                ),
                SizedBox(
                  width: 30,
                  height: 30,
                ),
                TextFormField(
                  key: Key(Keys.nameFormForSignUp),
                  controller: _nameController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Enter your full name'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: Key(Keys.emailFormForSignUp),
                  controller: _emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Enter your email',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    } else {
                      bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value);
                      if (!emailValid) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    }
                  },
                ),
                TextFormField(
                  key: Key(Keys.passwordFormForSignUp),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Choose a password',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some password';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  width: 15,
                  height: 25,
                ),
                Container(
                  height: 50,
                  child: FlatButton(
                    key: Key(Keys.registerButton),
                    color: appPrimaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      validateAndRegister();
                    },
                    child: Text('Register'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
