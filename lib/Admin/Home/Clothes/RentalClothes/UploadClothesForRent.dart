import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jemeel/config/config.dart';

class UploadRentalClothesPage extends StatefulWidget {
  const UploadRentalClothesPage({super.key});

  @override
  _UploadRentalClothesPageState createState() =>
      _UploadRentalClothesPageState();
}

class _UploadRentalClothesPageState extends State<UploadRentalClothesPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles = [];
  final TextEditingController _rentalPriceController = TextEditingController();

  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _pickupLocationController =
      TextEditingController();

  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  List<String> selectedSizes = [];
  bool isUploading = false;

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _imageFiles = pickedFiles;
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  Future<List<String>> _uploadImages(List<XFile> imageFiles) async {
    List<String> downloadUrls = [];
    for (var imageFile in imageFiles) {
      File file = File(imageFile.path);
      String fileName = imageFile.name;
      Reference storageReference =
          FirebaseStorage.instance.ref().child('rentalClothesImages/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles!.removeAt(index);
    });
  }

  Future<void> _uploadRentalClothes() async {
    if (_nameController.text.isEmpty ||
        _rentalPriceController.text.isEmpty ||
        selectedSizes.isEmpty ||
        _imageFiles == null ||
        _imageFiles!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please complete all required fields and select images.",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => isUploading = true);

    try {
      List<String> imageUrls = await _uploadImages(_imageFiles!);

      await FirebaseFirestore.instance.collection("rentalClothes").add({
        "name": _nameController.text.trim(),
        "brand": _brandController.text.trim(),
        "rentalPrice": double.parse(_rentalPriceController.text),
        "details": _detailsController.text.trim(),
        "images": imageUrls,
        "pickupLocation": _pickupLocationController.text.trim(),
        "sizes": selectedSizes,
        "status": "Available",
        'uploadTime': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Clothes uploaded for rent successfully!"),
        backgroundColor: Colors.green,
      ));

      setState(() {
        _nameController.clear();
        _brandController.clear();
        _pickupLocationController.clear();
        _rentalPriceController.clear();
        _detailsController.clear();
        _imageFiles = [];
        selectedSizes = [];
        isUploading = false;
      });
    } catch (e) {
      print("Error uploading rental clothes: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error uploading clothes. Please try again."),
        backgroundColor: Colors.red,
      ));
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Crown.primraryColor,
        title: const Text(
          'Upload Clothes for Rent',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Images",
                  style: TextStyle(
                      color: Crown.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
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
                        Text("Pick Multiple Images",
                            style: TextStyle(color: Crown.primraryColor)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _imageFiles != null && _imageFiles!.isNotEmpty
                  ? Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                        _imageFiles!.length,
                        (index) => Stack(
                          children: [
                            Image.file(
                              File(_imageFiles![index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error,
                                    color: Colors.red);
                              },
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Text("No images selected.",
                      style: TextStyle(color: Colors.black.withOpacity(0.5))),
              const SizedBox(height: 20),
              Text("Select Sizes",
                  style: TextStyle(
                      color: Crown.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: _sizes.map((size) {
                  return ChoiceChip(
                    label: Text(size),
                    selected: selectedSizes.contains(size),
                    onSelected: (selected) => setState(() {
                      selected
                          ? selectedSizes.add(size)
                          : selectedSizes.remove(size);
                    }),
                    selectedColor: Crown.primraryColor,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: selectedSizes.contains(size)
                          ? Colors.white
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              buildTextField(
                  controller: _nameController,
                  hintText: "Enter name of the clothing",
                  icon: Icons.edit),
              const SizedBox(height: 20),
              buildTextField(
                  controller: _brandController,
                  hintText: "Enter brand (optional)",
                  icon: Icons.branding_watermark),
              const SizedBox(height: 20),
              buildTextField(
                  controller: _rentalPriceController,
                  hintText: "Enter rental price per day",
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              buildTextField(
                  controller:
                      _pickupLocationController, // New Pickup Location Controller
                  hintText: "Enter pickup location",
                  icon: Icons.location_on),
              const SizedBox(height: 20),
              buildTextField(
                  controller: _detailsController,
                  hintText: "Enter additional details",
                  icon: Icons.info,
                  maxLines: 3),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: isUploading ? null : _uploadRentalClothes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Crown.buttonColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                  child: isUploading
                      ? CircularProgressIndicator(color: Crown.primraryColor)
                      : const Text("Upload Rental Clothes",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      cursorColor: Colors.black,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Crown.primraryColor),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Crown.primraryColor, width: 1)),
        enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Crown.textColor.withOpacity(0.5), width: 1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
