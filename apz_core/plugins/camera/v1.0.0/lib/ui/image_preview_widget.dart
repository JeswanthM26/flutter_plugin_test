import "dart:typed_data";
import "package:flutter/material.dart";

/// A widget that displays a preview of the captured image and provides options
class ImagePreviewWidget extends StatelessWidget {
  ///constructor
  const ImagePreviewWidget({
    required final Uint8List imageBytes,
    required final String title,
    super.key,
  }) : _imageBytes = imageBytes,
       _title = title;

  final Uint8List _imageBytes;
  final String _title;

  @override
  Widget build(final BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Text(_title),
      centerTitle: true,
      leading: Container(), // Remove back button
    ),
    body: Column(
      children: <Widget>[
        // Image preview section
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: ClipRRect(child: Image.memory(_imageBytes)),
          ),
        ),

        // Action buttons section
        Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    key: const Key("retakeButton"),
                    iconSize: 40,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    key: const Key("doneButton"),
                    iconSize: 40,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );
}
