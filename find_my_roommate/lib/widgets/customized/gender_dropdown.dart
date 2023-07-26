import 'package:flutter/material.dart';

import '../../helpers/enums/gender_type_enum.dart';

class GenderDropdown extends StatefulWidget {
  final void Function(GenderType pickedGender) selectGender;
  final GenderType? initialValue;
  const GenderDropdown(this.selectGender, {this.initialValue, super.key});

  @override
  State<GenderDropdown> createState() => _GenderDropdownState();
}

class _GenderDropdownState extends State<GenderDropdown> {
  GenderType? _selectedGender = GenderType.none;

  @override
  void initState() {
    if (widget.initialValue != null) {
      setState(() {
        _selectedGender = widget.initialValue!;
      });
    }
    super.initState();
  }

  void _selectGender(GenderType gender) {
    widget.selectGender(gender);
    setState(() {
      _selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12), // Customize the border radius
        border: Border.all(
          color: const Color.fromARGB(
              255, 220, 220, 220), // Customize the border color
          width: 1, // Customize the border width
        ),
      ),
      child: DropdownButton<GenderType>(
        value: _selectedGender,
        onChanged: (GenderType? newValue) => _selectGender(newValue!),
        underline: Container(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.black,
        ),
        items: [
          DropdownMenuItem<GenderType>(
            value: GenderType.none,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                'Gender',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          ),
          ...GenderType.values
              .where((gender) => gender != GenderType.none)
              .map((GenderType gender) {
            return DropdownMenuItem<GenderType>(
              value: gender,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  gender.name,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
