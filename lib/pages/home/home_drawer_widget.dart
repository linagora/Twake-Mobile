import 'package:flutter/material.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/widgets/common/rounded_image.dart';

class HomeDrawerWidget extends StatelessWidget {
  const HomeDrawerWidget() : super();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 32,
            ),
            Container(
              height: 70,
              child: Stack(
                children: [
                  Positioned(
                      left: 16, child: RoundedImage(width: 56, height: 56)),
                  Positioned.fill(
                    left: 82,
                    top: 12,
                    child: Column(
                      children: [
                        Align(
                          child: Text("Linagora Rus \nCompany. Consulting.",
                              maxLines: 2,
                              style: TextStyle(
                                color: Color(0xff000000),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                              )),
                          alignment: Alignment.topLeft,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        GestureDetector(
                          onTap: () {
                            //todo switch organization
                          },
                          child: Row(
                            children: [
                              Text("Switch organisation",
                                  style: TextStyle(
                                    color: Color(0xff004dff),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.normal,
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  size: 8,
                                  color: Color(0xff004dff),
                                ),
                              ),
                              Expanded(child: SizedBox.shrink())
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Text("WORKSPACES",
                    style: TextStyle(
                      color: Color(0x59000000),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                    )),
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.separated(
                  separatorBuilder: (_, __) => SizedBox(height: 16,),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return WorkspaceDrawerTile(isSelected: index == 0,);
                    }),
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_sharp,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text("Add a new workspace",
                          style: TextStyle(
                            color: Color(0xff000000),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      RoundedImage(
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text("Diana Potokina",
                          style: TextStyle(
                            color: Color(0xff000000),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(Icons.arrow_forward_ios_sharp,
                            size: 10, color: Colors.black),
                      ),
                      Expanded(child: SizedBox.shrink())
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

typedef OnWorkspaceDrawerTileTap = void Function();

class WorkspaceDrawerTile extends StatelessWidget {
  final bool isSelected;
  final OnWorkspaceDrawerTileTap? onWorkspaceDrawerTileTap;

  const WorkspaceDrawerTile({required this.isSelected, this.onWorkspaceDrawerTileTap}) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      child: Stack(
        children: [
          Positioned(
              child: isSelected ? Image.asset(
                      imageSelectedTile,
                      width: 6,
                      height: 44,
                    )
                  : SizedBox.shrink()),
          Positioned(left: 16, child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: isSelected ? Color(0xff004dff) : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12))
              ),
              child: RoundedImage(width: 44, height: 44, borderRadius: BorderRadius.circular(12),))),
          Positioned.fill(
              left: 76,
              top: 8,
              child: Text("Twake Dev",
                  style: TextStyle(
                    color: Color(0xff000000),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                  )))
        ],
      ),
    );
  }
}
