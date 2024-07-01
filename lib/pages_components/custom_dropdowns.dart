import 'package:flutter/material.dart';

class CountryCodeDropdown extends StatelessWidget {
  final String selectedCountryCode;
  final ValueChanged<String> onCountryCodeChanged;

  const CountryCodeDropdown(
      {super.key,
      required this.selectedCountryCode,
      required this.onCountryCodeChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: selectedCountryCode,
      onSelected: (String? newValue) {
        if (newValue != null) {
          onCountryCodeChanged(newValue);
        }
      },
      dropdownMenuEntries: const [
        DropdownMenuEntry(value: '+1', label: 'USA'),
        DropdownMenuEntry(value: '+44', label: 'UK'),
        DropdownMenuEntry(value: '+61', label: 'AU'),
        DropdownMenuEntry(value: '+91', label: 'IN'),
        DropdownMenuEntry(value: '+81', label: 'JP'),
        DropdownMenuEntry(value: '+49', label: 'DE'),
        DropdownMenuEntry(value: '+33', label: 'FR'),
        DropdownMenuEntry(value: '+39', label: 'IT'),
        DropdownMenuEntry(value: '+34', label: 'ES'),
        DropdownMenuEntry(value: '+55', label: 'BR'),
        DropdownMenuEntry(value: '+7', label: 'RU'),
        DropdownMenuEntry(value: '+86', label: 'CN'),
        DropdownMenuEntry(value: '+82', label: 'KR'),
        DropdownMenuEntry(value: '+64', label: 'NZ'),
        DropdownMenuEntry(value: '+27', label: 'ZA'),
        DropdownMenuEntry(value: '+52', label: 'MX'),
        DropdownMenuEntry(value: '+31', label: 'NL'),
        DropdownMenuEntry(value: '+46', label: 'SE'),
        DropdownMenuEntry(value: '+41', label: 'CH'),
        DropdownMenuEntry(value: '+32', label: 'BE'),
        DropdownMenuEntry(value: '+47', label: 'NO'),
        DropdownMenuEntry(value: '+65', label: 'SG'),
        DropdownMenuEntry(value: '+90', label: 'TR'),
        DropdownMenuEntry(value: '+84', label: 'VN'),
        // Add other country codes as needed
      ],
    );
  }
}
