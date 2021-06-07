import 'package:flutter/material.dart';

class CompanySettingItemWidget extends StatelessWidget {
  const CompanySettingItemWidget() : super();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        color: Colors.white,
        child: Row(
          children: [
            SizedBox(
              width: 8,
            ),
            SizedBox(
              width: 20,
              height: 20,
              child: Icon(Icons.settings),
            ),
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('Setting item'),
                )),
            SizedBox(
              width: 20,
              height: 20,
              child: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 8,)
          ],
        ),
      ),
    );
  }
}
