import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/utils/conflict_service.dart';
import 'package:forestapp/utils/dynamic_list_service.dart';
import 'package:forestapp/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

import 'ForestDetail.dart';

class ForestDataScreen extends StatefulWidget {
  final String userEmail;
  final Function(int) changeScreen;
  final Map<String, dynamic> defaultFilterConflict;

  const ForestDataScreen({
    Key? key,
    required this.userEmail,
    required this.changeScreen,
    required this.defaultFilterConflict,
  }) : super(key: key);

  @override
  State<ForestDataScreen> createState() => _ForestDataScreenState();
}

class _ForestDataScreenState extends State<ForestDataScreen> {
  final TextEditingController _searchController = TextEditingController();

  final Map<String, List<DropdownMenuItem<Map<String, dynamic>>>>
      _dynamicLists = {};
  Map<String, dynamic> filterList = {};
  late List<Conflict> _profileDataList = [];
  List<String> _villages = [];
  late List<Conflict> _searchResult = [];
  late List<Conflict> _baseSearchData = [];
  bool isSearchEnabled = false;
  late Future<void> _future;

  final List<String> _dateDropdownOptions = [
    'today',
    'yesterday',
    'this Week',
    'this Month',
    'this Year',
    'all'
  ];

  String _selectedFilter = 'All';
  Map<String, dynamic>? _selectedRange;
  Map<String, dynamic>? _selectedConflict;
  Map<String, dynamic>? _selectedRound;
  Map<String, dynamic>? _selectedBt;
  String? _selectedDate;
  List<String> villages = [
    "Usaripar, Ramtek",
    "Kadbhikheda, Ramtek",
    "Sawra, Ramtek",
    "Kamtee, Ramtek",
    "Dongartal, Ramtek",
    "Zinzaria, Ramtek",
    "Khapa, Ramtek",
    "Sillari, Ramtek",
    "Pipariya, Ramtek",
    "Salai, Ramtek",
    "Chatgaon, Ramtek",
    "Hiwra, Ramtek",
    "Mundi, Ramtek",
    "Ghoti, Ramtek",
    "Sahapur, Ramtek",
    "Dahoda, Ramtek",
    "Tuyapar, Ramtek",
    "Jamuniya, Ramtek",
    "Patharai, Ramtek",
    "Ambazari, Ramtek",
    "Borda, Ramtek",
    "Sarakha, Ramtek",
    "Kirangisarra, Parseoni",
    "Kolitmara, Parseoni",
    "Surera, Parseoni",
    "Banera, Parseoni",
    "Narhar, Parseoni",
    "Dhawalpur, Parseoni",
    "Sawangi, Parseoni",
    "Ghatkukda, Parseoni",
    "Pardi, Parseoni",
    "Gargoti, Parseoni",
    "Saleghat, Parseoni",
    "Suwardhara, Parseoni",
    "Siladevi, Perseoni",
    "Chargaon, Perseoni",
    "Makardhokda, Perseoni",
    "Ambazari, Perseoni",
    "Ghatpendhri, Perseoni"
  ];
  String? selectedVillage;

  @override
  void initState() {
    super.initState();
    _future = fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    final profileDataList = await ConflictService.getData(context, userEmail: widget.userEmail);

    // if the data is loaded from cache showing a bottom popup to user alerting
    // that the app is running in offline mode
    if (!(await hasConnection)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading the page in Offline mode'),
        ),
      );
    }

    // fetching the list of attributes
    final dynamicItems = await DynamicListService.fetchDynamicLists(context);
    for (var item in dynamicItems.keys) {
      _dynamicLists.addAll({
        item: dynamicItems[item]
            .map<DropdownMenuItem<Map<String, dynamic>>>(
              (Map<String, dynamic> e) =>
                  DropdownMenuItem<Map<String, dynamic>>(
                child: Text(e['name']),
                value: e,
              ),
            ).toList(),
      });
    }

    // disabling setting the first value as default
    // _selectedRange = _dynamicLists['range']?.first.value;
    // _selectedConflict = _dynamicLists['conflict']?.first.value;
    // _selectedRound = _dynamicLists['round']?.first.value;
    // _selectedBt = _dynamicLists['bt']?.first.value;

    // if defaultFilterConflict is not null then filtering the data according to conflict
    if (widget.defaultFilterConflict.isNotEmpty) {
      setState(() {
        _profileDataList = profileDataList;
        _searchResult = profileDataList;
        filterList['conflict'] = widget.defaultFilterConflict;
        filterData();
      });
    } else {
      setState(() {
        _profileDataList = profileDataList;
        _searchResult = profileDataList;
      });
    }
  }

  void _searchList(String searchQuery) {
    searchQuery = searchQuery.trim();

    List<Conflict> tempList = [];
    _profileDataList.forEach((profileData) {
      if (profileData.village_name
              .trim()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          profileData.userName
              .trim()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          profileData.userEmail
              .trim()
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
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
      if (isSearchEnabled) {
        _searchResult = _baseSearchData;
      } else {
        _searchResult = _profileDataList;
      }

      if (filterList.keys.contains('range')) {
        setState(() {
          _searchResult = _searchResult
              .where((data) =>
                  data.range.toLowerCase() ==
                  filterList['range']['name'].toLowerCase())
              .toList();
        });
      }
      if (filterList.keys.contains('conflict')) {
        setState(() {
          _searchResult = _searchResult
              .where((data) =>
                  data.conflict.toLowerCase() ==
                  filterList['conflict']['name'].toLowerCase())
              .toList();
        });
      }
      if (filterList.keys.contains('round')) {
        setState(() {
          _searchResult = _searchResult
              .where((data) =>
                  data.round.toLowerCase() ==
                  filterList['round']['name'].toLowerCase())
              .toList();
        });
      }
      if (filterList.keys.contains('beat')) {
        setState(() {
          _searchResult = _searchResult
              .where((data) =>
                  data.bt.toLowerCase() ==
                  filterList['beat']['name'].toLowerCase())
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
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  void _handleSearchFilter(String searchQuery, String filterType) {
    if (searchQuery.isNotEmpty) {
      isSearchEnabled = true;
      _searchList(searchQuery);
    } else {
      setState(() {
        _searchResult = _profileDataList;
        isSearchEnabled = false;
      });

      filterData();
    }
  }

  void clearDropdown(String filterAttribute) {
    if (filterAttribute == 'range') {
      _selectedRange = null;
    } else if (filterAttribute == 'conflict') {
      _selectedConflict = null;
    } else if (filterAttribute == 'round') {
      _selectedRound = null;
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
                                borderRadius: BorderRadius.circular(15),
                              ),
                              width: 30,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: DropdownButton<Map<String, dynamic>>(
                                  menuMaxHeight:
                                      MediaQuery.of(context).size.height * 0.5,
                                  isExpanded: true,
                                  underline: Container(),
                                  value:
                                      _selectedRange, // the currently selected title
                                  items: _dynamicLists['range'],
                                  style: TextStyle(
                                    // overflow: TextOverflow.ellipsis,
                                    color: Colors.black,
                                  ),
                                  onChanged: (Map<String, dynamic>? newValue) {
                                    setState(() {
                                      _selectedRange = newValue!;
                                    });

                                    filterList['range'] = newValue!;
                                    // setting the list of beats based on selected range
                                    filterData();

                                    _selectedRound = _dynamicLists['round']
                                        ?.where((DropdownMenuItem round) =>
                                            round.value['range_id'] ==
                                            _selectedRange!['id'])
                                        .map((e) => e.value)
                                        .toList()
                                        .first;
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
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text("Filter by Rounds"),
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
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: DropdownButton<Map<String, dynamic>>(
                                  isExpanded: true,
                                  value:
                                      _selectedRound, // the currently selected title
                                  underline: Container(),
                                  items: _selectedRange == null
                                      ? []
                                      : _dynamicLists['round']
                                          ?.where((DropdownMenuItem round) =>
                                              round.value['range_id'] ==
                                              _selectedRange!['id'])
                                          .toList(),
                                  onChanged: (Map<String, dynamic>? newValue) {
                                    setState(() {
                                      _selectedRound = newValue!;
                                    });
                                    filterList['round'] = newValue!;

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
                              setState(() {
                                clearDropdown('round');
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text("Filter by Status"),
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
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: DropdownButton<Map<String, dynamic>>(
                                  isExpanded: true,
                                  value:
                                      _selectedConflict, // the currently selected title
                                  items: _dynamicLists['conflict'],
                                  underline: Container(),
                                  onChanged: (Map<String, dynamic>? newValue) {
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
                              setState(() {
                                clearDropdown('conflict');
                              });
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
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: DropdownButton<String>(
                                  value:
                                      _selectedDate, // the currently selected title
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

                                    filterList['date'] =
                                        newValue!.toLowerCase();
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
                              setState(() {
                                clearDropdown('date');
                              });
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
                        color: Colors.black, fontWeight: FontWeight.bold),
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
                          backgroundColor:
                              Colors.greenAccent.shade400, // Background color
                          // Text Color (Foreground color)
                        ),
                        onPressed: () async {
                          if (await hasConnection) {
                            await ConflictService.exportToExcel(
                                _searchResult, context);
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Error'),
                                content:
                                    Text('Cannot export data in offline mode'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: Text("Export Data"))
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == "") {
                  return const Iterable<String>.empty();
                } else {
                  List<String> matches = <String>[];
                  matches.addAll(villages);

                  matches.retainWhere((s) {
                    return s
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });

                  return matches;
                }
              },
              onSelected: (String value) {
                _handleSearchFilter( value, _selectedFilter.simplifyText());

              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController searchController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    focusNode: focusNode,
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
                    onChanged: (String value) {
                      _handleSearchFilter( value, _selectedFilter.simplifyText());

                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
          FutureBuilder(
              future: _future,
              builder: (futureContext, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    ),
                  );
                } else {
                  return _searchResult.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Text(
                              "No result found....",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
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
                                Conflict profileData = _searchResult[index];
                                return Card(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 120.0,
                                        height: 120.0,
                                        child: Image.network(
                                          '${baseUrl}uploads/conflicts/${profileData.imageUrl}',
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    profileData.village_name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                DateFormat('MMM d, yyyy h:mm a')
                                                    .format(profileData
                                                        .datetime!
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
                                                                forestData:
                                                                    profileData,
                                                                changeIndex: widget
                                                                    .changeScreen,
                                                                currentIndex: 2,
                                                                changeData:
                                                                    (Conflict
                                                                        newData) {
                                                                  setState(() {
                                                                    _searchResult[
                                                                            index] =
                                                                        newData;
                                                                  });
                                                                },
                                                                deleteData:
                                                                    (Conflict
                                                                        data) {
                                                                  setState(() {
                                                                    _searchResult.removeWhere((element) =>
                                                                        element
                                                                            .id ==
                                                                        data.id);
                                                                  });
                                                                },
                                                              )));
                                                },
                                                label: const Text("View"),
                                                icon: const Icon(Icons
                                                    .arrow_right_alt_outlined),
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
                        );
                }
              })
        ],
      ),
    ));
  }

  @override
  void dispose() {
    //clearing the filter list
    filterList.clear();
    super.dispose();
  }
}
