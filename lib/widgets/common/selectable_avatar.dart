import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelectableAvatar extends StatefulWidget {
  @override
  _SelectableAvatarState createState() => _SelectableAvatarState();
}

class _SelectableAvatarState extends State<SelectableAvatar> {
  final picker = ImagePicker();

  File _image;
  // String _base64Image;
  Uint8List _bytes;

  Future _getImage() async {
    final image = await picker.getImage(source: ImageSource.gallery);
    image.readAsBytes().then((bytes) {
      String base64Image = base64Encode(bytes);
      setState(() {
        _image = File(image.path);
        // _base64Image = base64Image;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 48,
        height: 48,
        child: _bytes != null
            ? SizedBox()
            : (_image != null
            ? Image.file(_image)
            : Image.asset("assets/images/pic.png")),
        decoration: _bytes != null
            ? BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: MemoryImage(
              _bytes,
            ),
            fit: BoxFit.fill,
          ),
        )
            : BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
      ),
      onTap: null, //_getImage,
    );
  }
}
