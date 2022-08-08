import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  var marker = HashSet<Marker>();
  Model model = Model();
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get();
  }

  get() async {
    final data = await await FirebaseFirestore.instance
        .collection('locations')
        .doc("loc")
        .get()
        .then((value) =>
    model = Model.fromJson(value.data()));
    if (kDebugMode) {
       print(model.latitude);
    }
  }

  getLocation() async {
    final data = await FirebaseFirestore.instance
        .collection('locations')
        .doc("loc")
        .get()
        .then((value) {
      model = Model.fromJson(value.data());
      if (kDebugMode) {
         print(model.latitude);
      }
      setState(() {
        marker.add(
          Marker(
            markerId: const MarkerId("1"),
            infoWindow: const InfoWindow(title: "Your Location"),
            position: LatLng(model.latitude!, model.longitude!),
          ),
        );
      });
      print(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
                future: getLocation(),
                builder: (context, snapshot) {
                  return GoogleMap(
                    markers: marker,
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(model.latitude!, model.longitude!),
                      zoom: 14.4746,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  );
                }));
  }
}
