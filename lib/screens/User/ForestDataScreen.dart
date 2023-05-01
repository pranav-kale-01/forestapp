import 'package:flutter/material.dart';

class ForestData {
  final String image;
  final String title;
  final String description;
  final String date;

  ForestData(
      {required this.image,
      required this.title,
      required this.description,
      required this.date});
}

class ForestDataScreen extends StatefulWidget {
  const ForestDataScreen({super.key});

  @override
  State<ForestDataScreen> createState() => _ForestDataScreenState();
}

class _ForestDataScreenState extends State<ForestDataScreen> {
  final List<ForestData> forestData = [
    ForestData(
        image: 'https://randomuser.me/api/portraits/men/1.jpg',
        title: 'Forest 1',
        description: 'This is the first forest.',
        date: '2023-04-30'),
    ForestData(
        image: 'https://randomuser.me/api/portraits/men/1.jpg',
        title: 'Forest 2',
        description: 'This is the second forest.',
        date: '2023-04-29'),
    ForestData(
        image: 'https://randomuser.me/api/portraits/men/1.jpg',
        title: 'Forest 3',
        description: 'This is the third forest.',
        date: '2023-04-28')
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0.0), // hide the app bar
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
          ),
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Forest Data List',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: forestData.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        children: <Widget>[
                          Image.network(forestData[index].image),
                          ListTile(
                            title: Text(forestData[index].title),
                            subtitle: Text(forestData[index].description),
                            trailing: Text(forestData[index].date),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
