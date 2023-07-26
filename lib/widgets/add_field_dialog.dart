import 'package:flutter/material.dart';
import 'package:forestapp/common/models/DynamicListsModel.dart';
import 'package:forestapp/common/themeHelper.dart';
import 'package:forestapp/utils/dynamic_list_service.dart';

class AddFieldDialog extends StatefulWidget {
  final DynamicListsModel listItem;
  List<DynamicListsModel> attributeList;
  List<DropdownMenuItem<Map<String, dynamic>>> rounds;

  AddFieldDialog({Key? key, required this.listItem, required this.attributeList, required this.rounds}) : super(key: key);

  @override
  _AddFieldDialogState createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<AddFieldDialog> {
  String selectedRangeId = "";
  String selectedRoundId = "";
  String newField = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add " + widget.listItem.id[0].toUpperCase() + widget.listItem.id.substring(1) + 's'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 15.0, bottom: 8.0),
            child: Text(
              widget.listItem.id,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextField(
            onChanged: (value) {
              newField = value;
            },
            decoration: ThemeHelper().textInputDecoration('Round',
                'Enter ${widget.listItem.id[0].toUpperCase() + widget.listItem.id.substring(1)}s'),
          ),
          if ( widget.listItem.id.toLowerCase() == 'round')
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 15.0, bottom: 8.0),
                  child: Text(
                    "Range",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownButtonFormField(
                  decoration: ThemeHelper()
                      .textInputDecoration('Range', 'Select Range'),
                  items: widget.attributeList
                      .firstWhere((item) => item.id == 'range')
                      .values
                      .map<DropdownMenuItem<Map<String, dynamic>>>(
                          (e) => DropdownMenuItem(
                        child: Text(e['name']),
                        value: e,
                      ))
                      .toList(),
                  onChanged: (Map<String, dynamic>? value) {
                    selectedRangeId = value!['id'].toString();
                  },
                ),
              ],
            ),
          if (widget.listItem.id.toLowerCase() == 'beat')
            Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(top: 15.0, bottom: 8.0),
                  child: Text(
                    "Range",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownButtonFormField(
                  decoration: ThemeHelper()
                      .textInputDecoration('Range', 'Enter Range'),
                  items: widget.attributeList
                      .firstWhere((item) => item.id == 'range')
                      .values
                      .map<DropdownMenuItem<Map<String, dynamic>>>(
                          (e) => DropdownMenuItem(
                        child: Text(e['name']),
                        value: e,
                      ))
                      .toList(),
                  onChanged: (Map<String, dynamic>? value) {
                    setState(() {
                      selectedRangeId = value!['id'].toString();
                      widget.rounds = widget.attributeList
                          .firstWhere((item) => item.id == 'round')
                          .values
                          .where( (round) => round['range_id'] == selectedRangeId )
                          .map<DropdownMenuItem<Map<String, dynamic>>>(
                              (e) => DropdownMenuItem(
                            child: Text(e['name']),
                            value: e,
                          ))
                          .toList();
                    });
                  },
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(top: 15.0, bottom: 8.0),
                  child: Text(
                    "Round",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownButtonFormField(
                    decoration: ThemeHelper()
                        .textInputDecoration('Round', 'Enter Round'),
                    items: widget.rounds,
                    onChanged: (Map<String, dynamic>? value) {
                      selectedRoundId = value!['id'].toString();
                    }),
              ],
            )
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('OK'),
          onPressed: () async {
            // returning if the field is empty

            if (newField.isEmpty) {
              Navigator.of(context).pop( widget.listItem  );
              return;
            }

            // removing trailing and leading spaces
            newField = newField.trim();

            if( widget.listItem.id == 'range' ) {
              int id = await DynamicListService.addField(context, widget.listItem.id, newField);
              widget.listItem.values.add({
                "id": id,
                "name": newField
              });
            }
            else if (widget.listItem.id == 'round') {
              int id = await DynamicListService.addField(
                  context,
                  widget.listItem.id,
                  newField,
                  range_id: selectedRangeId
              );
              widget.listItem.values.add({
                "id": id,
                "name" : newField,
                "range_id": selectedRangeId
              });
            } else if (widget.listItem.id == 'beat') {
              int id =  await DynamicListService.addField(context, widget.listItem.id, newField, range_id: selectedRangeId, round_id: selectedRoundId);

              widget.listItem.values.add( {
                "id": id,
                "name" : newField,
                "range_id": selectedRangeId,
                "round_id": selectedRoundId
              } );
            }
            else if (widget.listItem.id == 'conflict' ) {
              int id =  await DynamicListService.addField(context, widget.listItem.id, newField );
              widget.listItem.values.add( {
                "id": id,
                "name" : newField,
                "range_id": selectedRangeId,
                "round_id": selectedRoundId
              } );
            }

            Navigator.of(context).pop( widget.listItem );

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
    );
  }
}
