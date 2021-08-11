import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';

class FileTile extends StatelessWidget {
  final String fileId;

  const FileTile({required this.fileId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Get.find<FileCubit>().getById(id: fileId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null) {
              return Text('Old file format is not supported');
            }
            final file = (snapshot.data as File);
            InlineSpan text;
            text = TextSpan(
              text: file.name,
              style: TextStyle(fontStyle: FontStyle.italic),
            );
            return Container(
              margin: EdgeInsets.all(4),
              padding: EdgeInsets.all(3),
              child: Row(children: [
                InkWell(
                  child: SizedBox(
                    child: file.preview != null && file.preview!.isNotEmpty
                        ? ClipRRect(
                            child: Image.network(file.preview!),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          )
                        : CircleAvatar(
                            child: Icon(Icons.cloud_download),
                            backgroundColor: Colors.indigo[100],
                          ),
                    width: 40,
                    height: 40,
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  // fit: FlexFit.tight,
                  child: Column(
                    children: [
                      RichText(
                        text: text,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        // softWrap: true,
                      ),
                      Text(
                        file.sizeStr,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: Color(0xff8e8e93)),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              ]),
            );
          } else {
            return LinearProgressIndicator();
          }
        });
  }
}
