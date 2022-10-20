import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/config/dimensions_config.dart';

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
                width: Dim.widthPercent(35),
                child: Image.asset(
                  'assets/images/data_sync.png',
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'We are syncing your data,',
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              Text(
                'please, be patient 😊 😕',
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: Dim.widthPercent(60),
                height: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  child: LinearProgressIndicator(
                    value: widget.progress / 100,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    color: Theme.of(context).colorScheme.surface,
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
                width: Dim.widthPercent(35),
                child: Image.asset(
                  'assets/images/data_sync_failed.png',
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text('We have encountered an issue',
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 20, fontWeight: FontWeight.w900)),
              Text('in syncing your data😔🥺',
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 20, fontWeight: FontWeight.w900)),
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
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(fontSize: 17, fontWeight: FontWeight.w600),
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
