import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final enabled;
  final Icon icon;
  final String hint;
  final bool obsecure;
  final FormFieldValidator<String> validator;
  final autofocus;
  final TextEditingController controller;
  final FocusNode focusNode;

  CustomTextField(
      {this.icon,
        this.enabled = true,
        this.hint,
        this.obsecure = false,
        this.validator,
        this.onSaved,
        this.autofocus = true,
        this.focusNode = null,
        this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          primaryColor: Theme.of(context).colorScheme.primary,
          hintColor: Theme.of(context).colorScheme.onBackground,
        ),
        child: TextFormField(
          enabled: enabled,
          focusNode: this.focusNode,
          onSaved: onSaved,
          validator: validator,
          autofocus: autofocus,
          obscureText: obsecure,
          controller: controller,
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface
          ),
          decoration: InputDecoration(
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              hintText: hint,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onBackground,
                  width: 1,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onBackground,
                  width: 2,
                ),
              ),
              prefixIcon: Padding(
                child: IconTheme(
                  data: IconThemeData(color: Theme.of(context).colorScheme.onBackground),
                  child: icon,
                ),
                padding: EdgeInsets.only(left: 30, right: 10),
              )),
        ),
      ),
    );
  }
}