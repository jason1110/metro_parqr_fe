import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class CityMap extends StatefulWidget {
  

  @override
  _CityMapState createState() => _CityMapState();

}

class _CityMapState extends State<CityMap> {


StreamSubscription _locationSubscription;
Location _locationTracker = Location();
Marker marker;
Marker meterMarker;
Circle circle;
GoogleMapController _controller;

static final CameraPosition initialLocation = CameraPosition(
target: LatLng(39.75319, -105.00009),
zoom: 14.4746,
);

Future<Uint8List> getMarker() async {
  ByteData byteData = await DefaultAssetBundle.of(context).load("images/car_icon.png");
  return byteData.buffer.asUint8List();
}

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    LatLng meterLoc = LatLng(39.746633, -104.981047);
    this.setState(() {
      marker = Marker(
        markerId: MarkerId('home'),
        position: latlng,
        rotation: newLocalData.heading,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(imageData)
      );
      meterMarker = Marker(
        markerId: MarkerId('meter'),
        position: meterLoc,
        draggable: false,
        zIndex: 1,
        flat: false,
        anchor: Offset(1, 1),
        icon: BitmapDescriptor.defaultMarkerWithHue(120),
      );  
      circle = Circle(
        circleId: CircleId('car'),
        radius: newLocalData.accuracy,
        strokeWidth: 3,
        zIndex: 1,
        strokeColor: Colors.lightGreen,
        center: latlng,
        fillColor: Colors.lightGreen.withAlpha(70)
      );
    });
  }

  Future<void> getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData){
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
            bearing: 192.8334901395799,
            target: LatLng(newLocalData.latitude, newLocalData.longitude),
            tilt: 0,
            zoom: 17.25,
            ),
          ));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (error) {
      if (error.code == 'PERMISSION_DENIED') {
        debugPrint('Permission Denied');
      }
    }
  }

    @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 650,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: initialLocation,
          markers: Set.of((marker != null) ? [marker, meterMarker] : []),
          circles: Set.of((circle != null) ? [circle] : []),
          onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
    );
  }
}



// SizedBox(
//               height: 300,
//               child: GoogleMap(
//                 mapType: MapType.normal,
//                 initialCameraPosition: initialLocation,
//                 markers: Set.of((carMarker != null) ? [carMarker] : []),
//                 circles: Set.of((circle != null) ? [circle] : []),
//                 onMapCreated: (GoogleMapController controller) {
//                 _controller = controller;
//                 },
//               ),
//             ),

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.greenAccent[400],
      //   child: Icon(Icons.location_searching),
      //   elevation: 8.0,
      //   onPressed: () {
      //     getCurrentLocation();
      //   },
      // ),