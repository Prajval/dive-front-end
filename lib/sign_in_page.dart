import 'package:dive/auth.dart';
import 'package:dive/home_page.dart';
import 'package:dive/keys.dart';
import 'package:dive/register_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SigninPage extends StatefulWidget {
  final BaseAuth auth;

  SigninPage({this.auth});

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  void validateAndSignin() {
    if (_formKey.currentState.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      widget.auth.signIn(email, password).then((value) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return HomePage(widget.auth);
        }));
      }).catchError((error) {
        print('$error');
        String errorMessage;
        switch (error.code) {
          case "ERROR_INVALID_EMAIL":
            errorMessage =
                "Your email address appears to be incorrect. Please try again.";
            break;
          case "ERROR_WRONG_PASSWORD":
            errorMessage = "Your password is wrong. Please try again.";
            break;
          case "ERROR_USER_NOT_FOUND":
            errorMessage =
                "User with this email doesn't exist. Please try again.";
            break;
          case "ERROR_USER_DISABLED":
            errorMessage =
                "User with this email has been disabled. Please try logging in with a different user.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            errorMessage =
                "You have tried to login too many times. Please try again later.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            errorMessage =
                "An error occurred while trying to login. Please try again later.";
            break;
          default:
            errorMessage =
                "An error occurred while trying to login. Please try again.";
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
      appBar: AppBar(
        title: Text('Login'),
      ),
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
                  key: Key(Keys.emailFormForSignIn),
                  keyboardType: TextInputType.emailAddress,
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
                  key: Key(Keys.passwordFormForSignIn),
                  obscureText: true,
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Please enter your password',
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
                    key: Key(Keys.signInButton),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      validateAndSignin();
                    },
                    child: Text('Login'),
                  ),
                ),
                Center(
                  child: Wrap(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot password',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    ],
                  ),
                ),
                Divider(
                  color: Colors.blue,
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Don\'t have an account ?'),
                      FlatButton(
                        key: Key(Keys.signUpButton),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return RegisterPage(
                              auth: widget.auth,
                            );
                          }));
                        },
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      )
                    ],
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
