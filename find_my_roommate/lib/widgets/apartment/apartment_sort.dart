import 'package:flutter/material.dart';

import '../../helpers/enums/sort_option_enum.dart';

class ApartmentSort extends StatefulWidget {
  final SortOption? selectedOption;
  final Function(SortOption) onOptionSelected;
  const ApartmentSort({
    required this.selectedOption,
    required this.onOptionSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<ApartmentSort> createState() => _ApartmentSortState();
}

class _ApartmentSortState extends State<ApartmentSort> {
  SortOption? _selectedSortingOption;

  void _openSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Sort Options'),
              contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: const Text(
                      'Sort by price ascending',
                      style: TextStyle(fontSize: 16),
                    ),
                    leading: Radio<SortOption>(
                      value: SortOption.priceAscending,
                      groupValue: _selectedSortingOption,
                      onChanged: (SortOption? value) {
                        setState(() {
                          _selectedSortingOption = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Sort by price descending',
                      style: TextStyle(fontSize: 16),
                    ),
                    leading: Radio<SortOption>(
                      value: SortOption.priceDescending,
                      groupValue: _selectedSortingOption,
                      onChanged: (SortOption? value) {
                        setState(() {
                          _selectedSortingOption = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Sort by newest to oldest',
                      style: TextStyle(fontSize: 16),
                    ),
                    leading: Radio<SortOption>(
                      value: SortOption.fromNewestToOldest,
                      groupValue: _selectedSortingOption,
                      onChanged: (SortOption? value) {
                        setState(() {
                          _selectedSortingOption = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Sort by oldest to newest',
                      style: TextStyle(fontSize: 16),
                    ),
                    leading: Radio<SortOption>(
                      value: SortOption.fromOldestToNewest,
                      groupValue: _selectedSortingOption,
                      onChanged: (SortOption? value) {
                        setState(() {
                          _selectedSortingOption = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Reset'),
                    leading: Radio<SortOption>(
                      value: SortOption.none,
                      groupValue: _selectedSortingOption,
                      onChanged: (SortOption? value) {
                        setState(() {
                          _selectedSortingOption = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onOptionSelected(_selectedSortingOption!);
                  },
                  child: const Text('Apply',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.sort),
      onPressed: () => _openSortOptions(context),
    );
  }
}
