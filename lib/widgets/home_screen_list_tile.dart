import 'package:flutter/material.dart';
import 'package:forestapp/common/models/ConflictModel.dart';
import 'package:intl/intl.dart';
import '../screens/Admin/ForestDetail.dart';

class HomeScreenListTile extends StatefulWidget {
  final Function(int) changeIndex;
  ConflictModel forestData;

  HomeScreenListTile({
    Key? key,
    required this.forestData,
    required this.changeIndex,
  }) : super(key: key);

  @override
  _HomeScreenListTileState createState() => _HomeScreenListTileState();
}

class _HomeScreenListTileState extends State<HomeScreenListTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return InkWell(
      onTap: () {
        // Navigating to  Forest Details
        Navigator.of(context)
            .push(
            MaterialPageRoute(
                builder: (context) =>
                    ForestDetail(
                        forestData: widget.forestData,
                        currentIndex: 0,
                        changeIndex: widget.changeIndex,
                        changeData: (ConflictModel newData) {
                          print( "test " );
                          setState(() {
                            widget.forestData = newData;
                          });
                        }
                    )
            )
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric( vertical: 4.0 ),
        padding: const EdgeInsets.symmetric( horizontal: 14.0, vertical: 16.0),
        width: mediaQuery.size.width * 0.94 ,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: mediaQuery.size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only( bottom: 4.0),
                        child: Text(
                          widget.forestData.village_name,
                          style: TextStyle(
                              fontSize: 18 * mediaQuery.textScaleFactor,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only( bottom: 4.0),
                        child: Text(
                          widget.forestData.conflict,
                          style: TextStyle(
                              fontSize: 18 * mediaQuery.textScaleFactor,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy hh:mm').format(widget.forestData.datetime!.toDate()),
                        style: TextStyle(
                            fontSize: 18 * mediaQuery.textScaleFactor,
                            fontWeight: FontWeight.w400
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only( bottom: 4.0),
                        child: Text(
                          widget.forestData.userName,
                          style: TextStyle(
                              fontSize: 18 * mediaQuery.textScaleFactor,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
