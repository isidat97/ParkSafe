import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';

/// Authentic Indian Vehicle Number Plate Input Field Widget
class VehicleNumberPlateField extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const VehicleNumberPlateField({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  State<VehicleNumberPlateField> createState() =>
      _VehicleNumberPlateFieldState();
}

class _VehicleNumberPlateFieldState extends State<VehicleNumberPlateField> {
  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white, // Standard white number plate
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? AppColors.error : const Color(0xFF1E2838),
              width: hasError ? 2.5 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: hasError
                    ? AppColors.error.withOpacity(0.25)
                    : const Color(0xFF1E2838).withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left IND Strip
              Container(
                width: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF003399), // Deep IND Blue
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Blue Chakra symbol
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 2,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'IND',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // License Plate Input
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: widget.controller,
                      onChanged: widget.onChanged,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        IndianVehicleNumberFormatter(),
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: Color(0xFF1E2838),
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        filled: false,
                        hintText: 'MH 12 AB 1234',
                        hintStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0x661E2838),
                          letterSpacing: 1.5,
                          fontFamily: 'monospace',
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Inline Error Display
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.errorText!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Formats vehicle number input: 2 Alpha + space + 2 Num + space + 2 Alpha + space + 4 Num
class IndianVehicleNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final clean = raw.substring(0, raw.length.clamp(0, 10));

    final sb = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i == 2 || i == 4 || i == 6) {
        sb.write(' ');
      }
      sb.write(clean[i]);
    }

    final formattedText = sb.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
