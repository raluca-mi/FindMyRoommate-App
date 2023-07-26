import 'package:find_my_roommate/screens/location/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../helpers/location_helper.dart';

class LocationPicker extends StatefulWidget {
  final Function onSelectPlace;
  final String? previewImageUrl;
  const LocationPicker(this.previewImageUrl, this.onSelectPlace, {super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String? staticMapImageUrl;
  String? _previewImageUrl;

  @override
  void initState() {
    _previewImageUrl = widget.previewImageUrl;
    super.initState();
  }

  Future<void> _getCurrentUserLocation() async {
    final locData = await Location().getLocation();
    staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
        latitude: locData.latitude, longitude: locData.longitude);
    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
    widget.onSelectPlace(
        locData.latitude, locData.longitude, _previewImageUrl!);
  }

  Future<void> _selectOnMap() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => const MapScreen(
          isSelecting: true,
        ),
      ),
    );
    if (selectedLocation == null) {
      return;
    }
    staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude);
    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });

    widget.onSelectPlace(selectedLocation.latitude, selectedLocation.longitude,
        _previewImageUrl!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 0.5,
                color: const Color.fromARGB(255, 216, 215, 215),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: const Color.fromARGB(255, 239, 239, 239),
                height: 170,
                width: double.infinity,
                alignment: Alignment.center,
                child: _previewImageUrl == null
                    ? const Text(
                        'No Location Chosen',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        textAlign: TextAlign.center,
                      )
                    : FractionallySizedBox(
                        widthFactor: 1.0,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            _previewImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _getCurrentUserLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('Current Location'),
              ),
              TextButton.icon(
                onPressed: _selectOnMap,
                icon: const Icon(Icons.map),
                label: const Text('Select on Map'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
