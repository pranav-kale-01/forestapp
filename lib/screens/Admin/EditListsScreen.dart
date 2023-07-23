import 'package:flutter/material.dart';
import 'package:forestapp/utils/dynamic_list_service.dart';
import 'package:forestapp/widgets/add_beats_dialog.dart';

import '../../common/models/DynamicListsModel.dart';

class EditListsScreen extends StatefulWidget {
  final Function(int) changeIndex;

  const EditListsScreen({
    Key? key,
    required this.changeIndex,
  }) : super(key: key);

  @override
  _EditListsScreenState createState() => _EditListsScreenState();
}

class _EditListsScreenState extends State<EditListsScreen> {
  List<DynamicListsModel> attributeList = [];
  String selectedRangeId = "";
  String selectedRoundId = "";

  @override
  void initState() {
    super.initState();
    getAttributeList();
  }

  void getAttributeList() async {
    // fetching the list of attributes from firebase
    Map<String, dynamic> dynamicLists =
        await DynamicListService.fetchDynamicLists();

    attributeList = dynamicLists.keys
        .map((e) => DynamicListsModel(id: e, values: dynamicLists[e]))
        .toList();

    setState(() {});
  }

  void _onItemTapped(int index) {
    widget.changeIndex(index);
    Navigator.of(context).pop();
  }

  void addItem(DynamicListsModel e) {
    List<DropdownMenuItem<Map<String, dynamic>>> _rounds = attributeList
        .firstWhere((item) => item.id == 'round')
        .values
        .where( (round) => round['range_id'] == selectedRangeId )
        .map<DropdownMenuItem<Map<String, dynamic>>>(
            (e) => DropdownMenuItem(
          child: Text(e['name']),
          value: e,
        ))
        .toList();

    // showing dialog to add a value
    showDialog(
      context: context,
      builder: ((context) =>  AddBeatsDialog(
        listItem: e,
        rounds: _rounds,
        attributeList: attributeList,
      )),
    );
  }

  Future<void> removeItem(DynamicListsModel e, Map<String, dynamic> item ) async {
    DynamicListService.removeField( e.id, item );
    // await FirebaseFirestore.instance
    //     .collection('dynamic_lists')
    //     .doc(e.id)
    //     .set({"values": e.values}, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Attribute Removed Successfully',
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
      ),
    );
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
          'Edit Attribute Lists',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_sharp),
            label: 'Guard',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Forest Data',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
            backgroundColor: Colors.black,
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
      body: attributeList.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: attributeList
                      .map((e) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Container(
                                      child: Text(
                                        e.id[0].toUpperCase() +
                                            e.id.substring(1) +
                                            's',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: IconButton(
                                      onPressed: () => addItem(e),
                                      icon: Icon(Icons.add),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Column(
                                  children: e.values
                                      .map((val) => Container(
                                            width: mediaQuery.size.width,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16.0,
                                              horizontal: 12.0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  val['name'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      removeItem(e, val ).then(
                                                          (value) =>
                                                              setState(() {
                                                                // removing the value from the list
                                                                e.values.remove(
                                                                    val);
                                                              }));
                                                    },
                                                    icon: Icon(Icons.remove)),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ),
                              )
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
    );
  }
}
