// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readpdf/util/validator.dart';
import 'package:readpdf/widget/password_dialog.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ReadPdfDialog extends StatefulWidget {
  const ReadPdfDialog({super.key});

  @override
  State<ReadPdfDialog> createState() => _ReadPdfDialogState();
}

class _ReadPdfDialogState extends State<ReadPdfDialog> {
  String pathPDF = "";
  String remotePDFpath = "";

  @override
  void initState() {
    super.initState();

    // fromAsset('assets/print_password.pdf', 'print_password.pdf').then((f) {
    // fromAsset('assets/android.pdf', 'android.pdf').then((f) {
    fromAsset('assets/dasarpemrogramangolangpassword.pdf',
            'dasarpemrogramangolangpassword.pdf')
        .then((f) {
      setState(() {
        pathPDF = f.path;
      });
    });

    // createFileOfPdfUrl().then((f) {
    //   setState(() {
    //     remotePDFpath = f.path;
    //   });
    // });

    // downloadPdf(context);
  }

  void downloadPdf() async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 100,
      msg: 'File Downloading...',
      progressBgColor: Colors.red,
      progressType: ProgressType.valuable,
    );
    await createFileOfPdfUrl((progress) {
      print("Download Progress: $progress%");
      pd.update(value: progress);
      // Anda bisa memperbarui UI dengan nilai progress ini.
    }).then((file) {
      pd.close();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFScreen(path: file.path),
        ),
      );
    });
  }

  // void downloadPdf(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return const DownloadProgressDialog(progress: 0);
  //         },
  //       );
  //     },
  //   );

  //   await createFileOfPdfUrl((progress) {
  //     // Perbarui dialog dengan progress baru
  //     Navigator.of(context, rootNavigator: true).pop();
  //     print("Download Progress: $progress%");
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(
  //           builder: (context, setState) {
  //             return DownloadProgressDialog(progress: progress);
  //           },
  //         );
  //       },
  //     );
  //   }).then((file) {
  //     // Tutup dialog setelah selesai download
  //     Navigator.of(context, rootNavigator: true).pop();

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => PDFScreen(path: file.path),
  //       ),
  //     );
  //   }).catchError((error) {
  //     // Tutup dialog dan tampilkan error
  //     Navigator.of(context, rootNavigator: true).pop();
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Error'),
  //           content: Text(error.toString()),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   });
  // }

  Future<File> createFileOfPdfUrl(Function(int) onProgress) async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      const url = "http://150.100.50.23:8000/storage/assets/product/golang.pdf";
      final filename = url.substring(url.lastIndexOf("/") + 1);
      // var dir = await getApplicationDocumentsDirectory();
      var dir = await getTemporaryDirectory();

      // Define the folder path
      final folderPath = "${dir.path}/slip";
      // Create the folder if it doesn't exist
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      print("Download files");
      print("$folderPath/$filename");
      File file = File("$folderPath/$filename");

      Dio dio = Dio();
      await dio.download(
        url,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // double progress = received / total * 100;
            int progress = (((received / total) * 100).toInt());
            onProgress(progress);
          }
        },
      );

      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");

      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      completer.completeError('Error parsing asset file!');
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextButton(
                child: const Text("Open PDF"),
                onPressed: () {
                  if (pathPDF.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFScreen(path: pathPDF),
                      ),
                    );
                  }

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const PdfViewPage(
                  //       // pdfPath: 'assets/print_password.pdf',
                  //       pdfPath: 'assets/android.pdf',
                  //       hasPassword:
                  //           false, // Set to true if the PDF has a password
                  //     ),
                  //   ),
                  // );
                },
              ),
              TextButton(
                child: const Text("Remote PDF"),
                onPressed: () {
                  // if (remotePDFpath.isNotEmpty) {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       // builder: (context) => PDFScreen(path: remotePDFpath),
                  //       builder: (context) => downloadPdf(context),
                  //     ),
                  //   );
                  // }

                  downloadPdf();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PDFScreen extends StatefulWidget {
  final String? path;

  const PDFScreen({super.key, this.path});

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  String? password;

  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _passwordDialogFocusNode = FocusNode();
  bool _hasPasswordDialog = false;

  final GlobalKey<FormFieldState> _passwordFormKey =
      GlobalKey<FormFieldState>();

  ///Close the password dialog
  void _closePasswordDialog() {
    // Navigator.pop(context, 'Cancel');
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    // _hasPasswordDialog = false;
    // // isReady = true;
    // _passwordDialogFocusNode.unfocus();
    // _textFieldController.clear();
  }

  /// Validates the password entered in text field.
  void _handlePasswordValidation(String value) {
    // if (value.isNotEmpty) {
    //   setState(() {
    //     password = value;
    //     // errorMessage = '';
    //     isReady = false;
    //     _passwordDialogFocusNode.requestFocus();
    //     // Navigator.of(context).pop();
    //   });
    // }

    // if (errorMessage.isNotEmpty) {
    //   Navigator.of(context).pop();
    //   _hasPasswordDialog = false;
    //   errorMessage = '';
    //   isReady = true;
    // }

    // if (errorMessage.isEmpty && isReady && _hasPasswordDialog) {
    //   errorMessage = '';
    //   setState(() {});
    //   Navigator.of(context).pop();
    // } else {
    password = value;
    isReady = false;
    _passwordDialogFocusNode.requestFocus();
    // Navigator.of(context).pop();
    setState(() {});
    // }

    log("error message submit : $errorMessage ");
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  Future<void> _showCustomPasswordDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PasswordDialog(
          formKey: _passwordFormKey,
          onPressed: (p0) {
            _handlePasswordValidation(p0);
          },
          validator: (value) {
            log("validator : $errorMessage");
            return Validator.requiredPassword(value, errorMessage);
          },
          // validator: (value) {
          //   if (value!.isEmpty) {
          //     return 'Please enter a password';
          //   }

          //   if (errorMessage.isNotEmpty) {
          //     return errorMessage;
          //   }

          //   return null;
          // },
        );
      },
    );
  }

  /// Show the customized password dialog
  // Future<void> _showCustomPasswordDialog() async {
  //   bool obscureText = true;
  //   return showDialog<void>(
  //       context: context,
  //       barrierDismissible: true,
  //       builder: (BuildContext context) {
  //         final Orientation orientation = kIsWeb
  //             ? Orientation.portrait
  //             : MediaQuery.of(context).orientation;
  //         return AlertDialog(
  //           scrollable: true,
  //           insetPadding: EdgeInsets.zero,
  //           contentPadding: orientation == Orientation.portrait
  //               ? const EdgeInsets.all(24)
  //               : const EdgeInsets.only(top: 0, right: 24, left: 24, bottom: 0),
  //           buttonPadding: orientation == Orientation.portrait
  //               ? const EdgeInsets.all(8)
  //               : const EdgeInsets.all(4),
  //           title: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: <Widget>[
  //               Text(
  //                 'Password required',
  //                 style: TextStyle(
  //                   fontFamily: 'Roboto',
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.w500,
  //                   color: Theme.of(context)
  //                       .colorScheme
  //                       .onSurface
  //                       .withOpacity(0.87),
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: 36,
  //                 width: 36,
  //                 child: RawMaterialButton(
  //                   onPressed: () {
  //                     _closePasswordDialog();
  //                   },
  //                   child: Icon(
  //                     Icons.clear,
  //                     color: Theme.of(context)
  //                         .colorScheme
  //                         .onSurface
  //                         .withOpacity(0.6),
  //                     size: 24,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           shape: const RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(4.0))),
  //           content: SingleChildScrollView(
  //               child: SizedBox(
  //                   width: 326,
  //                   child: Column(children: <Widget>[
  //                     Align(
  //                       alignment: Alignment.centerLeft,
  //                       child: Padding(
  //                         padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
  //                         child: Text(
  //                           'The document is password protected. Please enter a password.',
  //                           style: TextStyle(
  //                             fontFamily: 'Roboto',
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.w400,
  //                             color: Theme.of(context)
  //                                 .colorScheme
  //                                 .onSurface
  //                                 .withOpacity(0.6),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Form(
  //                       child: TextFormField(
  //                         key: _passwordFormKey,
  //                         controller: _textFieldController,
  //                         focusNode: _passwordDialogFocusNode,
  //                         obscureText: obscureText,
  //                         decoration: InputDecoration(
  //                           hintText: 'Password',
  //                           border: const OutlineInputBorder(
  //                               borderSide: BorderSide(color: Colors.blue)),
  //                           focusedBorder: const OutlineInputBorder(
  //                             borderSide: BorderSide(color: Colors.blue),
  //                           ),
  //                           suffixIcon: IconButton(
  //                             icon: Icon(
  //                               obscureText
  //                                   ? Icons.visibility
  //                                   : Icons.visibility_off,
  //                             ),
  //                             onPressed: () {
  //                               log("obscure : $obscureText");
  //                               setState(() {
  //                                 obscureText = !obscureText;
  //                               });
  //                             },
  //                           ),
  //                         ),
  //                         // obscuringCharacter: '#',
  //                         onFieldSubmitted: (value) {
  //                           _handlePasswordValidation(value);
  //                         },
  //                         validator: (value) {
  //                           if (value == null || value.isEmpty) {
  //                             return 'Please enter a password';
  //                           }

  //                           if (errorMessage.isNotEmpty) {
  //                             return errorMessage;
  //                           }
  //                           return null;
  //                         },
  //                         onChanged: (value) {
  //                           // _passwordFormKey.currentState?.validate();
  //                           // errorMessage = '';
  //                         },
  //                       ),
  //                     ),

  //                     // const SizedBox(height: 10),
  //                     // Text(
  //                     //   errorMessage.isEmpty
  //                     //       ? ''
  //                     //       : 'Invalid password. Please try again.',
  //                     //   style: const TextStyle(color: Colors.red, fontSize: 12),
  //                     // ), // A
  //                   ]))),
  //           actions: <Widget>[
  //             TextButton(
  //               onPressed: () {
  //                 _handlePasswordValidation(_textFieldController.text);
  //               },
  //               child: Text(
  //                 'OK',
  //                 style: TextStyle(
  //                   fontFamily: 'Roboto',
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w500,
  //                   color: Theme.of(context).colorScheme.primary,
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
  //               child: TextButton(
  //                 onPressed: () {
  //                   _closePasswordDialog();
  //                 },
  //                 child: Text(
  //                   'CANCEL',
  //                   style: TextStyle(
  //                     fontFamily: 'Roboto',
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w500,
  //                     color: Theme.of(context).colorScheme.primary,
  //                   ),
  //                 ),
  //               ),
  //             )
  //           ],
  //         );
  //       });
  // }

  // void _showPasswordDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       String? inputPassword;
  //       return AlertDialog(
  //         title: const Text("Enter Password"),
  //         content: Column(
  //           children: [
  //             TextField(
  //               obscureText: false,
  //               onChanged: (value) {
  //                 inputPassword = value;
  //               },
  //               decoration: const InputDecoration(hintText: "Password"),
  //             ),
  //             const SizedBox(height: 10),
  //             Text(
  //               errorMessage.isEmpty
  //                   ? ''
  //                   : 'Invalid password. Please try again.',
  //               style: const TextStyle(color: Colors.red, fontSize: 12),
  //             ), // Add some spacing
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text("Cancel"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text("Submit"),
  //             onPressed: () {
  //               if (inputPassword != null && inputPassword!.isNotEmpty) {
  //                 setState(() {
  //                   password = inputPassword!;
  //                   errorMessage = '';
  //                   isReady = false;
  //                 });
  //                 Navigator.of(context).pop();
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            key: ValueKey<String?>(password),
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            password: password,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (pages) {
              log('render');
              setState(() {
                errorMessage = '';
                this.pages = pages;
                isReady = true;
                // _hasPasswordDialog = true;
              });

              if (_hasPasswordDialog) {
                Navigator.of(context).pop();
              }
              // Navigator.of(context).pop();
            },
            onError: (details) {
              log('error');
              log('error : $details');
              log("password dialog : $_hasPasswordDialog");

              log("error message : $errorMessage");
              log("isready : $isReady");
              // setState(() {
              //   errorMessage = error.toString();
              // });

              // if (error.toString().contains("Password")) {
              //   _showCustomPasswordDialog();
              // } else {
              //   print(error.toString());
              // }
              // isReady = true;

              // log("detail : $details");
              // log("error : $errorMessage");
              // log("error_dialog : $_hasPasswordDialog ");

              if (details.contains('password')) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Invalid password!')),
                // );

                if (_hasPasswordDialog) {
                  errorMessage = "Invalid password !!";

                  _passwordFormKey.currentState?.validate();
                  // _textFieldController.clear();
                  _passwordDialogFocusNode.requestFocus();
                  setState(() {});
                } else {
                  errorMessage = '';
                  _showCustomPasswordDialog();
                  _passwordDialogFocusNode.requestFocus();
                  _hasPasswordDialog = true;
                  setState(() {});
                }

                // if (details.contains('password') && _hasPasswordDialog) {
                //   errorMessage = "Invalid password !!";
                //   _passwordFormKey.currentState?.validate();
                //   _textFieldController.clear();
                //   _passwordDialogFocusNode.requestFocus();
                // } else {
                //   errorMessage = '';

                //   /// Creating custom password dialog.
                //   _showCustomPasswordDialog();
                //   _passwordDialogFocusNode.requestFocus();
                //   _hasPasswordDialog = true;
                // }
              }
            },
            onPageError: (page, error) {
              log('_hasPasswordDialog : $_hasPasswordDialog ');
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              log('onviewCreated');
              if (!_controller.isCompleted) {
                _controller.complete(pdfViewController);

                if (_hasPasswordDialog) {
                  Navigator.pop(context);
                  _hasPasswordDialog = false;
                  _passwordDialogFocusNode.unfocus();
                  _textFieldController.clear();
                }
              }
              // _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
      // floatingActionButton: FutureBuilder<PDFViewController>(
      //   future: _controller.future,
      //   builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
      //     if (snapshot.hasData) {
      //       return FloatingActionButton.extended(
      //         label: Text("Go to ${pages! ~/ 2}"),
      //         onPressed: () async {
      //           await snapshot.data!.setPage(pages! ~/ 2);
      //         },
      //       );
      //     }

      //     return Container();
      //   },
      // ),
    );
  }
}
