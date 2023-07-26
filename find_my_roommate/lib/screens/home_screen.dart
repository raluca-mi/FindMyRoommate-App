import 'package:find_my_roommate/helpers/enums/facility_enum.dart';
import 'package:find_my_roommate/helpers/enums/sort_option_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
// ignore: depend_on_referenced_packages
import 'package:google_api_headers/google_api_headers.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_webservice/places.dart';

import 'package:provider/provider.dart';

import '../helpers/constants.dart';
import '../helpers/display_helper.dart';
import '../helpers/location_helper.dart';
import '../providers/apartments_provider.dart';
import '../widgets/apartment/apartment_filters.dart';
import '../widgets/apartment/apartment_sort.dart';
import '../widgets/drawers/main_drawer.dart';
import '../widgets/apartment/apartments_overview.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = Constants.homeScreenRoute;
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _HomeScreenState extends State<HomeScreen> {
  String? _searchedLocality;
  bool _isSearching = false;
  List<FacilityEnum> _selectedFilters = [];
  int _selectedPrice = 0;
  int _selectedCapacity = 0;
  SortOption? _selectedSortingOption;
  final Mode _mode = Mode.overlay;

  @override
  void initState() {
    super.initState();
  }

  void _handleFiltersSelected(
      List<FacilityEnum> selectedFilters, int price, int capacity) {
    setState(() {
      _selectedFilters = selectedFilters;
      _selectedPrice = price;
      _selectedCapacity = capacity;
    });
  }

  void _handleSortingOptionSelected(SortOption? selectedOption) {
    setState(() {
      _selectedSortingOption = selectedOption;
    });
  }

  Future<void> _handleSearchButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: GOOGLE_API_KEY,
        onError: _onError,
        mode: _mode,
        language: 'ro',
        strictbounds: false,
        types: ['(cities)'],
        decoration: InputDecoration(
            hintText: 'Enter city',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white))),
        components: [
          Component(Component.country, "ro"),
        ]);
    if (p == null) {
      setState(() {
        _isSearching = false;
      });
      return;
    } else {
      _displayPrediction(p, homeScaffoldKey.currentState);
    }
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
    final address = await LocationHelper.getAddressComponents(lat, lng);
    setState(() {
      _searchedLocality = address['locality'];
    });

    // ignore: use_build_context_synchronously
    Provider.of<ApartmentsProvider>(context, listen: false).searchApartments(
        _searchedLocality,
        _selectedFilters,
        _selectedPrice,
        _selectedCapacity,
        _selectedSortingOption);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.homeAppBarText),
        actions: [
          Row(
            children: [
              ApartmentFilters(
                selectedFacilities: _selectedFilters,
                selectedPrice: _selectedPrice,
                selectedCapacity: _selectedCapacity,
                onFiltersSelected: _handleFiltersSelected,
              ),
              ApartmentSort(
                selectedOption: _selectedSortingOption,
                onOptionSelected: _handleSortingOptionSelected,
              ),
              _isSearching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchedLocality = null;
                        setState(() {
                          _isSearching = false;
                        });
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () {
                        _handleSearchButton();
                        setState(() {
                          _isSearching = true;
                        });
                      },
                    ),
            ],
          )
        ],
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ApartmentsOverview(
              _searchedLocality,
              _selectedFilters,
              _selectedPrice,
              _selectedCapacity,
              _selectedSortingOption,
            ),
          ),
        ],
      ),
    );
  }
}
