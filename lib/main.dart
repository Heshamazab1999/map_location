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
    assetBytes();
  }

  Future<Uint8List> assetBytes() async {
    String imgurl = "https://www.fluttercampus.com/img/car.png";
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl)).load(imgurl))
        .buffer
        .asUint8List();
    return bytes;
  }

  addMarker() async {
    Uint8List bytes = await assetBytes();
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
        body: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('locations').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                snapshot.data!.docs.map((doc) {
                  final data = doc.data()! as Map<String, dynamic>;
                  for (int item = 0;
                      item <= snapshot.data!.docs.length;
                      ++item) {
                    markers.add(
                      Marker(
                        markerId: MarkerId(item.toString()),
                        position: LatLng(data['latitude'] as double,
                            data['longitude'] as double),
                        draggable: true,
                        icon: BitmapDescriptor.defaultMarkerWithHue(21),
                      ),
                    );
                  }
                }).toList();
                Model model = Model.fromJson(snapshot.data!.docs.first.data());
                return GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(model.latitude!, model.longitude!),
                    zoom: 10,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: Set.from(markers),
                );
              }
            }));
  }
}
