
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
 
/// Avatar con botón de cámara. Maneja el menú Galería/Cámara
/// y avisa a la pantalla padre mediante [onImagenSeleccionada].
class FotoPerfilSelector extends StatelessWidget {
  final File? imagen;
  final ValueChanged<File> onImagenSeleccionada;
 
  FotoPerfilSelector({
    super.key,
    required this.imagen,
    required this.onImagenSeleccionada,
  });
 
  final ImagePicker _picker = ImagePicker();
 
  Future<void> _tomarImagen(ImageSource source) async {
    final XFile? foto = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (foto != null) {
      onImagenSeleccionada(File(foto.path));
    }
  }
 
  void _mostrarOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _tomarImagen(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _tomarImagen(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFD9D9D9),
            backgroundImage: imagen != null ? FileImage(imagen!) : null,
            child: imagen == null
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: const Color(0xFF3B82F6),
              radius: 18,
              child: IconButton(
                icon: const Icon(Icons.camera_alt,
                    size: 18, color: Colors.white),
                onPressed: () => _mostrarOpciones(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 