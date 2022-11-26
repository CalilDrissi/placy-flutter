import 'package:flutter/material.dart';
import 'place_dialog.dart';
import './utils/dbhelper.dart';






class ManagePlaces extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Places'),),
      body: PlacesList(),
    );
  }
}



class PlacesList extends StatefulWidget {
  @override
  State<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends State<PlacesList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
