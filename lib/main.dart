// @dart=2.9
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import './utils/dbhelper.dart';
import './models/place.dart';
import 'place_dialog.dart';
import 'manage_places.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Places',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage('Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(this.title);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DbHelper helper;
  List<Marker> _markers = [];


  @override
  void initState() {
    _getCurrentLocation().then((pos){
      _addMarker(pos, 'currpos', 'You are here!');
    }).catchError( (err)=> print(err.toString()));
    helper = DbHelper();
    // helper.insertMockData();
    _getData();

    super.initState();
  }


  final CameraPosition position = CameraPosition(target: LatLng(41.9028, 12.4964), zoom: 12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(onPressed: (){
              MaterialPageRoute route = MaterialPageRoute(builder: (context)=> ManagePlaces());
              Navigator.push(context, route);
            }, icon: Icon(Icons.list),)
          ],
        ),
        body: Container(
          child: GoogleMap(
            markers: Set<Marker>.of(_markers),
            initialCameraPosition: position,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_location),
          onPressed: () {

            int here = _markers.indexWhere((p)=> p.markerId == MarkerId('currpos'));
            Place place;
            if (here == -1) {
              //the current position is not available
              place = Place(0, '', 0, 0, '');
            }
            else {
              LatLng pos = _markers[here].position;
              place = Place(0, '', pos.latitude, pos.longitude, '');
            }

            PlaceDialog dialog = PlaceDialog(place, true);
            showDialog(context: context, builder: (context) => dialog.BuildAlert(context));

          },




        ),// This trailing comma makes auto-formatting nicer for build methods.
        );
  }



  /////################# FUNCTIONALITY##################################
  Future _getCurrentLocation() async {
    bool isGeolocationAvailable = await Geolocator.isLocationServiceEnabled();

    Position _position = Position(
        accuracy: 1.0,
        latitude: this.position.target.latitude,
        longitude: this.position.target.longitude);
    if (isGeolocationAvailable) {
      try {
        _position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
      } catch (error) {
        return _position;
      }
    }
    return _position;
  }

  void _addMarker(Position pos, String markerId, String markerTitle) {
    final marker = Marker(
        markerId: MarkerId(markerId),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: InfoWindow(title: markerTitle),
        icon: (markerId == 'currpos')
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
            : BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange));

    _markers.add(marker);
    setState(() {
      _markers = _markers;
    });
  }


  Future _getData() async {
    await helper.openDb();
    // await helper.testDb();
    List <Place> _places =  await helper.getPlaces();
    for (Place p in _places) {
       _addMarker(Position(latitude: p.lat, longitude: p.lon), p.id.toString(),  p.name) ;
    }
    setState(() {
      _markers = _markers;
    });
  }


}
