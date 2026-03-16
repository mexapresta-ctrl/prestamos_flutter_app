import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum InputState { def, active, ok, error }

class CustomInput extends StatefulWidget {
  final String? label;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final InputState initialState;
  final String? tagText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? prefix;
  final String? hintText;

  const CustomInput({
    super.key,
    this.label,
    this.initialValue,
    this.onChanged,
    this.initialState = InputState.def,
    this.tagText,
    this.keyboardType,
    this.obscureText = false,
    this.controller,
    this.prefix,
    this.hintText,
  });

  @override
  CustomInputState createState() => CustomInputState();
}

class CustomInputState extends State<CustomInput> {
  late InputState _currentState;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
  }

  void _updateState(InputState newState) {
    if (_currentState != newState) {
      setState(() {
        _currentState = newState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Color tagColor;
    List<BoxShadow>? shadows;
    FontWeight fontWeight;

    switch (_currentState) {
      case InputState.def:
        backgroundColor = AppColors.surface1;
        borderColor = AppColors.border;
        textColor = AppColors.ink4;
        tagColor = AppColors.ink5;
        fontWeight = FontWeight.w600;
        break;
      case InputState.active:
        backgroundColor = Colors.white;
        borderColor = AppColors.admin;
        textColor = AppColors.ink;
        tagColor = AppColors.admin;
        fontWeight = FontWeight.w700;
        shadows = [
          const BoxShadow(
            color: Color(0x143447E8), // 0.08 opacity
            blurRadius: 0,
            spreadRadius: 3,
            offset: Offset(0, 0),
          )
        ];
        break;
      case InputState.ok:
        backgroundColor = AppColors.okSurface;
        borderColor = const Color(0x330A7050); // 0.2 opacity
        textColor = AppColors.ok;
        tagColor = AppColors.ok;
        fontWeight = FontWeight.w600;
        break;
      case InputState.error:
        backgroundColor = AppColors.errorSurface;
        borderColor = const Color(0x2EB82428); // 0.18 opacity
        textColor = AppColors.error;
        tagColor = AppColors.error;
        fontWeight = FontWeight.w600;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!.toUpperCase(),
            style: AppTypography.label,
          ),
          const SizedBox(height: 8),
        ],
        Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus && _currentState == InputState.def) {
              _updateState(InputState.active);
            } else if (!hasFocus && _currentState == InputState.active) {
              _updateState(InputState.def);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2), // Adjust vertical padding for TextField
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(10),
              boxShadow: shadows,
            ),
            child: Row(
              children: [
                if (widget.prefix != null) widget.prefix!,
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    initialValue: widget.controller == null ? widget.initialValue : null,
                    onChanged: widget.onChanged,
                    keyboardType: widget.keyboardType,
                    obscureText: widget.obscureText,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: fontWeight,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (widget.tagText != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      widget.tagText!.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: tagColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
