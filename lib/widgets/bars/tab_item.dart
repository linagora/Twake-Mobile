import 'package:flutter/material.dart';

class TabItem {
  static BottomNavigationBarItem bottomBarItem(
      String activeIconName,
      String disabledIconName,
      String title,
      Color textColor,
      ) {
    return BottomNavigationBarItem(
      activeIcon: ImageIcon(
        AssetImage(activeIconName),
      ),
      icon: ImageIcon(
        AssetImage(disabledIconName),
      ),
      label: title,
      // title: Text(
      //   title,
      //   style: TextStyle(
      //     color: textColor,
      //   ),
      // ),
    );
  }
}