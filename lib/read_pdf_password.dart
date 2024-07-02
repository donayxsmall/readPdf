// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReadPdfPassword extends StatefulWidget {
  const ReadPdfPassword({super.key});

  @override
  State<ReadPdfPassword> createState() => _ReadPdfPasswordState();
}

class _ReadPdfPasswordState extends State<ReadPdfPassword> {
  String? _password;
  final GlobalKey<FormFieldState> _formKey = GlobalKey<FormFieldState>();
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _passwordDialogFocusNode = FocusNode();
  final bool _hasPasswordDialog = false;
  final String _errorText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: const [],
      ),
      body: TextButton(
        child: const Text("Open PDF"),
        onPressed: () {
          // if (pathPDF.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              // builder: (context) => PDFScreen(path: 'assets/android.pdf'),
              builder: (context) =>
                  PDFScreen(path: 'assets/print_password.pdf'),
            ),
          );
          // }
        },
      ),
    );
  }
}

class PDFScreen extends StatefulWidget {
  String? path;
  PDFScreen({
    super.key,
    this.path,
  });

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  String? _password;
  final GlobalKey<FormFieldState> _formKey = GlobalKey<FormFieldState>();
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _passwordDialogFocusNode = FocusNode();
  bool _hasPasswordDialog = false;
  String _errorText = '';
  final bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: const [],
      ),
      body: Stack(
        children: [
          SfPdfViewer.asset(
            widget.path!,
            canShowPasswordDialog: false,
            password: _password,
            // pageLayoutMode: PdfPageLayoutMode.single,
            scrollDirection: PdfScrollDirection.horizontal,
            onDocumentLoaded: (details) {
              // setState(() {
              //   _isLoading = true;
              // });
              if (_hasPasswordDialog) {
                Navigator.pop(context);
                _hasPasswordDialog = false;
                _passwordDialogFocusNode.unfocus();
                _textFieldController.clear();
              }
            },
            onDocumentLoadFailed: (details) {
              // setState(() {
              //   _isLoading = false;
              // });

              if (details.description.contains('password')) {
                if (details.description.contains('password') &&
                    _hasPasswordDialog) {
                  _errorText = "Invalid password !!";
                  _formKey.currentState?.validate();
                  _textFieldController.clear();
                  _passwordDialogFocusNode.requestFocus();
                } else {
                  _errorText = '';

                  /// Creating custom password dialog.
                  _showCustomPasswordDialog();
                  _passwordDialogFocusNode.requestFocus();
                  _hasPasswordDialog = true;
                }
              }
            },
          ),
          // if (_isLoading)
          //   const Center(
          //     child: CircularProgressIndicator(),
          //   ),
        ],
      ),
    );
  }

  /// Show the customized password dialog
  Future<void> _showCustomPasswordDialog() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          final Orientation orientation = kIsWeb
              ? Orientation.portrait
              : MediaQuery.of(context).orientation;
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.87),
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
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
                          key: _formKey,
                          controller: _textFieldController,
                          focusNode: _passwordDialogFocusNode,
                          obscureText: true,
                          decoration: const InputDecoration(
                              hintText: 'Password hint: syncfusion',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue))),
                          obscuringCharacter: '#',
                          onFieldSubmitted: (value) {
                            _handlePasswordValidation(value);
                          },
                          validator: (value) {
                            if (_errorText.isNotEmpty) {
                              return _errorText;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _formKey.currentState?.validate();
                            _errorText = '';
                          },
                        ),
                      )
                    ]))),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _handlePasswordValidation(_textFieldController.text);
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
        });
  }

  ///Close the password dialog
  void _closePasswordDialog() {
    Navigator.pop(context, 'Cancel');
    _hasPasswordDialog = false;
    _passwordDialogFocusNode.unfocus();
    _textFieldController.clear();
  }

  /// Validates the password entered in text field.
  void _handlePasswordValidation(String value) {
    setState(() {
      _password = value;
      _passwordDialogFocusNode.requestFocus();
    });
  }
}
