import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:twake/models/globals/globals.dart';

class ServerConfiguration extends StatefulWidget {
  final Function? onCancel;
  final Function? onConfirm;

  const ServerConfiguration({
    Key? key,
    this.onCancel,
    this.onConfirm,
  }) : super(key: key);

  @override
  _ServerConfigurationState createState() => _ServerConfigurationState();
}

class _ServerConfigurationState extends State<ServerConfiguration> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _hintServerUrl = ValueNotifier<String>('');

  @override
  void initState() {
    _controller.text = Globals.instance.host;
    _hintServerUrl.value = _controller.text;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _hintServerUrl.dispose();
    super.dispose();
  }

  void _connect() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var host = _controller.text;
    bool valid = await Globals.instance.hostSet(host);
    if (valid) {
      _hintServerUrl.value = host;
      widget.onConfirm!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: EdgeInsets.fromLTRB(
            15.0,
            5.0,
            15.0,
            65.0,
            //  Dim.heightPercent(8),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          content: Text(
            AppLocalizations.of(context)!.invalidHost,
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () {
          widget.onCancel!();
          _controller.text = Globals.instance.host;
        }),
      ),
      body: SafeArea(
        child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            behavior: HitTestBehavior.opaque,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  child: Container(
                    height: constraints.maxHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Image.asset('assets/images/server.png'),
                            SizedBox(height: 15.0),
                            Text(
                              AppLocalizations.of(context)!.serverConnectionPreference,
                              textAlign: TextAlign.center,
                              softWrap: true,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 36.0),
                            Padding(
                              padding: EdgeInsets.only(left: 16, right: 36.0),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .serverConnectionPreferenceInfo,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 0),
                              child: _buildServerUrlTextField(),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.0),
                              child: Text(
                                AppLocalizations.of(context)!.changeServerHint,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 22.0),
                              child: TextButton(
                                onPressed: () => _connect(),
                                child: Container(
                                  width: Size.infinite.width,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0xff3840f7),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    AppLocalizations.of(context)!.connect,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }

  Widget _buildServerUrlTextField() => ValueListenableBuilder(
    valueListenable: _hintServerUrl,
    builder: (BuildContext context, String hintServerUrl, Widget? child) {
      return TextFormField(
        key: _formKey,
        validator: (value) => value!.isEmpty
            ? AppLocalizations.of(context)!.blankAddressError
            : null,
        controller: _controller,
        onFieldSubmitted: (_) => _connect(),
        style: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintServerUrl,
          hintStyle: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w400,
            color: Color(0xffc8c8c8),
          ),
          alignLabelWithHint: true,
          fillColor: Color(0xfff4f4f4),
          filled: true,
          suffix: Container(
            width: 30,
            height: 25,
            padding: EdgeInsets.only(left: 10),
            child: IconButton(
              padding: EdgeInsets.all(0),
              onPressed: () => _controller.clear(),
              iconSize: 15,
              icon: Icon(CupertinoIcons.clear),
            ),
          ),
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              width: 0.0,
              style: BorderStyle.none,
            ),
          ),
        ),
      );
    }
  );
}
