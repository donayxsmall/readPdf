import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() => runApp(const ReadPdfDialog2());

class ReadPdfDialog2 extends StatefulWidget {
  const ReadPdfDialog2({super.key});

  @override
  _ReadPdfDialog2State createState() => _ReadPdfDialog2State();
}

class _ReadPdfDialog2State extends State<ReadPdfDialog2> {
  String pathPDF = "";
  String landscapePathPdf = "";
  String remotePDFpath = "";
  String corruptedPathPDF = "";

  @override
  void initState() {
    super.initState();
    // fromAsset('assets/corrupted.pdf', 'corrupted.pdf').then((f) {
    //   setState(() {
    //     corruptedPathPDF = f.path;
    //   });
    // });
    fromAsset('assets/print_password.pdf', 'print_password.pdf').then((f) {
      setState(() {
        pathPDF = f.path;
      });
    });
    // fromAsset('assets/demo-landscape.pdf', 'landscape.pdf').then((f) {
    //   setState(() {
    //     landscapePathPdf = f.path;
    //   });
    // });

    // createFileOfPdfUrl().then((f) {
    //   setState(() {
    //     remotePDFpath = f.path;
    //   });
    // });
  }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      const url = "http://www.pdf995.com/samples/pdf.pdf";
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  Future<File> fromAsset(String asset, String filename) async {
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF View',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Builder(
            builder: (BuildContext context) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                    },
                  ),
                  TextButton(
                    child: const Text("Open Landscape PDF"),
                    onPressed: () {
                      if (landscapePathPdf.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PDFScreen(path: landscapePathPdf),
                          ),
                        );
                      }
                    },
                  ),
                  TextButton(
                    child: const Text("Remote PDF"),
                    onPressed: () {
                      if (remotePDFpath.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PDFScreen(path: remotePDFpath),
                          ),
                        );
                      }
                    },
                  ),
                  TextButton(
                    child: const Text("Open Corrupted PDF"),
                    onPressed: () {
                      if (corruptedPathPDF.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PDFScreen(path: corruptedPathPDF),
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
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
  bool isPasswordProtected = true; // Set this based on actual PDF file
  String? enteredPassword;
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = "";
  // String? password;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

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
      // body: isPasswordProtected ? _buildPasswordInput() : _buildPasswordInput(),
      body: _buildPDFView(context),
      // : _buildPDFView(context),
    );
  }

  Widget _buildPasswordInput(context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Enter Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  log("error message : $errorMessage");
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  } else if (errorMessage.isNotEmpty) {
                    // replace with actual password check
                    return 'Invalid password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      enteredPassword = _passwordController.text;
                      isPasswordProtected =
                          false; // assuming the password is correct
                    });
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPDFView(BuildContext context) {
    return Stack(
      children: <Widget>[
        PDFView(
          key: ValueKey<String?>(enteredPassword),
          filePath: widget.path,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: true,
          pageSnap: true,
          password: enteredPassword,
          defaultPage: currentPage!,
          fitPolicy: FitPolicy.BOTH,
          preventLinkNavigation:
              false, // if set to true the link is handled in flutter
          onRender: (pages) {
            log('render');
            setState(() {
              pages = pages;
              isReady = true;
            });
          },
          onError: (error) {
            log('error');
            // setState(() {
            //   errorMessage = error.toString();
            // });

            log('error : $error');

            if (error.contains('password')) {
              log('error password');
              // _buildPasswordInput(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _buildPasswordInput(context),
                ),
              );
            } else {
              log('no password');
            }

            // if (error.contains('password')) {
            //   errorMessage = "Invalid password !!";
            //   _formKey.currentState?.validate();
            //   _passwordController.clear();
            //   // _buildPDFView(context);
            // } else {
            //   errorMessage = "";
            //   _buildPasswordInput(context);
            // }

            print(error.toString());
          },
          onPageError: (page, error) {
            log('PAGE error');
            setState(() {
              errorMessage = '$page: ${error.toString()}';
            });
            print('$page: ${error.toString()}');
          },
          onViewCreated: (PDFViewController pdfViewController) {
            log('VIEW CREATED');
            _controller.complete(pdfViewController);
          },
          onLinkHandler: (String? uri) {
            print('goto uri: $uri');
          },
          onPageChanged: (int? page, int? total) {
            log('PAGE CHANGED');
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
    );
  }
}
