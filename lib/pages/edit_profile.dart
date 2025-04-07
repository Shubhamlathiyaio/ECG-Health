import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController userName = TextEditingController();
  TextEditingController email = TextEditingController();
  bool isMale = true;
  bool isFemale = false;
  bool isOther = false;
  String isEmail = '';
  String isUserName = '';
  String isPhoto = '';
  bool isLoading = false;
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getDataFromFirebase();
  }

  getDataFromFirebase() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    String number = sharedPreferences.getString("Login_Number") ?? '';
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('users/$number/Profile');
    ref.onValue.listen((DatabaseEvent event) async {
      if (mounted) {
        setState(() {
          isEmail = event.snapshot.child('email').value.toString();
          isUserName = event.snapshot.child('userName').value.toString();
          isPhoto = event.snapshot.child('imageUrl').value.toString();
        });
      }
    });
  }

  editData() async {
    setState(() {
      isLoading = true;
    });
    var sharedPreferences = await SharedPreferences.getInstance();
    String number = sharedPreferences.getString("Login_Number") ?? '';
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('users/$number/Profile');

    String? imageUrl = isPhoto;

    if (_image != null) {
      try {
        if (isPhoto != 'null' && isPhoto.isNotEmpty) {
          final storageRef = FirebaseStorage.instance.refFromURL(isPhoto);
          await storageRef.putFile(_image!);
          imageUrl = await storageRef.getDownloadURL();
        } else {
          final newStorageRef = FirebaseStorage.instance.ref().child(
              'users_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
          await newStorageRef.putFile(_image!);
          imageUrl = await newStorageRef.getDownloadURL();
        }
      } catch (e) {
        final newStorageRef = FirebaseStorage.instance
            .ref()
            .child('users_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await newStorageRef.putFile(_image!);
        imageUrl = await newStorageRef.getDownloadURL();
      }
    }

    await ref.update({
      'email': email.text.isEmpty ? isEmail : email.text,
      'userName': userName.text.isEmpty ? isUserName : userName.text,
      'imageUrl': imageUrl,
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _pickImage();
                          },
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.grey.shade200,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : (isPhoto == 'null' || isPhoto.isEmpty
                                      ? const AssetImage('assets/boy.png')
                                      : NetworkImage(isPhoto)) as ImageProvider,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 1,
                          right: 1,
                          child: GestureDetector(
                            onTap: () {
                              _pickImage();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.white,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(2, 4),
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 3,
                                    ),
                                  ]),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(Icons.add_a_photo,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        ' Enter New User Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500]),
                      ),
                      TextField(
                        controller: userName,
                        cursorColor: const Color(0xFF0B84FE),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: isUserName,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        ' Enter New Email',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500]),
                      ),
                      TextField(
                        controller: email,
                        cursorColor: const Color(0xFF0B84FE),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: isEmail,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B84FE),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (userName.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Enter UserName')),
                                );
                              } else if (email.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Enter email')));
                              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(email.text.trim())) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Enter Valid Email")));
                              } else {
                                editData();
                              }
                            },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
