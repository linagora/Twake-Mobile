import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';

class SyncingDataScreen extends StatefulWidget {
  SyncingDataScreen(this.progress, {Key? key}) : super(key: key);
  final double progress;
  @override
  _SyncingDataScreenState createState() => _SyncingDataScreenState();
}

//late AnimationController _controller;

@override
void initState() {
//  _progress = 0;
}

class _SyncingDataScreenState extends State<SyncingDataScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                child: Image.asset(
                  'assets/images/data_sync.png',
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'We are syncing your data,',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w900),
              ),
              Text(
                'please, be patient 😊 😕',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w900),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  child: LinearProgressIndicator(
                    value: widget.progress / 100,
                    backgroundColor: Color(0xFFF6F6F6),
                    color: Color(0xFF004DFF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SyncDataFailed extends StatelessWidget {
  const SyncDataFailed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Try again',
                    )),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                child: FittedBox(
                  child: Image.asset(
                    'assets/images/data_sync_failed.png',
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'We have encountered an issue,',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w900),
              ),
              Text(
                'in syncing your data😔🥺',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w900),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: 220,
                height: 50,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  onPressed: () {
                    Get.find<AuthenticationCubit>().syncData();
                  },
                  child: Text(
                    'Try again',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
