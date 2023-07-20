import 'package:flutter/material.dart';
import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/screens/Admin/EditListsScreen.dart';
import 'package:forestapp/utils/conflict_service.dart';
import 'package:forestapp/utils/hive_service.dart';
import 'package:forestapp/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/home_screen_list_tile.dart';
import '../loginScreen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) changeIndex;
  final Function( String) setConflict;

  const HomeScreen({
  super.key,
  required this.setConflict,
  required this.changeIndex
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Conflict> _profileDataList = [];
  HiveService hiveService = HiveService();

  int _TotalConflictsCount = 0;

  Map<String, int> conflictsCounter = {
    'cattle injured' : 0,
    'cattle killed' : 0,
    'humans injured' : 0,
    'humans killed' : 0,
    'crop damaged' : 0,
  };

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    List<Conflict> conflictList = await ConflictService.getData();

    // if the data is loaded from cache showing a bottom popup to user alerting
    // that the app is running in offline mode
    if( !(await hasConnection) ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading the page in Offline mode'),
        ),
      );
    }

    for( var item in conflictList ) {
      if( !conflictsCounter.containsKey(item.conflict) ) {
        conflictsCounter[item.conflict] = 0;
      }

      conflictsCounter[item.conflict] = conflictsCounter[item.conflict]! + 1;
    }

    setState(() {
      _profileDataList = conflictList;
      _TotalConflictsCount = conflictList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          height: 120,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              )
          ),
        ),
        title: const Text(
          'Pench MH',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            SharedPreferences prefs =  await SharedPreferences.getInstance();
                            prefs.remove('userEmail');
                            prefs.remove('isAdmin');
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    // perform logout
                  }
                },
              ),
              // const Text("Logout"),
            ],
          ),
        ],
      ),
      body: _profileDataList.isEmpty ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Loading Data.....",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ) : Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 15),
            width: mediaQuery.size.width,
            height: mediaQuery.size.height * 0.45,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // button to edit dynamic lists
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .greenAccent.shade400, // Background color
                        // Text Color (Foreground color)
                      ),
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => EditListsScreen(
                            changeIndex: widget.changeIndex,
                          )
                          )
                        );
                      },
                      child: Text("Edit Attribute Lists")
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.setConflict( '' );
                          widget.changeIndex( 2 );
                        },
                        child: Container(
                            margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                            padding: const EdgeInsets.all(15),
                            height: mediaQuery.size.height * 0.15,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  )
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Total conflicts",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  _TotalConflictsCount.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.setConflict( 'humans injured' );
                          widget.changeIndex( 2 );
                        },
                        child: Container(
                            margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                            padding: const EdgeInsets.all(15),
                            height: mediaQuery.size.height * 0.15,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  )
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Humans Injured",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  conflictsCounter['humans injured'].toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.setConflict( 'humans killed' );
                          widget.changeIndex( 2 );
                        },
                        child: Container(
                            margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                            padding: const EdgeInsets.all(15),
                            height: mediaQuery.size.height * 0.15,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  )
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Humans Killed",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  conflictsCounter['humans killed'].toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.setConflict( 'cattle injured' );
                          widget.changeIndex( 2 );
                        },
                        child: Container(
                            margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                            padding: const EdgeInsets.all(15),
                            height: mediaQuery.size.height * 0.15,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  )
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Cattles Injured",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  conflictsCounter['cattle injured'].toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.setConflict( 'cattle killed' );
                          widget.changeIndex( 2 );
                        },
                        child: Container(
                            margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                            padding: const EdgeInsets.all(15),
                            height: mediaQuery.size.height * 0.15,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  )
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Cattles Killed",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  conflictsCounter['cattle killed'].toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.setConflict( 'crop damaged' );
                          widget.changeIndex( 2 );
                        },
                        child: Container(
                            margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                            padding: const EdgeInsets.all(15),
                            height: mediaQuery.size.height * 0.15,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  )
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Crop Damaged",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  conflictsCounter['crop damaged'].toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: mediaQuery.size.height * 0.41 ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade500,
                  blurRadius: 5,
                  offset: const Offset(1, 1),
                )
              ],
              color: Colors.white,
            ),
            alignment: Alignment.bottomCenter,
            width: mediaQuery.size.width,
            height: mediaQuery.size.height * 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric( vertical: 10.0, horizontal: 4.0),
                  child: Text(
                    "Recent",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: mediaQuery.size.height * 0.32,
                  child: RefreshIndicator(
                    onRefresh: fetchUserProfileData,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: (_profileDataList.length >= 5 ? _profileDataList.sublist(0,5) : _profileDataList).map((forestData) =>  HomeScreenListTile(
                          forestData: forestData,
                          changeIndex: widget.changeIndex,
                          deleteData: (Conflict data) {
                            setState(() {
                              _profileDataList.removeWhere((element) => element.id == data.id );
                            });
                          },
                        ),
                        ).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
