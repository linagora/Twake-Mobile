import 'package:flutter/material.dart';

class CompanyTile extends StatelessWidget {
  final bool isSelected;
  final String logo;
  final int messageCount;

  const CompanyTile({required this.isSelected, required this.logo, required this.messageCount}) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Container(
                        color: Colors.redAccent,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: ClipOval(
                    child: SelectedWidget(
                      isSelected: isSelected,
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }
}

class SelectedWidget extends StatelessWidget {
  final bool isSelected;

  const SelectedWidget({required this.isSelected}) : super();

  @override
  Widget build(BuildContext context) {
    return this.isSelected ? ClipOval(
      child: Container(
        width: 20,
        height: 20,
        color: Colors.blueAccent,
        child: SizedBox.shrink(),
      ),
    ) : Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blueGrey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: SizedBox.shrink()
    );
  }
}

