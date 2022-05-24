// A widget that displays the picture taken by the user.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/config/dimensions_config.dart';

class DisplayCameraPictureScreen extends StatefulWidget {
  const DisplayCameraPictureScreen();

  @override
  State<DisplayCameraPictureScreen> createState() =>
      _DisplayCameraPictureScreenState();
}

class _DisplayCameraPictureScreenState
    extends State<DisplayCameraPictureScreen> {
  late String imagePath;

  @override
  void initState() {
    super.initState();

    imagePath = Get.arguments;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
      height: Dim.maxScreenHeight,
      width: Dim.maxScreenWidth,
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            _pictureView(),
            _bottomTitle(),
          ],
        ),
      ),
    );
  }

  Widget _pictureView() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(22),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _picture(),
              Align(alignment: Alignment.bottomCenter, child: _buildButtons()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _picture() {
    return Image.file(
      File(imagePath),
      fit: BoxFit.fill,
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        GestureDetector(
          onTap: (() => Get.back()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Retake",
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
            ),
          ),
        ),
        Spacer(),
        GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Save",
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomTitle() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          SizedBox(
            height: Dim.heightPercent(5),
          )
        ],
      ),
    );
  }
}
