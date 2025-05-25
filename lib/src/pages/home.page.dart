import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Performance tracker'),
        ),
        body: Text('another body'),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Colors.blue,
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
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
        ),
      ),
      
    );
  }
}