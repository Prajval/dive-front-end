import 'package:dive/base_state.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen(this.userRepository);

  final UserRepository userRepository;

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends BaseState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initialize();
    getLogger().d(initializingForgotPassword);
  }

  @override
  void dispose() {
    getLogger().d(disposingForgotPassword);
    _emailController.dispose();
    close();
    super.dispose();
  }

  void validateAndSendResetPasswordToEmail() {
    String email = _emailController.text;

    if (_formKey.currentState.validate()) {
      widget.userRepository.resetPassword(email).then((_) {
        getLogger().i(sentEmailToResetPassword);
        ReusableWidgets.displayDialog(
            context, success, sentEmailToResetPassword, ok, () {
          Navigator.of(context).pop();
        });
      }).catchError((error) {
        getLogger().e(failedToSendEmailToResetPassword + error.toString());

        ReusableWidgets.displayDialog(
            context, errorTitle, passwordResetSendingEmailFailed, ok, () {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(forgotPasswordAppBar, context),
      body: Center(
        child: Container(
          margin: EdgeInsets.only(top: 70, left: 20, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
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
                  key: Key(Keys.emailFormForForgotPassword),
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
                SizedBox(
                  width: 15,
                  height: 25,
                ),
                Container(
                  height: 50,
                  child: FlatButton(
                    key: Key(Keys.sendEmailForgotPasswordButton),
                    color: appPrimaryColor,
                    textColor: appWhiteColor,
                    onPressed: () {
                      validateAndSendResetPasswordToEmail();
                    },
                    child: Text(passwordResetEmailButton),
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
