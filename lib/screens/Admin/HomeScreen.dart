import 'package:flutter/material.dart';
import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/contstant/constant.dart';
import 'package:forestapp/screens/Admin/EditListsScreen.dart';
import 'package:forestapp/utils/conflict_service.dart';
import 'package:forestapp/utils/hive_service.dart';
import 'package:forestapp/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/home_screen_list_tile.dart';
import '../loginScreen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) changeIndex;
  final Function(Map<String,dynamic>) setConflict;

  const HomeScreen(
      {super.key, required this.setConflict, required this.changeIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Conflict> _profileDataList = [];
  HiveService hiveService = HiveService();
  late Future<void> _future;

  int _TotalConflictsCount = 0;

  Map<String, dynamic> conflictsCounter = {};

  @override
  void initState() {
    super.initState();
    _future = init();
  }

  Future<void> init() async {
    await fetchConflicts();
  }

  Future<void> fetchConflicts() async {
    conflictsCounter = {
      'cattle injured': 0,
      'cattle killed': 0,
      'humans injured': 0,
      'humans killed': 0,
      'crop damaged': 0,
      'total_conflicts': 0
    };

    // if the data is loaded from cache showing a bottom popup to user alerting
    // that the app is running in offline mode
    if (!(await hasConnection)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading the page in Offline mode'),
        ),
      );
    }
    else {

      // getting the count of conflicts
      conflictsCounter = await ConflictService.getCounts(context);

      // for (Map<String, dynamic> conflict in conflictCounts.reversed) {
      //   _TotalConflictsCount += int.parse(conflict['count']);
      //
      //   conflictsCounter[conflict['conflict_name'].toLowerCase()] =
      //       int.parse(conflict['count']);
      // }

      // getting the recent entries
      List<Conflict> conflictList = await ConflictService.getRecentEntries(context);

      setState(() {
        _profileDataList = conflictList;
      });
    }
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
              )),
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
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.remove(SHARED_USER_EMAIL);
                            prefs.remove(SHARED_USER_TYPE);
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
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if( snapshot.connectionState == ConnectionState.waiting ) {
            return Center(
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
            );
          }
          else {
            return Stack(
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
                              backgroundColor:
                              Colors.greenAccent.shade400, // Background color
                              // Text Color (Foreground color)
                            ),
                            onPressed: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditListsScreen(
                                    changeIndex: widget.changeIndex,
                                  )));
                            },
                            child: Text("Edit Attribute Lists")),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget.setConflict({});
                                widget.changeIndex(2);
                              },
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
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
                                      ]),
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
                                        conflictsCounter.containsKey('total_conflicts') ? conflictsCounter['total_conflicts'].toString() : "0",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget.setConflict({"name": 'humans injured', "id": ""});
                                widget.changeIndex(2);
                              },
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
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
                                      ]),
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
                                        conflictsCounter.containsKey('humans injured') ? conflictsCounter['humans injured'].toString() : "0",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget.setConflict({"name": 'humans killed', "id": ""});
                                widget.changeIndex(2);
                              },
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
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
                                      ]),
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
                                        conflictsCounter.containsKey('humans killed') ? conflictsCounter['humans killed'].toString() : "0",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget.setConflict({"name": 'cattle injured', "id": ""});
                                widget.changeIndex(2);
                              },
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
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
                                      ]),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Cattle Injured",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        conflictsCounter.containsKey('cattle injured') ? conflictsCounter['cattle injured'].toString() : "0",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget.setConflict({"name": 'cattle killed', "id": ""});
                                widget.changeIndex(2);
                              },
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
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
                                      ]),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Cattle Killed",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        conflictsCounter.containsKey('cattle killed') ? conflictsCounter['cattle killed'].toString() : "0",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget.setConflict({"name": 'crop damaged', "id": ""});
                                widget.changeIndex(2);
                              },
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
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
                                      ]),
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
                                        conflictsCounter.containsKey('crop damaged') ? conflictsCounter['crop damaged'].toString() : "0",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: mediaQuery.size.height * 0.41),
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
                  height: mediaQuery.size.height * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        width: mediaQuery.size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 12.0),
                        child: Text(
                          "Recent",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _profileDataList.isEmpty
                          ? Expanded(
                        child: Center(
                          child: Text(
                            "No data found",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                          : SizedBox(
                        height: mediaQuery.size.height * 0.32,
                        child: RefreshIndicator(
                          onRefresh: fetchConflicts,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: (_profileDataList.length >= 5
                                  ? _profileDataList.sublist(0, 5)
                                  : _profileDataList)
                                  .map(
                                    (forestData) => HomeScreenListTile(
                                  isAdmin: true,
                                  forestData: forestData,
                                  changeIndex: widget.changeIndex,
                                  deleteData: (Conflict data) {
                                    setState(() {
                                      _profileDataList.removeWhere(
                                              (element) =>
                                          element.id == data.id);
                                    });
                                  },
                                ),
                              )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
