import 'package:dive/repository/user_repo.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../base_state.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen(this.userRepository);

  final UserRepository userRepository;

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends BaseState<EditProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initialize();
    getLogger().d(initializingUpdateProfileScreen);

    _emailController.text = widget.userRepository.getCurrentUser().email;
    _nameController.text = widget.userRepository.getCurrentUser().displayName;
  }

  @override
  void dispose() {
    getLogger().d(disposingUpdateProfileScreen);
    _emailController.dispose();
    _nameController.dispose();
    close();
    super.dispose();
  }

  void validateAndUpdateProfile() {
    String email = _emailController.text;
    String name = _nameController.text;

    if (_formKey.currentState.validate()) {
      widget.userRepository.updateProfile(email, name).then((_) {
        getLogger().i(successfullyUpdatedProfile);
        ReusableWidgets.displayDialog(
            context, success, updateProfileSuccess, ok, () {
          Navigator.of(context).pop();
        });
      }).catchError((error) {
        getLogger().e(failedToUpdateProfile + error.toString());

        ReusableWidgets.displayDialog(
            context, errorTitle, updateProfileFailure, ok, () {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(editProfileAppBar, context),
      body: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: 30,
                  height: 30,
                ),
                TextFormField(
                  key: Key(Keys.nameFormForUpdateProfile),
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
                  key: Key(Keys.emailFormForUpdateProfile),
                  controller: _emailController,
                  decoration: InputDecoration(
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
                    key: Key(Keys.updateProfileButton),
                    color: appPrimaryColor,
                    textColor: appWhiteColor,
                    onPressed: () {
                      validateAndUpdateProfile();
                    },
                    child: Text(updateProfileButton),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
