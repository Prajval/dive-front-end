import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/register_repo.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../base_state.dart';
import '../utils/auth.dart';

class RegisterScreen extends StatefulWidget {
  final RegisterRepository registerRepo;

  RegisterScreen({this.registerRepo});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends BaseState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    subscribeToLinksStream();
    getLogger().d(initializingRegisterScreen);
  }

  @override
  void dispose() {
    getLogger().d(disposingRegisterScreen);
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    unsubscribeToLinksStream();
    super.dispose();
  }

  void validateAndRegister() {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    if (_formKey.currentState.validate()) {
      widget.registerRepo.registerUser(name, email, password).then((_) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => ChatListScreen(
                      auth: GetIt.instance<BaseAuth>(),
                      questionsRepository:
                          GetIt.instance<QuestionsRepository>(),
                    )),
            (Route<dynamic> route) => false);
      }).catchError((error) {
        String errorMessage;
        switch (error.code) {
          case weakPassword:
            errorMessage = weakPasswordMessage;
            break;
          case malformedEmail:
            errorMessage = malformedEmailMessage;
            break;
          case emailAlreadyInUse:
            errorMessage = emailAlreadyInUseMessage;
            break;
          default:
            errorMessage = defaultErrorMessageForRegistration;
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
      appBar: ReusableWidgets.getAppBar(registerAppBar, context),
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
                      prefixIcon: Icon(Icons.person), hintText: nameHint),
                  validator: (value) {
                    if (value.isEmpty) {
                      return nameEmptyValidatorError;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: Key(Keys.emailFormForSignUp),
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
                  key: Key(Keys.passwordFormForSignUp),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: chooseAPasswordHint,
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
                    key: Key(Keys.registerButton),
                    color: appPrimaryColor,
                    textColor: appWhiteColor,
                    onPressed: () {
                      validateAndRegister();
                    },
                    child: Text(registerButton),
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
