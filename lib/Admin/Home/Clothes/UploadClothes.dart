import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jemeel/config/config.dart';

class UploadClothesPage extends StatefulWidget {
  const UploadClothesPage({super.key});

  @override
  _UploadClothesPageState createState() => _UploadClothesPageState();
}

class _UploadClothesPageState extends State<UploadClothesPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles = [];
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final List<dynamic> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  List<dynamic> selectedSizes = []; // List to store selected sizes
  bool isUploading = false;

  // Method to pick multiple images
  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          _imageFiles = pickedFiles;
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  // Method to upload images to Firebase Storage and return the download URLs
  Future<List<String>> _uploadImages(List<XFile> imageFiles) async {
    List<String> downloadUrls = [];
    for (var imageFile in imageFiles) {
      File file = File(imageFile.path);
      String fileName = imageFile.name;
      Reference storageReference =
          FirebaseStorage.instance.ref().child('clothesImages/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  } // Method to remove a selected image

  void _removeImage(int index) {
    setState(() {
      _imageFiles!.removeAt(index);
    });
  }

  // Method to upload clothes data to Firebase Firestore
  Future<void> _uploadClothes() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
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

    setState(() {
      isUploading = true;
    });

    try {
      List<String> imageUrls = await _uploadImages(_imageFiles!);

      // Create a new document in the "clothes" collection with the entered data
      await FirebaseFirestore.instance.collection("clothes").add({
        "name": _nameController.text,
        "brand": _brandController.text,

        "price": double.parse(_priceController.text),
        "details": _detailsController.text,
        "images": imageUrls, // Store the list of image URLs
        "uploadTime": DateTime.now(), // Store the current date and time
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Clothes uploaded successfully!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));

      // Clear the form and images after successful upload
      setState(() {
        _nameController.clear();
        _brandController.clear();
        _priceController.clear();
        _detailsController.clear();
        _imageFiles = [];
        isUploading = false;
      });
    } catch (e) {
      print("Error uploading clothes: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error uploading clothes. Please try again."),
        backgroundColor: Colors.red,
      ));
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Jemeel.primraryColor,
        title: const Text(
          'Upload Clothes',
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
              // Image picker section
              Text(
                "Images",
                style: TextStyle(
                  color: Jemeel.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Jemeel.primraryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Jemeel.primraryColor),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image,
                            color: Jemeel.primraryColor, size: 40),
                        const SizedBox(height: 5),
                        Text(
                          "Pick Multiple Images",
                          style: TextStyle(color: Jemeel.primraryColor),
                        ),
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
                                onPressed: () {
                                  _removeImage(index);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Text(
                      "No images selected.",
                      style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                children: _sizes.map((size) {
                  return ChoiceChip(
                    label: Text(size),
                    selected: selectedSizes.contains(size),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? selectedSizes.add(size)
                            : selectedSizes.remove(size);
                      });
                    },
                    selectedColor: Jemeel.primraryColor,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: selectedSizes.contains(size)
                          ? Colors.white
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              // Name field
              buildTextField(
                controller: _nameController,
                hintText: "Enter name of the clothing",
                icon: Icons.edit,
              ),
              const SizedBox(height: 20),

              // Brand field
              buildTextField(
                controller: _brandController,
                hintText: "Enter brand (optional)",
                icon: Icons.branding_watermark,
              ),
              const SizedBox(height: 20),

              // Price field
              buildTextField(
                controller: _priceController,
                hintText: "Enter price",
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Details field
              buildTextField(
                controller: _detailsController,
                hintText: "Enter additional details",
                icon: Icons.info,
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Upload button
              Center(
                child: ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () {
                          _uploadClothes();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Jemeel.buttonColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: isUploading
                      ? CircularProgressIndicator(
                          color: Jemeel.buttonColor,
                        )
                      : const Text(
                          "Upload Clothes",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable method to build a text field with consistent styling
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
        prefixIcon: Icon(icon, color: Jemeel.primraryColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Jemeel.primraryColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Jemeel.textColor.withOpacity(0.5), width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
