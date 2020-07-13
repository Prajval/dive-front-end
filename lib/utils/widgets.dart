import 'package:flutter/material.dart';

import 'auth.dart';
import 'constants.dart';

class ReusableWidgets {
  static getAppBar(String title, BuildContext context) {
    return AppBar(
        elevation: 3,
        backgroundColor: appBarColor,
        title: Text(title, style: TextStyle(color: whiteTextColor)));
  }

  static getAppBarWithAvatar(String title, BuildContext context, Auth auth,
      Key key, VoidCallback callback) {
    return AppBar(
        actions: <Widget>[
          FlatButton(
            key: key,
            onPressed: callback,
            child: CircleAvatar(
              backgroundColor: backgroundColor,
              child: Icon(
                Icons.person,
                color: appPrimaryColor,
              ),
            ),
          )
        ],
        elevation: 3,
        backgroundColor: appBarColor,
        title: Text(title, style: TextStyle(color: whiteTextColor)));
  }

  static getForm(Key key, TextEditingController controller,
      final String hintText, FormFieldValidator validator, Icon icon) {
    return TextFormField(
      key: key,
      controller: controller,
      decoration: InputDecoration(
          prefixIcon: icon, hintText: hintText, focusColor: appPrimaryColor),
      validator: validator,
    );
  }
}
