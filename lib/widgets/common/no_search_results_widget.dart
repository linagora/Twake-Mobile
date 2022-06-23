import 'package:flutter/material.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/widgets/common/button_text_builder.dart';

class NoSearchResultsWidget extends StatelessWidget {
  final String searchTerm;
  final Function onResetTap;

  const NoSearchResultsWidget(
      {Key? key, required this.searchTerm, required this.onResetTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        children: [
          Image.asset(
            imageSearchFace,
          ),
          SizedBox(
            height: 16,
          ),
          if (searchTerm.length > 0)
            Text("There were no results for “$searchTerm”. Try a new search",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 17, fontWeight: FontWeight.w400)),
          if (searchTerm.length == 0)
            Text("There were no results",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 17, fontWeight: FontWeight.w400)),
          SizedBox(
            height: 16,
          ),
          if (searchTerm.length > 0)
            FractionallySizedBox(
              widthFactor: 0.6,
              child: ButtonTextBuilder(Key('button_reset_search'),
                      onButtonClick: () => onResetTap(),
                      backgroundColor: Theme.of(context).colorScheme.surface)
                  .setText('Reset search')
                  .setHeight(44)
                  .setBorderRadius(BorderRadius.all(Radius.circular(14)))
                  .build(),
            )
        ],
      ),
    );
  }
}
