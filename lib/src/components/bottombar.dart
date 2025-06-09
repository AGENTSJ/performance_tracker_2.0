import 'package:flutter/material.dart';
import 'package:performance_tracker/src/constants.ui.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: PRIMARY,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              tooltip: 'Open navigation menu',
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
            IconButton(tooltip: 'Search', icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(tooltip: 'Favorite', icon: const Icon(Icons.favorite), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
