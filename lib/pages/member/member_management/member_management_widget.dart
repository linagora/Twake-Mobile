import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/widgets/common/rounded_image.dart';
import 'package:twake/widgets/common/rounded_widget.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

class MemberManagementWidget extends StatelessWidget {
  const MemberManagementWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // dismiss keyboard when tap outside
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          bottom: false,
          child: Container(
            color: Color(0xfff2f2f6),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  height: 56,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoButton(
                            onPressed: () => popBack(),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xff004dff),
                            )),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                            onPressed: () {}, 
                          child: Icon(Icons.settings, color: Color(0xff004dff),),),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Member management',
                            style: TextStyle(
                              color: Color(0xff000000),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                            ),
                          ))
                    ],
                  ),
                ),
                Divider(
                  color: Color(0x1e000000),
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 16, bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('CHANNEL MEMBERS (4)',
                        style: TextStyle(
                          color: Color(0xff969ca4),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                  child: TwakeSearchTextField(
                    hintText: 'Search for members',
                    backgroundColor: Color(0xfff9f8f9),
                  ),
                ),

                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: RoundedWidget(
                                      borderRadius: 17,
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        color: Color(0x14969ca4),
                                        child: Icon(
                                          Icons.add,
                                          color: Color(0xff004dff),
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text("Add a member",
                                      style: TextStyle(
                                        color: Color(0xff004dff),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                      ))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 46.0),
                              child: Divider(
                                color: Color(0x1e000000),
                                height: 1,
                              ),
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              separatorBuilder: (_, __) => Padding(
                                padding: const EdgeInsets.only(left: 46.0),
                                child: Divider(
                                  color: Color(0x1e000000),
                                  height: 1,
                                ),
                              ),
                              itemCount: 5,
                              itemBuilder: (ctx, index) {
                                return _MemberManagementTile();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberManagementTile extends StatelessWidget {
  const _MemberManagementTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: RoundedImage(
              width: 34,
              height: 34,
            ),
          ),
          Expanded(
            child: Text('Diana Potokina',
                style: TextStyle(
                  color: Color(0xff000000),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                )),
          )
        ],
      ),
    );
  }
}
