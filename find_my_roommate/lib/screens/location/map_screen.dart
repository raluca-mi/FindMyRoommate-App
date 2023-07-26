import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_webservice/places.dart';
// ignore: depend_on_referenced_packages
import 'package:google_api_headers/google_api_headers.dart';

import '../../helpers/constants.dart';
import '../../helpers/display_helper.dart';
import '../../helpers/location_helper.dart';

class MapScreen extends StatefulWidget {
  final GeoPoint initialLocation;
  final String apartmentTitle;
  final bool isSelecting;

  const MapScreen(
      {this.initialLocation = const GeoPoint(37.422, -122.084),
      this.apartmentTitle = '',
      this.isSelecting = false,
      super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  late GoogleMapController _googleMapController;
  final Mode _mode = Mode.overlay;
  Set<Marker> markers = {};

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: GOOGLE_API_KEY,
        onError: _onError,
        mode: _mode,
        language: 'ro',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
            hintText: 'Search...',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white))),
        components: [
          Component(Component.country, "ro"),
        ]);

    _displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void _onError(PlacesAutocompleteResponse response) {
    DisplayHelper.showErrorMessage(
        context, '${Constants.errorOccuredText}: ${response.errorMessage}');
  }

  Future<void> _displayPrediction(
      Prediction p, ScaffoldState? currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: GOOGLE_API_KEY,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    markers.clear();
    markers.add(Marker(
        markerId: const MarkerId("A"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {
      _pickedLocation = LatLng(lat, lng);
    });

    _googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }

  void _selectLocation(LatLng position) {
    markers.clear();
    markers.add(Marker(
      markerId: const MarkerId('A'),
      position: position,
    ));
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pickedLocation == null && !widget.isSelecting) {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('A'),
          position: LatLng(
            widget.initialLocation.latitude,
            widget.initialLocation.longitude,
          ),
          infoWindow: InfoWindow(title: widget.apartmentTitle),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
          actions: [
            if (widget.isSelecting)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    onPressed: _handlePressButton,
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _pickedLocation == null
                        ? null
                        : () {
                            Navigator.of(context).pop(_pickedLocation);
                          },
                  ),
                ],
              ),
          ],
        ),
        body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.initialLocation.latitude,
                  widget.initialLocation.longitude),
              zoom: 16,
            ),
            onTap: widget.isSelecting ? _selectLocation : null,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController = controller;
            },
            markers: markers));
  }
}
