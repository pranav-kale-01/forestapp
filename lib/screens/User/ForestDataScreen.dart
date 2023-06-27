import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/ConflictModel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

import 'ForestDetail.dart';

class ForestDataScreen extends StatefulWidget {
  final Function(int) changeScreen;

  const ForestDataScreen({
    Key? key,
    required this.changeScreen,
  }) : super(key: key);

  @override
  State<ForestDataScreen> createState() => _ForestDataScreenState();
}

class _ForestDataScreenState extends State<ForestDataScreen> {
  final TextEditingController _searchController = TextEditingController();

  late List<ConflictModel> _profileDataList = [];
  late List<ConflictModel> _searchResult = [];
  late List<ConflictModel> _baseSearchData = [];
  final Map<String, List<DropdownMenuItem<String>>> _dynamicLists = {};
  Map<String, dynamic> filterList = {};
  bool isSearchEnabled = false;

  final List<String> _dateDropdownOptions = [
    'today',
    'yesterday',
    'this Week',
    'this Month',
    'this Year',
  ];

  String _selectedFilter = 'this Year';
  String? _selectedRange;
  String? _selectedConflict;
  String? _selectedBt;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('forestdata').orderBy('createdAt',descending: true ).get();

    final profileDataList = userSnapshot.docs.map(
          (doc) => ConflictModel(
            id: doc.id,
            range: doc['range'],
            round: doc['round'],
            bt: doc['bt'],
            cNoName: doc['c_no_name'],
            conflict: doc['conflict'],
            notes: doc['notes'],
            person_age: doc['person_age'],
            imageUrl: doc['imageUrl'],
            userName: doc['user_name'],
            userEmail: doc['user_email'],
            person_gender: doc['person_gender'],
            pincodeName: doc['pincode_name'],
            sp_causing_death: doc['sp_causing_death'],
            village_name: doc['village_name'],
            person_name: doc['person_name'],
            datetime: doc['createdAt'] as Timestamp?,
            location: doc['location'] as GeoPoint,
            userContact: doc['user_contact'],
            userImage: doc['user_imageUrl'],
          ),
        ).toList();

    setState(() {
      _profileDataList = profileDataList;
      _searchResult = profileDataList;
    });

    // getting all possible ranges
    // fetching the list of attributes from firebase
    final docSnapshot = await FirebaseFirestore.instance.collection('dynamic_lists').get();

    for (var doc in docSnapshot.docs) {
      List<DropdownMenuItem<String>>? tempList = [];

      for (var att in doc.get('values')) {
        tempList.add(DropdownMenuItem<String>(
          value: att.toString(),
          child: Text(att.toString()),
        ));
      }
      _dynamicLists[doc.id] = tempList;
    }

    _selectedRange = _dynamicLists['range']?.first.value;
    _selectedConflict = _dynamicLists['conflict']?.first.value;
    _selectedBt = _dynamicLists['bt']?.first.value?.toLowerCase();
  }

  Future<void> exportToExcel() async {
    Directory? directory;
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // add header row
      sheet.appendRow([
        'Range',
        'Round',
        'Beat',
        'village Name'
            'CNo/S.No Name',
        'Pincode Name',
        'conflict',
        'Name',
        'Age',
        'gender',
        'SP Causing Death',
        'notes',
        'Username'
            'User Email',
        'User Contact',
        'location',
        'Created At',
      ]);

      // add data rows
      _searchResult.forEach((data) {
        sheet.appendRow([
          data.range,
          data.round,
          data.bt,
          data.village_name,
          data.cNoName,
          data.pincodeName,
          data.conflict,
          data.person_name,
          data.person_age,
          data.person_gender,
          data.sp_causing_death,
          data.notes,
          data.userName,
          data.userEmail,
          data.userContact,
          data.location,
          data.datetime,
        ]);
      });

      // save the Excel file
      final fileBytes = excel.encode();
      int fileCount = 0;

      String fileName = 'forest_data.xlsx';

      final storagePermission =
      await Permission.manageExternalStorage.request();
      if (storagePermission.isDenied || storagePermission.isRestricted) {
        openAppSettings();
      }

      if (storagePermission != PermissionStatus.granted) {
        throw Exception('Storage permission not granted');
      }
      directory = await getExternalStorageDirectory();

      String newPath = "";

      List<String> paths = directory!.path.split("/");
      for (int x = 1; x < paths.length; x++) {
        String folder = paths[x];
        if (folder != "Android") {
          newPath += "/" + folder;
        } else {
          break;
        }
      }
      newPath = newPath + "/ConflictApp/data";
      directory = Directory(newPath);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      var file = File('${directory.path}/$fileName');

      while (await file.exists()) {
        fileCount++;
        fileName = 'forest_data($fileCount).xlsx';
        file = File('${directory.path}/$fileName');
      }

      await file.writeAsBytes(fileBytes!);

      // show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Excel file saved to folder conflictApp/data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            onPressed: () async {
              //Use the path to launch the directory with the native file explorer
              await OpenFilex.open('${directory?.path}/$fileName');
            },
            label: "Open",
            textColor: Colors.black,
          ),
        ),
      );
    } catch (e) {
      // show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export to Excel failed: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _searchList(String searchQuery) {
    List<ConflictModel> tempList = [];
    _profileDataList.forEach((profileData) {
      if (profileData.village_name.toLowerCase().contains(searchQuery.toLowerCase()) || profileData.userName.toLowerCase().contains(searchQuery.toLowerCase()) || profileData.userEmail.toLowerCase().contains(searchQuery.toLowerCase())) {
        tempList.add(profileData);
      }
    });

    filterData();

    setState(() {
      _baseSearchData = tempList;
    });
  }

  void filterData() {
    try {
      if( isSearchEnabled ) {
        _searchResult = _baseSearchData;
      }
      else {
        _searchResult = _profileDataList;
      }

      if (filterList.keys.contains('range')) {
        setState(() {
          _searchResult = _searchResult
              .where((data) => data.range == filterList['range'])
              .toList();
        });
      }
      if (filterList.keys.contains('conflict')) {
        setState(() {
          _searchResult = _searchResult
              .where((data) => data.conflict == filterList['conflict'])
              .toList();
        });
      }
      if (filterList.keys.contains('beat')) {
        setState(() {
          _searchResult = _searchResult
              .where((data) => data.bt == filterList['beat'])
              .toList();
        });
      }
      if (filterList.keys.contains('date')) {
        DateTime now = DateTime.now();
        DateTime start;

        switch (filterList['date']?.toLowerCase()) {
          case 'today':
            start = DateTime(now.year, now.month, now.day);
            break;
          case 'yesterday':
            start = DateTime(now.year, now.month, now.day - 1);
            break;
          case 'this week':
            start = DateTime(now.year, now.month, now.day)
                .subtract(Duration(days: DateTime.now().weekday));
            break;
          case 'this month':
            start = DateTime(now.year, now.month, 1);
            break;
          case 'this year':
            start = DateTime(now.year, 1, 1);
            break;
          default:
            print('Invalid filter type: ${filterList['date']}');
            return;
        }

        List<ConflictModel> tempList = [];
        _searchResult.forEach((profileData) {
          if (profileData.datetime != null &&
              profileData.datetime!.toDate().isAfter(start)) {
            tempList.add(profileData);
          }
        });

        setState(() {
          _searchResult = tempList;
        });
      }
    }
    catch( e, s) {
      debugPrint( e.toString() );
      debugPrint( s.toString() );
    }
  }

  void _handleSearchFilter(String searchQuery, String filterType) {
    if (searchQuery.isNotEmpty) {
      isSearchEnabled = true;
      _searchList(searchQuery);
    } else {
      _searchResult = _profileDataList;
      isSearchEnabled = false;
      filterData();
    }
  }

  void clearDropdown(String filterAttribute) {
    if (filterAttribute == 'range') {
      _selectedRange = null;
    } else if (filterAttribute == 'conflict') {
      _selectedConflict = null;
    } else if (filterAttribute == 'beat') {
      _selectedBt = null;
    } else {
      _selectedDate = null;
    }

    setState(() {
      filterList.remove(filterAttribute);
      filterData();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text('Filter'),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    Text("Filter by Range"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRange, // the currently selected title
                                items: _dynamicLists['range'],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedRange = newValue!;
                                  });

                                  filterList['range'] = newValue!;
                                  filterData();
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              clearDropdown('range');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text("Filter by Conflict Name"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value:
                                    _selectedConflict, // the currently selected title
                                items: _dynamicLists['conflict'],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedConflict = newValue!;
                                  });
                                  filterList['conflict'] = newValue!;

                                  filterData();
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              clearDropdown('conflict');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text("Filter by Beats"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value:
                                    _selectedBt, // the currently selected title
                                items: _dynamicLists['beat'],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedBt = newValue!;
                                  });
                                  filterList['beat'] = newValue!;

                                  filterData();
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              clearDropdown('beat');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text("Filter by Date"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value:
                                    _selectedDate, // the currently selected title
                                items: _dateDropdownOptions.map((item) {
                                  return DropdownMenuItem<String>(
                                    child: Text(item.toLowerCase()),
                                    value: item.toLowerCase(),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedDate = newValue!;
                                  });

                                  filterList['date'] = newValue!.toLowerCase();
                                  filterData();
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              clearDropdown('date');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
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
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )),
            ),
            title: const Text(
              'Forest Data List',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Forest Data List',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .greenAccent.shade400, // Background color
                              // Text Color (Foreground color)
                            ),
                            onPressed: () async {
                              await exportToExcel();
                            },
                            child: Text("Export Data"))
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Search by title, user name or user email',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: _showFilterDialog,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    _handleSearchFilter(value, _selectedFilter.simplifyText());
                  },
                ),
              ),
              _searchResult.isEmpty
                  ? Text(
                      "No result found....",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    )
                  : Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _searchResult.length,
                          itemBuilder: (innerContext, index) {
                            ConflictModel profileData = _searchResult[index];
                            return Card(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 120.0,
                                    height: 120.0,
                                    child: Image.network(
                                      profileData.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                profileData.village_name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            DateFormat('MMM d, yyyy h:mm a')
                                                .format(profileData.datetime!
                                                    .toDate()),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            profileData.userName,
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            profileData.userEmail,
                                          ),
                                          const SizedBox(height: 8.0),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  255,
                                                  3,
                                                  8,
                                                  35), // Background color
                                              // Text Color (Foreground color)
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ForestDetail(
                                                            forestData: profileData,
                                                            changeIndex: widget.changeScreen,
                                                            currentIndex: 1,
                                                            changeData: (ConflictModel newData) {

                                                              setState(() {
                                                                _searchResult[index] = newData;
                                                              });
                                                            },
                                                            deleteData: (ConflictModel data) {
                                                              setState(() {
                                                                _searchResult.removeWhere((element) => element.id == data.id );
                                                              });
                                                            },
                                                          )
                                                  )
                                              );
                                            },
                                            label: const Text("View"),
                                            icon: const Icon(
                                                Icons.arrow_right_alt_outlined),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ));
  }
}
