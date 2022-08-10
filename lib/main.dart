import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_location/Model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Model model = Model();
  List<Marker> markers = [];

  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addMarker();
    FirebaseFirestore.instance
        .collection('locations')
        .snapshots()
        .listen((event) {
      print(event.docs);
      event.docs.forEach((element) {
        model = Model.fromJson(element.data());
        setState(() {
          markers.add(Marker(
            markerId: MarkerId(element.id),
            position: LatLng(model.latitude!, model.longitude!),
            draggable: true,
            infoWindow: InfoWindow(
              title: element.id,
              snippet: '${model.latitude}, ${model.longitude}',
            ),
          ));
        });
      });
    });
  }

  addMarker() async {
    String imgurl = "https://www.fluttercampus.com/img/car.png";
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl)).load(imgurl))
        .buffer
        .asUint8List();
    setState(() {
      markers.add(Marker(
        markerId: MarkerId("2"),
        position: LatLng(35.83333, 36.66667),
        draggable: true,
        icon: BitmapDescriptor.fromBytes(bytes),
      ));
      markers.add(Marker(
        markerId: MarkerId("3"),
        position: LatLng(35.83663, 36.134867),
        draggable: true,
        icon: BitmapDescriptor.fromBytes(bytes),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: model.latitude == null && model.longitude == null
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                mapType: MapType.hybrid,
                compassEnabled: true,
                trafficEnabled: true,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(model.latitude!, model.longitude!),
                  zoom: 10,
                ),
                markers: Set<Marker>.of(markers),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                })
     );
  }
}
