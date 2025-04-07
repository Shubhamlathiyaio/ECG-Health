// ignore_for_file: avoid_print

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewDocument extends StatefulWidget {
  final String folder;

  ViewDocument({Key? key, required this.folder}) : super(key: key);

  @override
  State<ViewDocument> createState() => _ViewDocumentState();
}

class _ViewDocumentState extends State<ViewDocument> {

  @override
  void initState() {
    super.initState();
    _fetchDevice();
    fetchFiles();
  }

  String keys = '';
  bool isLoading = false;

  List<Map<String, String>> fileNames = [];

  fetchFiles() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String number = prefs.getString("Login_Number") ?? '';
    DatabaseReference folderRef = FirebaseDatabase.instance
        .ref('users/$number/documentVault/${widget.folder}');

    try {
      DatabaseEvent folderEvent = await folderRef.once();
      DataSnapshot folderSnapshot = folderEvent.snapshot;

      if (folderSnapshot.value != null && folderSnapshot.value is Map) {
        Map<dynamic, dynamic> roomsData =
        folderSnapshot.value as Map<dynamic, dynamic>;

        List<Map<String, String>> allFolderNames = [];

        roomsData.forEach((key, value) {
          if (key != 'folder' && value is Map) {
            if (value.containsKey('name') && value.containsKey('url')) {
              allFolderNames.add({
                'key': key,  // Store the key
                'name': value['name'],
                'url': value['url']
              });
            } else {
              print('Skipping key: $key as it does not contain name and url');
            }
          }
        });

        setState(() {
          fileNames = allFolderNames;
          isLoading = false;
          print('fileNames = $fileNames');
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching rooms: $error");
    }
  }

  Future<void> _fetchDevice() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String loginNumber = prefs.getString("Login_Number") ?? '';

      DatabaseReference deviceRef = FirebaseDatabase.instance
          .ref()
          .child('users/$loginNumber/documentVault/${widget.folder}');

      DatabaseEvent dataSnapshot = await deviceRef.once();
      DataSnapshot livingRoomSnapshot = dataSnapshot.snapshot;

      if (livingRoomSnapshot.value != null) {
        Map<dynamic, dynamic>? values =
            livingRoomSnapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          values.forEach((key, value) {
            keys = key;
            print('keyss1: $keys');
          });

          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching devices: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder),
      ),
      floatingActionButton: buildSpeedDial(),
      body: isLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: CircularProgressIndicator(
                  color: Colors.blue,
                  backgroundColor: Colors.white,
                )),
              ],
            )
          : fileNames.isNotEmpty
              ? ListView.builder(
                  itemCount: fileNames.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () {
                        showDeleteDialog(index);
                      },
                      onTap: () {
                        if (fileNames[index]['name']!.endsWith('.pdf')) {
                          //file.path!
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewerScreen(
                                  filePath: fileNames[index]['url'].toString()),
                            ),
                          );
                        } else if (fileNames[index]['name']!.endsWith('.jpg') ||
                            fileNames[index]['name']!.endsWith('.png')) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImage(
                                  imagePath:
                                      fileNames[index]['url'].toString()),
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.all(10),
                        color: Colors.white,
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (fileNames[index]['name']!.endsWith('.jpg') ||
                                fileNames[index]['name']!.endsWith('.png'))
                              Image.network(
                                fileNames[index]['url']!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            else if (fileNames[index]['name']!.endsWith('.pdf'))
                              const Icon(Icons.picture_as_pdf)
                            else
                              const Icon(Icons.insert_drive_file),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${fileNames[index]['name']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        '"${widget.folder}" folder is empty',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    )
                  ],
                ),
    );
  }

  Future<void> deleteData(String key, String fileName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String loginNumber = prefs.getString("Login_Number") ?? '';
    DatabaseReference deviceRef = FirebaseDatabase.instance
        .ref('users/$loginNumber/documentVault/${widget.folder}');


    try {
      // Delete from Firebase Realtime Database
      await deviceRef.child(key).remove();
      print("Delete from Realtime Database successful.");

      // Delete from Firebase Storage
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference storageRef = storage.ref('documents/$fileName');
      await storageRef.delete();
      print("Delete from Firebase Storage successful.");

      // Refresh the list after deletion
      fetchFiles();
    } catch (error) {
      print("Delete failed: $error");
    }
  }

  showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: const Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                final String key = fileNames[index]['key']!;
                final String fileName = fileNames[index]['name']!;
                deleteData(key, fileName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 28.0),
      backgroundColor: Colors.blue,
      visible: true,
      curve: Curves.bounceInOut,
      children: [
        SpeedDialChild(
          shape: const CircleBorder(),
          child: const Icon(Icons.file_copy_rounded, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () async {
            await openFilePicker();
          },
          label: 'New File',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
    );
  }

  Future<void> openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null) {
      for (var file in result.files) {
        await saveFile(file);
        await saveFileToFirebase(file);
      }
    } else {
      // User canceled the picker
    }
  }

  // saveFile function use to save image/pdf to device
  Future<void> saveFile(PlatformFile file) async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final path = directory.path;
      final savedFile = File('$path/${file.name}');
      try {
        await savedFile.writeAsBytes(file.bytes!);
        print('File saved to $path/${file.name}');
      } catch (e) {
        print('Failed to save file: $e');
      }
    } else {
      print('Could not get external storage directory.');
    }
  }

  Future<void> saveFileToFirebase(PlatformFile file) async {
    setState(() {
      isLoading = true;
    });
    final storageRef =
        FirebaseStorage.instance.ref().child('documents/${file.name}');
    try {
      await storageRef.putData(file.bytes!);
      final downloadUrl = await storageRef.getDownloadURL();
      await saveFileToDatabase(file.name, downloadUrl);
      print('File uploaded to Firebase: $downloadUrl');
    } catch (e) {
      print('Failed to upload file: $e');
    }
  }

  Future<void> saveFileToDatabase(String fileName, String downloadUrl) async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String number = prefs.getString("Login_Number") ?? '';
    final databaseRef = FirebaseDatabase.instance
        .ref('users/$number/documentVault/${widget.folder}');
    await databaseRef.push().set({
      'name': fileName,
      'url': downloadUrl,
    });
    fetchFiles();
    print('File saved to Firebase Realtime Database');
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String filePath;

  const PdfViewerScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Image.network(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
