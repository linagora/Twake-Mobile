import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/widgets/common/rounded_image.dart';

import 'workspace_title.dart';

class WorkspacesManagement extends StatelessWidget {
  const WorkspacesManagement() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            color: Colors.white70,
            child: Column(
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                        child: Text(
                          'You are in the workspace Twake Dev from the group Linagora',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          icon: Image.asset('assets/images/cancel.png'),
                          onPressed: () {}),
                    )
                  ],
                ),
                RoundedImage(
                  imageUrl: 'assets/images/oldtwakelogo.jpg',
                  width: 60.0,
                  height: 60.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Text('Twake Dev'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black12,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Icon(Icons.settings),
                            width: 50,
                            height: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Settings'),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black12,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Icon(Icons.accessibility),
                            width: 50,
                            height: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Collaborators'),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black12,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Icon(Icons.ballot),
                            width: 50,
                            height: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Integrations'),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  AddWorkspaceTile(),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return WorkspaceTile(
                          image: 'assets/images/cancel.png',
                          title: '$index',
                          selected: index == 1,
                          subtitle: '',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AddWorkspaceTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(height: 8.0),
            Row(
              children: [
                SizedBox(width: 16.0),
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xfff5f5f5),
                  ),
                  child: Image.asset('assets/images/add.png'),
                ),
                SizedBox(width: 16.0),
                Text(
                  'Create a new workspace',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Divider(
              thickness: 1.0,
              height: 1.0,
              color: Color(0xfff4f4f4),
            ),
          ],
        ),
      ),
    );
  }
}