import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'custom_buttons.dart';

class InputRow extends StatelessWidget {
  final String textFieldLabel;
  final TextEditingController controller;
  final double height;
  final TextInputType inputType;

  const InputRow(
      {super.key,
      required this.textFieldLabel,
      required this.controller,
      required this.height,
      required this.inputType});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            labelText: textFieldLabel, border: const OutlineInputBorder()),
        keyboardType: TextInputType.phone,
      ),
    );
  }
}

class InputRowWithSuffix extends StatelessWidget {
  final String textFieldLabel;
  final TextEditingController controller;
  final double height;
  final bool obscureText;
  final IconData enableIcon;
  final IconData disableIcon;
  final TextInputType inputType;
  final VoidCallback suffixClick;

  const InputRowWithSuffix(
      {super.key,
      required this.textFieldLabel,
      required this.controller,
      required this.height,
      required this.obscureText,
      required this.enableIcon,
      required this.disableIcon,
      required this.inputType,
      required this.suffixClick});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: SizedBox(
          height: height,
          child: TextField(
            obscureText: obscureText,
            controller: controller,
            decoration: InputDecoration(
              labelText: textFieldLabel,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(obscureText ? disableIcon : enableIcon),
                onPressed: suffixClick,
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
        ),
      )
    ]);
  }
}

class PhoneInputWidget extends StatelessWidget {
  final double height;
  final TextEditingController phoneController;
  final Country selectedCountry;
  final Function(String) onPhoneChanged;
  final Function(Country) onCountryChanged;

  const PhoneInputWidget(
      {super.key,
      required this.height,
      required this.phoneController,
      required this.selectedCountry,
      required this.onPhoneChanged,
      required this.onCountryChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: height,
      child: Container(
        child: TextFormField(
            cursorColor: Colors.purple,
            controller: phoneController,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            onChanged: onPhoneChanged,
            decoration: InputDecoration(
              hintText: "Enter phone number",
              hintStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      countryListTheme: const CountryListThemeData(
                        bottomSheetHeight: 550,
                      ),
                      onSelect: onCountryChanged,
                    );
                  },
                  child: Text(
                    "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              suffixIcon: phoneController.text.length > 9
                  ? Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: const Icon(
                        Icons.done,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  : null,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15)
            ]),
      ),
    );
  }
}

class OTPInputWidget extends StatelessWidget {
  final double height;
  final Function(String) onOTPCompleted;

  const OTPInputWidget({super.key, required this.height, required this.onOTPCompleted});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.maxFinite,
        height: height,
        child: Pinput(
          length: 6,
          showCursor: true,
          defaultPinTheme: PinTheme(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.purple.shade200,
              ),
            ),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          onCompleted: onOTPCompleted,
        ));
  }
}
