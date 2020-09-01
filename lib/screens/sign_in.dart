import 'package:dive/base_state.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/router_keys.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  final BaseAuth auth;

  SigninScreen({this.auth});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends BaseState<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    subscribeToLinksStream();
    getLogger().d(initializingSignInScreen);
  }

  @override
  void dispose() {
    getLogger().d(disposingSignInScreen);
    _emailController.dispose();
    _passwordController.dispose();
    unsubscribeToLinksStream();
    super.dispose();
  }

  void validateAndSignin() {
    if (_formKey.currentState.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      getLogger().d(formIsValidSigningIn);
      widget.auth.signIn(email, password).then((value) {
        getLogger().d(signInSuccessful);
        Navigator.pushReplacementNamed(context, RouterKeys.chatListRoute);
      }).catchError((error) {
        getLogger().e(signInFailed);
        String errorMessage;
        switch (error.code) {
          case invalidEmail:
            getLogger().e(invalidEmail);
            errorMessage = invalidEmailMessage;
            break;
          case wrongPassword:
            getLogger().e(wrongPassword);
            errorMessage = wrongPasswordMessage;
            break;
          case userNotFound:
            getLogger().e(userNotFound);
            errorMessage = userNotFoundMessage;
            break;
          case userDisabled:
            getLogger().e(userDisabled);
            errorMessage = userDisabledMessage;
            break;
          default:
            getLogger().e(defaultError);
            errorMessage = defaultErrorMessageForSignIn;
        }

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  errorTitle,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text('$errorMessage'),
                actions: <Widget>[
                  FlatButton(
                    child: Text(ok),
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
      appBar: ReusableWidgets.getAppBar(loginAppBar, context),
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
                    hintText: emailHint,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return emailEmptyValidatorError;
                    } else {
                      bool emailValid = RegExp(emailRegex).hasMatch(value);
                      if (!emailValid) {
                        return invalidEmailValidatorError;
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
                    hintText: enterPasswordHint,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return passwordEmptyValidationError;
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
                    color: appPrimaryColor,
                    textColor: appWhiteColor,
                    onPressed: () {
                      validateAndSignin();
                    },
                    child: Text(loginButton),
                  ),
                ),
                Center(
                  child: Wrap(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {},
                        child: Text(
                          forgotPasswordButton,
                          style: TextStyle(color: signUpGreyColor),
                        ),
                      )
                    ],
                  ),
                ),
                Divider(
                  color: appPrimaryColor,
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(dontHaveAnAccount),
                      FlatButton(
                        key: Key(Keys.signUpButton),
                        onPressed: () {
                          Navigator.pushNamed(
                              context, RouterKeys.registerRoute);
                        },
                        child: Text(
                          signUpButton,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appPrimaryColor),
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
