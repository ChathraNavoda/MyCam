// pages/home_page.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final picker = ImagePicker();
  File? _imageFile;
  String? _savedImagePath;

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  Future<void> _saveImage() async {
    if (_imageFile == null) {
      return;
    }
    final bytes = await _imageFile!.readAsBytes();
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));
    setState(() {
      _savedImagePath = result['filePath'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_savedImagePath != null
            ? 'Image saved successfully!'
            : 'Failed to save image'),
      ),
    );
  }

  Future<void> _copyPath() async {
    if (_savedImagePath == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: _savedImagePath!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image path copied to clipboard!'),
      ),
    );
  }

  Widget _buildImage() {
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
      );
    } else {
      return const Placeholder(
        fallbackHeight: 200.0,
        fallbackWidth: double.infinity,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 150,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.camera_alt),
                            title: Text('Take a new photo'),
                            onTap: () {
                              _getImage(ImageSource.camera);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text('Choose from gallery'),
                            onTap: () {
                              _getImage(ImageSource.gallery);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: CircleAvatar(
                radius: 80.0,
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Icon(
                        Icons.camera_alt,
                        size: 50.0,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveImage,
              child: Text('Save to Gallery'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _copyPath,
              child: Text('Get image path'),
            ),
          ],
        ),
      ),
    );
  }
}
