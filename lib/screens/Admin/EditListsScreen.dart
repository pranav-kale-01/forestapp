import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../common/models/DynamicListsModel.dart';

class EditListsScreen extends StatefulWidget {
  const EditListsScreen({Key? key}) : super(key: key);

  @override
  _EditListsScreenState createState() => _EditListsScreenState();
}

class _EditListsScreenState extends State<EditListsScreen> {
  List<DynamicListsModel> attributeList = [];

  @override
  void initState() {
    super.initState();
    getAttributeList();
  }

  void getAttributeList() async {
    // fetching the list of attributes from firebase
    final docSnapshot = await FirebaseFirestore.instance.collection('dynamic_lists').get();

    for( var doc in docSnapshot.docs ) {
      List<String> tempList = [];
      for( var att in doc.get('values') ) {
        tempList.add(att.toString());
      }

      attributeList.add( DynamicListsModel(id: doc.id, values: tempList) );
    }

    setState(() {

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
          'Edit Attribute Lists',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: attributeList.isEmpty ? Center(
        child: CircularProgressIndicator(),
      ): Padding(
        padding: const EdgeInsets.symmetric( vertical: 12.0, ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: attributeList.map((e) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                          child: Text(
                            e.id[0].toUpperCase() + e.id.substring(1) + 's',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric( horizontal: 12.0, ),
                      child: IconButton(
                        onPressed: () {
                          String newField = "";

                          // showing dialog to add a value
                          showDialog(
                            context: context,
                            builder: ((context) => AlertDialog(
                                title: Text(e.id[0].toUpperCase() + e.id.substring(1) + 's'),
                                content: TextField(
                                  onChanged: (value) {
                                    newField = value;
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'Enter ${e.id[0].toUpperCase() + e.id.substring(1)}s'
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () async {
                                      // returning if the field is empty
                                      if( newField.isEmpty ) {
                                        return;
                                      }

                                      e.values.add(newField);

                                      await FirebaseFirestore.instance.collection('dynamic_lists').doc(e.id).set( {
                                        "values" : e.values
                                      }, SetOptions(merge: true));

                                      Navigator.of(context).pop();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Attribute Added',
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
                                    },
                                  ),
                                ],
                              )
                            ),
                          );
                        },
                        icon: Icon(
                            Icons.add
                        ),
                      ),
                    )
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: e.values.map((val) => Container(
                        width: mediaQuery.size.width,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: const EdgeInsets.symmetric( vertical: 4.0, ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0, ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              val.toString(),
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),

                            IconButton(
                                onPressed: () async {
                                  setState(() {
                                    // removing the value from the list
                                    e.values.remove(val);
                                  });

                                  await FirebaseFirestore.instance.collection('dynamic_lists').doc(e.id).set( {
                                    "values" : e.values
                                  }, SetOptions(merge: true));

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Attribute Removed Sucessfully',
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

                                },
                                icon: Icon(
                                  Icons.remove
                                )
                            ),
                          ],
                        ),
                      )
                    ).toList(),
                  ),
                )
              ],
            )
            ).toList(),
          ),
        ),
      ),
    );
  }
}
