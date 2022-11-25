// @dart=2.9
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
  List<Marker> markers = [];

  @override
  void initState() {
    _getCurrentLocation().then((pos) {
      addMarker(pos, 'currpos', 'You are here!');
    }).catchError((err) => print(err.toString()));
    super.initState();
  }

  final CameraPosition position =
      CameraPosition(target: LatLng(41.9028, 12.4964), zoom: 12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          child: GoogleMap(
            markers: Set<Marker>.of(markers),
            initialCameraPosition: position,
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

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

  void addMarker(Position pos, String markerId, String markerTitle) {
    final marker = Marker(
        markerId: MarkerId(markerId),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: InfoWindow(title: markerTitle),
        icon: (markerId == 'currpos')
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
            : BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange));

    markers.add(marker);
    setState(() {
      markers = markers;
    });
  }
}
