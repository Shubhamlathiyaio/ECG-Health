import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_documnet.dart';

class DocumentVault extends StatefulWidget {
  const DocumentVault({super.key});

  @override
  State<DocumentVault> createState() => _DocumentVaultState();
}

class _DocumentVaultState extends State<DocumentVault> {
  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  bool isLoading = false;
  List<String> folderNames = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Vault'),
      ),
      floatingActionButton: buildSpeedDial(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.blue,
            ))
          : folderNames.isEmpty
              ? const Center(
                  child: Text('Folder is empty',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 50,
                      crossAxisSpacing: 50,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    itemCount: folderNames.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onLongPress: () {
                          _showDeleteConfirmationDialog(folderNames[index]);
                        },
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ViewDocument(folder: folderNames[index]);
                              },
                            ));
                          },
                          child: Card(
                            color: Colors.blue,
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Expanded(
                                      child: Icon(Icons.folder,
                                          size: 50.0, color: Colors.white)),
                                  Text(
                                    folderNames[index],
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  List<Map<String, String>> fileNames = [];

  fetchFiles(String folderName) async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String number = prefs.getString("Login_Number") ?? '';
    DatabaseReference folderRef = FirebaseDatabase.instance
        .ref('users/$number/documentVault/$folderName');

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
                'key': key, // Store the key
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
        });
        _deleteFolder(folderName);
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

  Future<void> _fetchFolders() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String number = prefs.getString("Login_Number") ?? '';

    DatabaseReference folderRef =
        FirebaseDatabase.instance.ref('users/$number').child('documentVault');

    try {
      DatabaseEvent folderEvent = await folderRef.once();
      DataSnapshot folderSnapshot = folderEvent.snapshot;
      if (folderSnapshot.value != null && folderSnapshot.value is Map) {
        Map<dynamic, dynamic> roomsData =
            folderSnapshot.value as Map<dynamic, dynamic>;

        List<String> allFolderNames = [];
        roomsData.forEach((folderName, _) {
          allFolderNames.add(folderName.toString());
        });

        setState(() {
          folderNames = allFolderNames;
        });
      }
    } catch (error) {
      print("Error fetching rooms: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteFolder(String folderName) async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String number = prefs.getString("Login_Number") ?? '';

    DatabaseReference folderRef = FirebaseDatabase.instance
        .ref('users/$number')
        .child('documentVault')
        .child(folderName);

    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      for (int i = 0; i < fileNames.length; i++) {
        final Reference storageRef =
            storage.ref('documents/${fileNames[i]['name']}');
        await storageRef.delete();
        print("Delete from Firebase Storage successful.");
      }
      await folderRef.remove();
      setState(() {
        folderNames.remove(folderName);
        isLoading = false;
      });
    } catch (error) {
      print("Error deleting folder: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  saveDataFirebase(String folderName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String number = prefs.getString("Login_Number") ?? '';
    final databaseRef = FirebaseDatabase.instance
        .ref('users/$number')
        .child('documentVault')
        .child(folderName);
    await databaseRef.set({
      'folder': folderName,
    });
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
          child: const Icon(Icons.folder, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () {
            createNewFolderDialog();
          },
          label: 'New Folder',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
    );
  }

  createNewFolderDialog() {
    final TextEditingController folderNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(hintText: 'Enter folder name'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                saveDataFirebase(folderNameController.text);
                _fetchFolders();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String folderName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Folder'),
          content:
              Text('Are you sure you want to delete the folder "$folderName"?'),
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
                Navigator.of(context).pop();

                fetchFiles(folderName);
              },
            ),
          ],
        );
      },
    );
  }
}
