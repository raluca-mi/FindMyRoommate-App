import 'package:find_my_roommate/helpers/enums/sort_option_enum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../helpers/enums/facility_enum.dart';
import './apartment_tile.dart';
import '../../providers/apartments_provider.dart';

class ApartmentsOverview extends StatelessWidget {
  final String? searchedLocality;
  final List<FacilityEnum> selectedFilters;
  final int selectedPrice;
  final int selectedCapacity;
  final SortOption? selectedSortingOption;

  const ApartmentsOverview(this.searchedLocality, this.selectedFilters,
      this.selectedPrice, this.selectedCapacity, this.selectedSortingOption,
      {super.key});

  Future<void> _refreshApartments(BuildContext context) async {
    await Provider.of<ApartmentsProvider>(context, listen: false)
        .searchApartments(searchedLocality, selectedFilters, selectedPrice,
            selectedCapacity, selectedSortingOption);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refreshApartments(context),
            child: FutureBuilder(
              future: Provider.of<ApartmentsProvider>(context, listen: false)
                  .searchApartments(searchedLocality, selectedFilters,
                      selectedPrice, selectedCapacity, selectedSortingOption),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.error != null) {
                  return Text(
                      'Error loading the apartments: ${snapshot.error.toString()}');
                } else {
                  return Consumer<ApartmentsProvider>(
                    builder: (ctx, apartmentsData, _) {
                      final apartments = apartmentsData.filteredApartments;
                      if (apartments.isEmpty) {
                        return const Center(
                            child: Text(Constants.noApartmentsFoundText));
                      }
                      return ListView.builder(
                        itemCount: apartments.length,
                        itemBuilder: (ctx, index) =>
                            ChangeNotifierProvider.value(
                          value: apartments[index],
                          child: const ApartmentTile(),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
