import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';

import '../../helpers/enums/facility_enum.dart';

class ApartmentFilters extends StatefulWidget {
  final List<FacilityEnum> selectedFacilities;
  final int selectedPrice;
  final int selectedCapacity;
  final Function(List<FacilityEnum>, int, int) onFiltersSelected;

  const ApartmentFilters({
    required this.selectedFacilities,
    required this.selectedPrice,
    required this.selectedCapacity,
    required this.onFiltersSelected,
    super.key,
  });

  @override
  State<ApartmentFilters> createState() => _ApartmentFiltersState();
}

class _ApartmentFiltersState extends State<ApartmentFilters> {
  List<FacilityEnum> _selectedFacilities = [];
  int _selectedPrice = 0;
  int _selectedCapacity = 0;

  @override
  void initState() {
    _selectedFacilities = widget.selectedFacilities;
    _selectedPrice = widget.selectedPrice;
    _selectedCapacity = widget.selectedCapacity;
    super.initState();
  }

  Future<void> _openFacilitiesFilters() async {
    await FilterListDialog.display<FacilityEnum>(
      headerCloseIcon: const Icon(Icons.close),
      height: 700,
      width: 500,
      context,
      headlineText: 'Select Facilities',
      listData: FacilityEnum.values,
      selectedListData: _selectedFacilities,
      onApplyButtonClick: (selectedItems) {
        setState(() {
          _selectedFacilities = selectedItems!;
        });
        Navigator.pop(context);
      },
      validateSelectedItem: (list, val) => list!.contains(val),
      choiceChipLabel: (item) => item.toString().split('.')[1],
      controlButtons: [ControlButtonType.All, ControlButtonType.Reset],
      onItemSearch: (FacilityEnum item, String query) {
        query = query.toLowerCase();
        final itemText = item.toString().toLowerCase();
        return itemText.contains(query);
      },
    );
  }

  Future<void> _openApartmentFilters() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Filters'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Select Facilities'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _openFacilitiesFilters(),
                      ),
                      ListTile(
                        title: const Text('Max budget/month'),
                        subtitle: Slider(
                          value: _selectedPrice.toDouble().clamp(0, 1000),
                          min: 0,
                          max: 1000,
                          divisions: 100,
                          onChanged: (value) {
                            setState(() {
                              _selectedPrice = value.toInt();
                            });
                          },
                          label: '${_selectedPrice.toString()}\u20ac',
                        ),
                      ),
                      ListTile(
                        title: const Text('Total capacity'),
                        subtitle: Slider(
                          value: _selectedCapacity.toDouble().clamp(0, 10),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          onChanged: (value) {
                            setState(() {
                              _selectedCapacity = value.toInt();
                            });
                          },
                          label: _selectedCapacity.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onFiltersSelected(
                    _selectedFacilities, _selectedPrice, _selectedCapacity);
                Navigator.pop(context);
              },
              child: const Text('Apply',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _selectFacilities(List<FacilityEnum>? selectedItems) {
    setState(() {
      if (selectedItems == null) {
        _selectedFacilities = [];
      } else {
        _selectedFacilities = selectedItems;
      }
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _openApartmentFilters,
      icon: const Icon(Icons.filter_alt),
    );
  }
}
