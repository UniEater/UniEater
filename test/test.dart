import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'restaurant_info.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  late GoogleMapController mapController;
  LocationData? currentLocation;
  final Location location = Location();
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.granted) {
      _getLocation();
    } else {
      final requestPermissionStatus = await location.requestPermission();
      if (requestPermissionStatus == PermissionStatus.granted) {
        _getLocation();
      } else {
        //TODO: Handle the case when permission is denied
        print('Location permission denied');
      }
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isGettingLocation = true;
    });
    final locationResult = await location.getLocation();
    setState(() {
      currentLocation = locationResult;
      _isGettingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isGettingLocation
          ? const Center(child: CircularProgressIndicator())
          : currentLocation == null
              ? const Center(child: Text('Unable to get location'))
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) =>
                      mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 14.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: _createMarkers(),
                ),
    );
  }

  //navigate to google maps
  Future<void> _launchMaps(String address) async {
    final Uri googleMapsUrl = Uri.parse('comgooglemaps://?daddr=$address');
    final Uri webUrl = Uri.parse('https://www.google.com/maps/dir//$address');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl);
    } else {
      throw Exception('Could not launch $googleMapsUrl or $webUrl');
    }
  }

  void _showBottomSheet(
      BuildContext context, String title, String timings, String address) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 50, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => restaurant_info()),
                        );
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      timings,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      address,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 84, 182, 217),

                            padding:
                                const EdgeInsets.symmetric(horizontal: 100),

                            elevation: 5,
                            // side:
                            //     BorderSide(color: Colors.blueAccent, width: 2),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shadowColor: Colors.grey,
                          ),
                          onPressed: () {},
                          child: const Text("店家菜單"),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 84, 182, 217),
                                  width: 2),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                            ),
                            onPressed: () => _launchMaps(address),
                            child: const Icon(
                              Icons.near_me,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //pin the store location
  //TODO : database, icon
  Set<Marker> _createMarkers() {
    return {
      Marker(
        markerId: const MarkerId("exampleMarker"),
        position: const LatLng(25.0130057, 121.5402865),
        infoWindow: const InfoWindow(
          title: "台科大學餐",
          snippet: "最頂的學餐",
        ),
        onTap: () {
          _showBottomSheet(context, "台科大學餐", "11:30 - 20:00", "台北市忠孝東路三段一號");
        },
      ),
      Marker(
        markerId: const MarkerId("測試餐廳"),
        position: const LatLng(37.3323603, -122.0316901),
        infoWindow: const InfoWindow(
          title: "測試餐廳",
          snippet: "一間測試餐廳",
        ),
        onTap: () {
          _showBottomSheet(context, "測試餐廳", "11:30 - 20:00", "台北市忠孝東路三段一號");
        },
      ),
    };
  }
}
