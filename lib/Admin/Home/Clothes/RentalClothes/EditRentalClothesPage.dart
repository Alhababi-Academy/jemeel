import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jemeel/Admin/Home/Clothes/RentalClothes/AllRentalClothesPage.dart';
import 'package:jemeel/config/config.dart';

class EditRentalClothesPage extends StatefulWidget {
  final ClothingItem clothingItem;

  const EditRentalClothesPage({super.key, required this.clothingItem});

  @override
  _EditRentalClothesPageState createState() => _EditRentalClothesPageState();
}

class _EditRentalClothesPageState extends State<EditRentalClothesPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _newImages = [];
  List<String> _existingImages = [];
  final List<String> _imagesToDelete = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  List<String> selectedSizes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.clothingItem.name;
    _brandController.text = widget.clothingItem.brand;
    _priceController.text = widget.clothingItem.rentalPrice.toStringAsFixed(2);
    _existingImages = List.from(widget.clothingItem.images);
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() => _newImages = [...?_newImages, ...pickedFiles]);
      }
    } catch (e) {
      _showError("Error picking images: $e");
    }
  }

  void _removeNewImage(int index) {
    setState(() => _newImages!.removeAt(index));
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
          FirebaseStorage.instance.ref().child('rentalClothesImages/$fileName');
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

  Future<void> _updateRentalClothes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      List<String> newImageUrls = await _uploadNewImages();
      await _deleteMarkedImages();

      await FirebaseFirestore.instance
          .collection('rentalClothes')
          .doc(widget.clothingItem.id)
          .update({
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim(),
        'rentalPrice': double.parse(_priceController.text),
        'rentalDuration': _durationController.text.trim(),
        'details': _detailsController.text.trim(),
        'images': [..._existingImages, ...newImageUrls],
        'sizes': selectedSizes,
        'status': widget.clothingItem.status,
        'uploadTime': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context, true);
    } catch (e) {
      _showError("Error updating rental clothes: $e");
    } finally {
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
        title: const Text('Edit Rental Item'),
        backgroundColor: Crown.primraryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateRentalClothes,
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
                    _buildSizeSelection(),
                    _buildFormFields(),
                    const SizedBox(height: 30),
                    _buildUpdateButton(),
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

  Widget _buildSizeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Sizes",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: _sizes
              .map((size) => ChoiceChip(
                    label: Text(size),
                    selected: selectedSizes.contains(size),
                    onSelected: (selected) => setState(() => selected
                        ? selectedSizes.add(size)
                        : selectedSizes.remove(size)),
                    selectedColor: Crown.primraryColor,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: selectedSizes.contains(size)
                          ? Colors.white
                          : Colors.black,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          hintText: "Enter name of the clothing",
          icon: Icons.edit,
          validator: (value) => value!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _brandController,
          hintText: "Enter brand (optional)",
          icon: Icons.branding_watermark,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _priceController,
          hintText: "Enter rental price per day",
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) return "Required";
            if (double.tryParse(value) == null) return "Invalid price";
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _durationController,
          hintText: "Enter rental duration (e.g., 3 days)",
          icon: Icons.calendar_today,
          validator: (value) => value!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _detailsController,
          hintText: "Enter additional details",
          icon: Icons.info,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateRentalClothes,
        style: ElevatedButton.styleFrom(
          backgroundColor: Crown.buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text(
          "Update Rental Clothes",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      cursorColor: Colors.black,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Crown.primraryColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Crown.primraryColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Crown.textColor.withOpacity(0.5), width: 1),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
