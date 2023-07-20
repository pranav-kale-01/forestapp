import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
// import 'package:forestapp/common/models/timestamp.dart';
// import 'package:forestapp/common/models/geopoint.dart' as G;
import 'package:forestapp/utils/conflict_service.dart';
import 'package:forestapp/utils/utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

import '../../common/models/conflict_model_hive.dart';
import 'ForestDetail.dart';

class ForestDataScreen extends StatefulWidget {
  final Function(int) changeScreen;
  final String defaultFilterConflict;

  const ForestDataScreen({
    Key? key,
    required this.changeScreen,
    required this.defaultFilterConflict,
  }) : super(key: key);

  @override
  State<ForestDataScreen> createState() => _ForestDataScreenState();
}

class _ForestDataScreenState extends State<ForestDataScreen> {
  final TextEditingController _searchController = TextEditingController();

  late List<Conflict> _profileDataList = [];
  late List<Conflict> _searchResult = [];
  late List<Conflict> _baseSearchData = [];

  final Map<String, List<DropdownMenuItem<String>>> _dynamicLists = {};
  Map<String, dynamic> filterList = {};

  bool isSearchEnabled = false;

  final List<String> _dateDropdownOptions = [
    'today',
    'yesterday',
    'this Week',
    'this Month',
    'this Year',
    'all',
  ];

  String _selectedFilter = 'All';
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
    final profileDataList = await ConflictService.getData();

    // if the data is loaded from cache showing a bottom popup to user alerting
    // that the app is running in offline mode
    if( !(await hasConnection) ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading the page in Offline mode'),
        ),
      );
    }

    // fetching the list of attributes from firebase
    final docSnapshot = await FirebaseFirestore.instance.collection('dynamic_lists').get();

    for( var doc in docSnapshot.docs ) {
      List<DropdownMenuItem<String>>? tempList = [];

      for (var att in doc.get('values')) {
        tempList.add(
            DropdownMenuItem<String>(
              value: att.toString() ,
              child: Text(
                att.toString(),
                overflow: TextOverflow.ellipsis,
              ),
            )
        );
      }
      _dynamicLists[doc.id] = tempList;
    }

    _selectedRange = _dynamicLists['range']?.first.value;
    _selectedConflict = _dynamicLists['conflict']?.first.value;
    _selectedBt = _dynamicLists['bt']?.first.value?.toLowerCase();


    // if defaultFilterConflict is not null then filtering the data according to conflict
    if( widget.defaultFilterConflict.isNotEmpty ) {
      setState(() {
        _profileDataList = profileDataList;
        _searchResult = profileDataList;
        filterList['conflict'] = widget.defaultFilterConflict;
        filterData();
      });
    }
    else {
      setState(() {
        _profileDataList = profileDataList;
        _searchResult = profileDataList;
      });
    }
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


      if (Platform.isAndroid) {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        var release = androidInfo.version.release;

        if( int.parse(release) < 10 ) {
          var storagePermission = await Permission.storage.request();

          if( ! await storagePermission.isGranted ) {
            throw Exception('Storage permission not granted');
          }
        }
        else {
          var storagePermission = await Permission.manageExternalStorage;

          if( await storagePermission.isGranted ) {
            storagePermission.request();

            if( ! await storagePermission.isGranted ) {
              throw Exception('Storage permission not granted');
            }
          }
        }
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
        fileName = 'forest_data($fileCount).xls';
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
    List<Conflict> tempList = [];
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

        List<Conflict> tempList = [];
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
                    Text("Filter by Range"),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: material.Border.all(
                                  color: Colors.black45,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular( 15 ),
                              ),
                              width: 30,
                              child: Padding(
                                padding: const EdgeInsets.symmetric( horizontal: 8.0, ),
                                child: DropdownButton<String>(
                                  menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
                                  isExpanded: true,
                                  underline: Container(),
                                  value: _selectedRange, // the currently selected title
                                  items: _dynamicLists['range'],
                                  style: TextStyle(
                                    // overflow: TextOverflow.ellipsis,
                                    color: Colors.black,
                                  ),
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
                          ),
                          SizedBox(
                            width: 8,
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

                    const SizedBox(height: 16.0),

                    Text("Filter by Conflict Name"),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: material.Border.all(
                                  color: Colors.black45,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular( 15 ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric( horizontal: 8.0, ),
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedConflict, // the currently selected title
                                  items: _dynamicLists['conflict'],
                                  underline: Container(),
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
                    const SizedBox(height: 16.0),
                    Text("Filter by Beats"),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: material.Border.all(
                                  color: Colors.black45,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular( 15 ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric( horizontal: 8.0),
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedBt, // the currently selected title
                                  underline: Container(),
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
                    const SizedBox(height: 16.0),
                    Text("Filter by Date"),
                    const SizedBox(height: 8.0),

                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: material.Border.all(
                                  color: Colors.black45,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular( 15 ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric( horizontal: 8.0),
                                child: DropdownButton<String>(
                                  value: _selectedDate, // the currently selected title
                                  underline: Container(),
                                  isExpanded: true,
                                  items: _dateDropdownOptions.map((item) {
                                    return DropdownMenuItem<String>(
                                      child: Text(
                                          item.toLowerCase(),
                                          overflow: TextOverflow.ellipsis,
                                      ),
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
                  child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      ),
                  ),
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
                  )
              ),
            ),
            title: const Text(
              'Forest Data',
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
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, ),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _searchResult.length,
                    itemBuilder: (innerContext, index) {
                      final profileData = _searchResult[index];
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
                                        backgroundColor: Color.fromARGB(255,
                                            3, 8, 35), // Background color
                                        // Text Color (Foreground color)
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ForestDetail(
                                                        forestData: profileData,
                                                        currentIndex: 2,
                                                        changeIndex: widget.changeScreen,
                                                        changeData: (Conflict newData) {
                                                          setState(() {
                                                            _searchResult[index] = newData;
                                                          });
                                                        },
                                                        deleteData: (Conflict data) {
                                                          setState(() {
                                                            _searchResult.removeWhere((element) => element.id == data.id );
                                                          });
                                                        },
                                                    ),
                                            ),
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
