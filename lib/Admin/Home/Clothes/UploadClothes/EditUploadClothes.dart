import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jemeel/Admin/Home/Clothes/UploadClothes/AllClothes.dart';
import 'package:jemeel/config/config.dart';

class EditClothesPage extends StatefulWidget {
  final ClothingItem clothingItem;

  const EditClothesPage({super.key, required this.clothingItem});

  @override
  _EditClothesPageState createState() => _EditClothesPageState();
}

class _EditClothesPageState extends State<EditClothesPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _newImages = [];
  List<String> _existingImages = [];
  final List<String> _imagesToDelete = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.clothingItem.name;
    _brandController.text = widget.clothingItem.brand;
    _priceController.text = widget.clothingItem.price.toStringAsFixed(2);
    _detailsController.text = widget.clothingItem.details;
    _existingImages = List.from(widget.clothingItem.images);
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newImages = [...?_newImages, ...pickedFiles];
        });
      }
    } catch (e) {
      _showError("Error picking images: $e");
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages!.removeAt(index);
    });
  }

  void _markImageForDeletion(int index) {
    setState(() {
      _imagesToDelete.add(_existingImages[index]);
      _existingImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadNewImages() async {
    List<String> downloadUrls = [];
    for (var imageFile in _newImages!) {
      File file = File(imageFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('clothesImages/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  Future<void> _deleteMarkedImages() async {
    for (String url in _imagesToDelete) {
      try {
        await FirebaseStorage.instance.refFromURL(url).delete();
      } catch (e) {
        print("Error deleting image: $e");
      }
    }
  }

  Future<void> _updateClothes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload new images
      List<String> newImageUrls = await _uploadNewImages();

      // Delete marked images
      await _deleteMarkedImages();

      // Combine existing and new images
      List<String> allImages = [..._existingImages, ...newImageUrls];

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('clothes')
          .doc(widget.clothingItem.id)
          .update({
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim(),
        'price': double.parse(_priceController.text),
        'details': _detailsController.text.trim(),
        'images': allImages,
        'uploadTime': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context, true); // Return success
    } catch (e) {
      _showError("Error updating clothes: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Clothing Item'),
        backgroundColor: Crown.primraryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateClothes,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 20),
                    _buildFormFields(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Images",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Crown.primraryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Crown.primraryColor),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, color: Crown.primraryColor, size: 40),
                  const SizedBox(height: 5),
                  Text("Add New Images",
                      style: TextStyle(color: Crown.primraryColor)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._existingImages
                .asMap()
                .entries
                .map((entry) => _buildExistingImage(entry.key, entry.value)),
            ...?_newImages
                ?.asMap()
                .entries
                .map((entry) => _buildNewImage(entry.key, entry.value)),
          ],
        ),
      ],
    );
  }

  Widget _buildExistingImage(int index, String url) {
    return Stack(
      children: [
        Image.network(
          url,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        Positioned(
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _markImageForDeletion(index),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImage(int index, XFile file) {
    return Stack(
      children: [
        Image.file(
          File(file.path),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        Positioned(
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _removeNewImage(index),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: "Item Name"),
          validator: (value) => value!.isEmpty ? "Required" : null,
        ),
        TextFormField(
          controller: _brandController,
          decoration: const InputDecoration(labelText: "Brand (optional)"),
        ),
        TextFormField(
          controller: _priceController,
          decoration: const InputDecoration(labelText: "Price"),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) return "Required";
            if (double.tryParse(value) == null) return "Invalid price";
            return null;
          },
        ),
        TextFormField(
          controller: _detailsController,
          decoration: const InputDecoration(labelText: "Details"),
          maxLines: 3,
        ),
      ],
    );
  }
}
