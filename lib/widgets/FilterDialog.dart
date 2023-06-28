import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';

import '../common/models/ConflictModel.dart';

class FilterDialog extends StatefulWidget {
  late List<ConflictModel> profileDataList = [];
  final material.VoidCallback updateState;

  FilterDialog({
    Key? key,
    required this.profileDataList,
    required this.updateState
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late List<ConflictModel> _searchResult = [];
  late List<ConflictModel> _baseSearchData = [];


  Map<String, List<DropdownMenuItem<String>>> dynamicLists = {};
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

  String? _selectedRange;
  String? _selectedConflict;
  String? _selectedBt;
  String? _selectedDate = 'all';

  @override
  void initState() {
    super.initState();

    fetchDynamicLists();
  }

  Future<void> fetchDynamicLists() async {
    // getting all possible ranges
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
      dynamicLists[doc.id] = tempList;
    }

    _selectedRange = dynamicLists['range']?.first.value;
    _selectedConflict = dynamicLists['conflict']?.first.value;
    _selectedBt = dynamicLists['bt']?.first.value?.toLowerCase();
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

    filterList.remove(filterAttribute);
    filterData();
    widget.updateState();
  }

  Future<void> fetchUserProfileData() async {
    final userSnapshot = await FirebaseFirestore.instance.collection('forestdata').get();

    final profileDataList = userSnapshot.docs
        .map(
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

    widget.profileDataList = profileDataList;
    _searchResult = profileDataList;
    widget.updateState();


    // getting all possible ranges
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
      dynamicLists[doc.id] = tempList;
    }

    _selectedRange = dynamicLists['range']?.first.value;
    _selectedConflict = dynamicLists['conflict']?.first.value;
    _selectedBt = dynamicLists['bt']?.first.value?.toLowerCase();

    setState(() { });
  }

  void filterData() {
    try {
      if( isSearchEnabled ) {
        _searchResult = _baseSearchData;
      }
      else {
        _searchResult = widget.profileDataList;
      }

      if (filterList.keys.contains('range')) {
        _searchResult = _searchResult
            .where((data) => data.range == filterList['range'])
            .toList();
        widget.updateState();
      }
      if (filterList.keys.contains('conflict')) {
        _searchResult = _searchResult
            .where((data) => data.conflict == filterList['conflict'])
            .toList();
        widget.updateState();

      }
      if (filterList.keys.contains('beat')) {
        _searchResult = _searchResult
            .where((data) => data.bt == filterList['beat'])
            .toList();
        widget.updateState();
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

        _searchResult = tempList;
        widget.updateState();

      }
    }
    catch( e, s) {
      debugPrint( e.toString() );
      debugPrint( s.toString() );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          items: dynamicLists['range'],
                          style: TextStyle(
                            // overflow: TextOverflow.ellipsis,
                            color: Colors.black,
                          ),
                          onChanged: (String? newValue) {
                            _selectedRange = newValue!;

                            filterList['range'] = newValue;
                            filterData();

                            widget.updateState();
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
                          items: dynamicLists['conflict'],
                          underline: Container(),
                          onChanged: (String? newValue) {

                            _selectedConflict = newValue!;

                            filterList['conflict'] = newValue;

                            filterData();

                            widget.updateState();
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
                          items: dynamicLists['beat'],
                          onChanged: (String? newValue) {

                            _selectedBt = newValue!;
                            filterList['beat'] = newValue;

                            filterData();
                            widget.updateState();
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

                            _selectedDate = newValue!;

                            filterList['date'] = newValue.toLowerCase();
                            filterData();
                            widget.updateState();
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
  }
}
