import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/widgets/common/rounded_image.dart';

import 'add_workspace_tile.dart';
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
                          icon: Image.asset(imagePathCancel), onPressed: () {}),
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
                          image: imagePathCancel,
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
