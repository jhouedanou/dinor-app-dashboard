import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.iconData,
    this.isPasswordField = false,
    required this.editingController,
    required this.enabled,
    this.isOutlined = false,
    this.isEmailField = false,
  });

  final String labelText;
  final IconData iconData;
  final bool isPasswordField;
  final TextEditingController editingController;
  final bool enabled;
  final bool isOutlined;
  final bool isEmailField;


  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {

  bool _obscureText = true ;
  RegExp get _emailRegex => RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  Widget build(BuildContext context) {

    return TextFormField(
      validator: (value) {
        if(widget.isEmailField == true){
          if (!_emailRegex.hasMatch(value!)) {
            return 'Adresse E-mail invalide';
          }
        }else{
          if(value!.isEmpty){
            return 'Ce champs est obligatoire';
          }
        }
        return null;
      },
      style: GoogleFonts.roboto(
          color: Colors.black.withOpacity(0.7)
      ),
      decoration: InputDecoration(
        border: widget.isOutlined == true ? const OutlineInputBorder() : null,
        focusColor: const Color(0xFF159e72),
        fillColor: const Color(0xFF159e72),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF159e72), width: 2)
        ),
        labelText: widget.labelText.toUpperCase(),
        labelStyle: GoogleFonts.roboto(
            color: Colors.black.withOpacity(0.7), fontSize: 8
        ),
        prefixIcon: widget.iconData == widget.iconData ? Icon( widget.iconData,color: Colors.red,): null,
        suffixIcon: widget.isPasswordField
            ? _buildPasswordFieldVisibilityToggle()
            : null,
      ),
      cursorColor: const Color(0xFF159e72),
      obscureText: widget.isPasswordField ? _obscureText : false,
      controller: widget.editingController,
      enabled: widget.enabled,
    );
  }

  Widget _buildPasswordFieldVisibilityToggle() {
    return IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,color: Colors.red,
      ),
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }
}
