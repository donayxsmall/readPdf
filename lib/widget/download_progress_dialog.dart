import 'package:flutter/material.dart';

class DownloadProgressDialog extends StatelessWidget {
  final double progress;

  const DownloadProgressDialog({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Downloading'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${progress.toStringAsFixed(2)}%'),
          const SizedBox(height: 20),
          LinearProgressIndicator(value: progress / 100),
        ],
      ),
    );
  }
}
