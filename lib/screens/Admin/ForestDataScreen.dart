import 'package:flutter/material.dart';

class ForestDataScreen extends StatelessWidget {
  final List<ForestData> forestDataList = [
    ForestData(
      location: 'Yosemite National Park',
      title: 'El Capitan',
      description:
          'El Capitan is a vertical rock formation in Yosemite National Park, located on the north side of Yosemite Valley, near its western end. The granite monolith extends about 3,000 feet (900 meters) from base to summit along its tallest face and is one of the world\'s favorite challenges for rock climbers.',
      userName: 'John Doe',
      dateTime: DateTime.now(),
      image: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    ForestData(
      location: 'Yellowstone National Park',
      title: 'Old Faithful',
      description:
          'Old Faithful is a cone geyser in Yellowstone National Park in Wyoming, United States. It was named in 1870 during the Washburn-Langford-Doane Expedition and was the first geyser in the park to receive a name. It is one of the most predictable geysers, erupting almost every 90 minutes.',
      userName: 'Jane Smith',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      image: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    ForestData(
      location: 'Redwood National Park',
      title: 'Tall Trees Grove',
      description:
          'Tall Trees Grove is a nature reserve and hiking area in Del Norte County, California. The grove is part of the Redwood National and State Parks system and is home to some of the tallest trees in the world, including Hyperion, the world\'s tallest known living tree.',
      userName: 'Bob Johnson',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      image: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
  ];

  ForestDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Forest Data'),
        // ),
        body: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'Forest Data',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: forestDataList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: Text(forestDataList[index].title),
                      subtitle: Text(forestDataList[index].location),
                      // leading: CircleAvatar(
                      //   backgroundImage:
                      //       NetworkImage(forestDataList[index].image),
                      // ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(forestDataList[index].dateTime.toString()),
                          const SizedBox(height: 5),
                          Text('Added by ${forestDataList[index].userName}'),
                        ],
                      ),
                      onTap: () {
                        // Navigate to detail screen
                      },
                    ),
                  );
                },
              ),
            )
          ]),
    ));
  }
}

class ForestData {
  final String location;
  final String title;
  final String description;
  final String userName;
  final DateTime dateTime;
  final String image;

  ForestData({
    required this.location,
    required this.title,
    required this.description,
    required this.userName,
    required this.dateTime,
    required this.image,
  });
}
