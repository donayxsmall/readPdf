// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:readpdf/read_pdf_dialog.dart';

class PasswordDialog extends StatefulWidget {
  // final Function(String, String) onValidatePassword;
  // final Function(String) handlePasswordValidation;
  // final Function(String) onChanged;
  final GlobalKey<FormFieldState> formKey;
  final Function(String, String)? onSubmitted;
  final Function(String)? onPressed;
  final String? Function(String?)? validator;

  const PasswordDialog({
    super.key,
    required this.formKey,
    this.onSubmitted,
    this.onPressed,
    this.validator,
  });

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  bool obscureText = true;

  // final GlobalKey<FormFieldState> _passwordFormKey =
  //     GlobalKey<FormFieldState>();
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _passwordDialogFocusNode = FocusNode();
  bool isReady = false;
  String errorMessage = '';
  String? password;

  void _closePasswordDialog() {
    // Navigator.pop(context, 'Cancel');
    // Navigator.of(context).pop();
    // Navigator.of(context).pop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ReadPdfDialog()),
    );

    // _hasPasswordDialog = false;
    // // isReady = true;
    // _passwordDialogFocusNode.unfocus();
    // _textFieldController.clear();
  }

  // void _handlePasswordValidation(String value) {
  //   password = value;
  //   isReady = false;
  //   _passwordDialogFocusNode.requestFocus();
  //   setState(() {});
  //   log("error message submit : $errorMessage ");

  //   // widget.onValidatePassword(value, errorMessage);
  // }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation =
        kIsWeb ? Orientation.portrait : MediaQuery.of(context).orientation;

    return AlertDialog(
      scrollable: true,
      insetPadding: EdgeInsets.zero,
      contentPadding: orientation == Orientation.portrait
          ? const EdgeInsets.all(24)
          : const EdgeInsets.only(top: 0, right: 24, left: 24, bottom: 0),
      buttonPadding: orientation == Orientation.portrait
          ? const EdgeInsets.all(8)
          : const EdgeInsets.all(4),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Password required',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87),
            ),
          ),
          SizedBox(
            height: 36,
            width: 36,
            child: RawMaterialButton(
              onPressed: () {
                _closePasswordDialog();
              },
              child: Icon(
                Icons.clear,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 24,
              ),
            ),
          ),
        ],
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      content: SingleChildScrollView(
          child: SizedBox(
              width: 326,
              child: Column(children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                    child: Text(
                      'The document is password protected. Please enter a password.',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                Form(
                  child: TextFormField(
                    key: widget.formKey,
                    controller: _textFieldController,
                    focusNode: _passwordDialogFocusNode,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          log("obscure : $obscureText");
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),
                    // obscuringCharacter: '#',
                    onFieldSubmitted: (value) {
                      // widget.handlePasswordValidation(value);
                      if (widget.onSubmitted != null) {
                        widget.onSubmitted!(value, errorMessage);
                      }
                    },
                    validator: (value) => widget.validator!(value),
                    // validator: (value) {
                    //   // if (value == null || value.isEmpty) {
                    //   //   return 'Please enter a password';
                    //   // }

                    //   // if (errorMessage.isNotEmpty) {
                    //   //   return errorMessage;
                    //   // }
                    //   // return null;

                    //   widget.validator!(value);
                    //   return null;
                    // },
                    onChanged: (value) {
                      // _passwordFormKey.currentState?.validate();
                      // errorMessage = '';
                    },
                  ),
                ),

                // const SizedBox(height: 10),
                // Text(
                //   errorMessage.isEmpty
                //       ? ''
                //       : 'Invalid password. Please try again.',
                //   style: const TextStyle(color: Colors.red, fontSize: 12),
                // ), // A
              ]))),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            widget.onPressed!(_textFieldController.text);
            // widget.validator!(_textFieldController.text, errorMessage);
            // widget.handlePasswordValidation(_textFieldController.text);
          },
          child: Text(
            'OK',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: TextButton(
            onPressed: () {
              _closePasswordDialog();
            },
            child: Text(
              'CANCEL',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        )
      ],
    );
  }
}
