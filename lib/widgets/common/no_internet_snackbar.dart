import 'package:flutter/material.dart';
import 'package:twake/blocs/connection_bloc.dart' as cb;

void connectionListener(BuildContext ctx, cb.ConnectionState state) {
  Scaffold.of(ctx).hideCurrentSnackBar();
  if (state is cb.ConnectionLost) {
    Scaffold.of(ctx).showSnackBar(
      SnackBar(
        padding: EdgeInsets.zero,
        duration: Duration(days: 365),
        backgroundColor: Colors.yellow[900],
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Waiting for internet',
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(width: 15.0),
            Icon(
              Icons.timer_rounded,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}
