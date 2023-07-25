import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ThemeHelper {
  InputDecoration textInputDecoration(
      [String labelText = "", String hintText = ""]) {
    return InputDecoration(
        fillColor: Colors.white,
        filled: true,
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color(0xFFC9C9C9),
                width: 1.0
            ),
            borderRadius: BorderRadius.circular(20.0)
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color(0xFF959595),
                width: 2.0
            ),
            borderRadius: BorderRadius.circular(20.0)
        ),
        disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.transparent,
                width: 1.0
            ),
            borderRadius: BorderRadius.circular(20.0)
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14.0,
          color: Colors.grey,
        )
    );
  }

  BoxDecoration inputBoxDecorationShaddow() {
    return BoxDecoration(boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 5),
      )
    ]);
  }

  BoxDecoration buttonBoxDecoration(
    BuildContext context, [String color1 = "", String color2 = ""]) {

      Color c1 = Theme.of(context).primaryColor;
      Color c2 = Theme.of(context).colorScheme.secondary;

      if (color1.isEmpty == false) {
        c1 = HexColor(color1);
      }
      if (color2.isEmpty == false) {
        c2 = HexColor(color2);
      }

    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade500,
          blurRadius: 10,
          offset: const Offset(2, 2),
        )
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 1.0],
        colors: [ c1, c2, ],
      ),
      color: Colors.lightGreen.shade300,
      borderRadius: BorderRadius.circular(30),
    );
  }

  ButtonStyle buttonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      minimumSize: MaterialStateProperty.all(const Size(50, 50)),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
    );
  }

  AlertDialog alartDialog(String title, String content, BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black38)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class LoginFormStyle {}
