import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final FormFieldSetter<String> onSaved;
  final maxLength;
  final enabled;
  final Icon icon;
  final String hint;
  final bool obsecure;
  final FormFieldValidator<String> validator;
  final autofocus;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldSetter<String> onChanged;

  CustomTextField(
      {this.icon,
      this.maxLength = 0,
      this.enabled = true,
      this.hint,
      this.obsecure = false,
      this.validator,
      this.onSaved,
      this.autofocus = true,
      this.focusNode,
      this.controller,
      this.onChanged});

  _CustomTextFieldState createState() => _CustomTextFieldState(
        icon: icon,
        maxLength: maxLength,
        enabled: enabled,
        hint: hint,
        obsecure: obsecure,
        validator: validator,
        onSaved: onSaved,
        autofocus: autofocus,
        focusNode: focusNode,
        controller: controller,
        onChanged: onChanged,
      );
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FormFieldSetter<String> onSaved;
  final maxLength;
  final enabled;
  final Icon icon;
  final String hint;
  final bool obsecure;
  final FormFieldValidator<String> validator;
  final autofocus;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldSetter<String> onChanged;

  bool switchObscure = false;

  _CustomTextFieldState(
      {this.icon,
      this.maxLength = 0,
      this.enabled = true,
      this.hint,
      this.obsecure = false,
      this.validator,
      this.onSaved,
      this.autofocus = true,
      this.focusNode,
      this.controller,
      this.onChanged}) {
    switchObscure = obsecure;
  }

  void _showText() {
    setState(() {
      switchObscure = !switchObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sufficIcon = Padding(
      padding: EdgeInsets.only(left: 10, right: 30),
      child: IconButton(
        icon: Icon(Icons.remove_red_eye,
            color: switchObscure ? Colors.grey : Colors.blue),
        onPressed: () => _showText(),
      ),
    );

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          primaryColor: Theme.of(context).colorScheme.primary,
          hintColor: Theme.of(context).colorScheme.onBackground,
        ),
        child: TextFormField(
          maxLength: maxLength > 0 ? maxLength: null,
          maxLengthEnforced: maxLength > 0 ? true: false,
          enabled: enabled,
          focusNode: this.focusNode,
          onSaved: onSaved,
          onChanged: onChanged,
          validator: validator,
          autofocus: autofocus,
          obscureText: switchObscure,
          controller: controller,
          style: Theme.of(context).textTheme.body1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.body2,
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
            contentPadding: EdgeInsets.all(0),
            prefixIcon: Padding(
              child: IconTheme(
                data: IconThemeData(
                    color: Theme.of(context).colorScheme.onBackground),
                child: icon,
              ),
              padding: EdgeInsets.only(left: 30, right: 10),
            ),
            suffixIcon: obsecure ? sufficIcon : Padding(padding: EdgeInsets.only(right: 30),),
          ),
        ),
      ),
    );
  }
}
