
import 'package:flutter/material.dart';
 
/// Estilo compartido de los campos del formulario.
InputDecoration estiloCampo(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFD9D9D9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}
 