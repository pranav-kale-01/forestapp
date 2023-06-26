import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/ConflictModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/home_screen_list_tile.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) changeIndex;

  const HomeScreen({
    super.key,
    required this.changeIndex
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _userEmail;
  late List<ConflictModel> _profileDataList = [];

  int _TotalConflictsCount = 0;
  int _humansInjuredCount = 0;
  int _cattleInjuredCount = 0;
  int _cropDamagedCount = 0;
  int _humansKilledCount = 0;
  int _cattleKilledCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    getTotalDocumentsCount().then((value) {
      setState(() {
        // _count = value;
      });
    });
    getTotalDocumentsCountUser().then((value) {});
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    setState(() {
      _userEmail = userEmail ?? '';
    });
    fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    _TotalConflictsCount = 0;
    _humansInjuredCount = 0;
    _cattleInjuredCount = 0;
    _cropDamagedCount = 0;
    _humansKilledCount = 0;
    _cattleKilledCount = 0;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('forestdata')
        .where('user_email', isEqualTo: _userEmail)
        .orderBy('createdAt', descending: true)
        .get();

    final List<ConflictModel> profileDataList = [];

    for( var item in userSnapshot.docs ) {
      if (item['conflict'] == 'cattle injured') {
        _cattleInjuredCount += 1;
      }
      else if (item['conflict'] == 'cattle killed') {
        _cattleKilledCount += 1;
      }
      else if (item['conflict'] == 'humans injured') {
        _humansInjuredCount += 1;
      }
      else if (item['conflict'] == 'humans killed') {
        _humansKilledCount += 1;
      }
      else if (item['conflict'] == 'crop damaged') {
        _cropDamagedCount += 1;
      }
    }

    int count = 0;
    for( var item in userSnapshot.docs ) {
      if( count >= 5 ) {
        break;
      }

      profileDataList.add(
          ConflictModel(
              id: item.id,
              range: item['range'],
              round: item['round'],
              bt: item['bt'],
              cNoName: item['c_no_name'],
              conflict: item['conflict'],
              notes: item['notes'],
              person_age: item['person_age'],
              imageUrl: item['imageUrl'],
              userName: item['user_name'],
              userEmail: item['user_email'],
              person_gender: item['person_gender'],
              pincodeName: item['pincode_name'],
              sp_causing_death: item['sp_causing_death'],
              village_name: item['village_name'],
              person_name: item['person_name'],
              datetime: item['createdAt'] as Timestamp?,
              location: item['location'] as GeoPoint,
              userContact: item['user_contact'],
              userImage: item['user_imageUrl'],
          )
      );

      count += 1;
    }

    setState(() {
      _profileDataList = profileDataList;
      _TotalConflictsCount = userSnapshot.size;
    });
  }

  Future<int> getTotalDocumentsCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('forestdata')
        // .where('user_email', isEqualTo: _userEmail)
        // .orderBy('createdAt', descending: true)
        .get();
    return snapshot.size;
  }

  Future<int> getTotalDocumentsCountUser() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.size;
  }


  final CollectionReference users = FirebaseFirestore.instance.collection('users');

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
            height: mediaQuery.size.height * 0.4,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
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
                    Expanded(
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
                              _humansInjuredCount.toString(),
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                    Expanded(
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
                              _humansKilledCount.toString(),
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
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
                              _cattleInjuredCount.toString(),
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                    Expanded(
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
                              _cattleKilledCount.toString(),
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                    Expanded(
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
                              "Crop Damage",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              _cropDamagedCount.toString(),
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: mediaQuery.size.height * 0.36 ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Colors.white,
            ),
            alignment: Alignment.bottomCenter,
            width: mediaQuery.size.width,
            height: mediaQuery.size.height * 0.5,
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
                  height: mediaQuery.size.height * 0.37,
                  child: RefreshIndicator(
                    onRefresh: fetchUserProfileData,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: _profileDataList.map((forestData) =>  HomeScreenListTile(
                            forestData: forestData,
                            changeIndex: widget.changeIndex,
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
