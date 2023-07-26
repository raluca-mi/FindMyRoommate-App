import 'package:flutter/material.dart';
import '../../helpers/enums/facility_enum.dart';
import '../../models/facility_chip.dart';

class FacilitiesPicker extends StatefulWidget {
  final List<FacilityChip> initialFacilities;
  final Function(List<FacilityChip>) onSave;
  final bool editMode;

  const FacilitiesPicker({
    required this.initialFacilities,
    required this.onSave,
    this.editMode = true,
    Key? key,
  }) : super(key: key);

  @override
  State<FacilitiesPicker> createState() => _FacilitiesPickerState();
}

class _FacilitiesPickerState extends State<FacilitiesPicker> {
  List<FacilityChip> availableFacilities = [];
  List<FacilityChip> chosenFacilities = [];

  @override
  void initState() {
    super.initState();
    availableFacilities = FacilityChip.availableFacilities
        .where((chip) =>
            !_containsFacility(widget.initialFacilities, chip.facility))
        .toList();
    chosenFacilities.addAll(widget.initialFacilities);
  }

  bool _containsFacility(List<FacilityChip> facilities, FacilityEnum facility) {
    return facilities.any((chip) => chip.facility == facility);
  }

  void _addFacilityChip(FacilityEnum facility) {
    final newFacilityChip = FacilityChip(facility);
    setState(() {
      chosenFacilities.add(newFacilityChip);
      availableFacilities.removeWhere((chip) => chip.facility == facility);
    });
    widget.onSave(chosenFacilities);
  }

  void _removeFacilityChip(FacilityChip facilityChip) {
    setState(() {
      chosenFacilities.remove(facilityChip);
      availableFacilities.add(facilityChip);
    });
    widget.onSave(chosenFacilities);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.editMode)
            const Text(
              'Available Facilities:',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          if (widget.editMode) const SizedBox(height: 8.0),
          if (widget.editMode)
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: availableFacilities.map((facilityChip) {
                final isAlreadySelected =
                    _containsFacility(chosenFacilities, facilityChip.facility);
                return ElevatedButton.icon(
                  onPressed: !isAlreadySelected
                      ? () => _addFacilityChip(facilityChip.facility)
                      : null,
                  icon: Icon(facilityChip.icon),
                  label: Text(facilityChip.label),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: isAlreadySelected
                        ? Colors.grey
                        : const Color.fromARGB(255, 180, 191, 236),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          if (widget.editMode) const SizedBox(height: 16.0),
          if (widget.editMode)
            const Text(
              'Chosen Facilities:',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          chosenFacilities.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No facilities chosen yet...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: chosenFacilities.map((chip) {
                    return Chip(
                      label: Text(chip.label),
                      avatar: Icon(chip.icon),
                      backgroundColor: const Color.fromARGB(255, 255, 206, 90),
                      deleteIconColor: widget.editMode ? Colors.black : null,
                      onDeleted: widget.editMode
                          ? () => _removeFacilityChip(chip)
                          : null,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
