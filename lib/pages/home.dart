import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tubes_grup1/authentication.dart';
import 'package:tubes_grup1/crud_nonapp.dart';
import 'package:tubes_grup1/pages/login.dart';
import 'package:tubes_grup1/pages/transaction.dart';

class MainPage extends StatelessWidget {
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File fileToUpload = File(result.files.single.path!);
        String fileName =
            'file_${DateTime.now().millisecondsSinceEpoch}${fileToUpload.path.split('/').last}';
        firebase_storage.Reference ref =
            _storage.ref().child('Files').child(fileName);
        await ref.putFile(fileToUpload);
        print('File uploaded successfully!');
      } else {
        // User canceled file picking
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> downloadFile() async {
    try {
      String fileName = 'file_17035729985741.pdf'; //<-- Edit this as your need
      firebase_storage.Reference ref =
          _storage.ref().child('Files').child(fileName);
      // Get the Downloads directory
      final directory = "/storage/emulated/0/Download";
      // Create a new File instance with the desired path
      final File file = File('${directory}/$fileName');
      // Download the file and save it to the device's Downloads folder
      await ref.writeToFile(file);
      print('File downloaded successfully to: ${file.path}');
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              AuthService().signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Home'),
                Tab(text: 'Transaction'),
                // Tab(text: 'CRUD')
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              // Content for Tab 1
              Home(),
              // Content for Tab 2
              Transaction()
              // Column(
              //   children: [
              //     const SizedBox(height: 20),
              //     const Center(
              //       child: Text('Download File'),
              //     ),
              //     const SizedBox(height: 20),
              //     IconButton(
              //       icon: const Icon(Icons.download),
              //       onPressed: () async {
              //         await downloadFile();
              //       },
              //     ),
              //   ],
              // ),
              // Content for Tab 3
              // Column(
              //   children: [
              //     const SizedBox(height: 20),
              //     const Center(
              //       child: Text('Go to Students Data'),
              //     ),
              //     IconButton(
              //       icon: const Icon(Icons.accessibility),
              //       onPressed: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => CRUD(),
              //           ),
              //         );
              //       },
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: Image.asset('images/ahda.jpg'),
            ),
            const Text(
              'Ahda Akmalul Ilmi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text('1101202381')
          ],
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: Image.asset(
                  'images/placeholder.png'), // Ganti placeholder jadi nama file fotonya
            ),
            const Text(
              'Faris',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text('nim')
          ],
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: Image.asset(
                  'images/placeholder.png'), // Ganti placeholder jadi nama file fotonya
            ),
            const Text(
              'Indah',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text('nim')
          ],
        ),
      ],
    );
  }
}

class Transaction extends StatelessWidget {
  const Transaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Data'),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('transactions').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print(snapshot);
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          List<TransactionData> TransactionList =
              snapshot.data!.docs.map((DocumentSnapshot document) {
            return TransactionData.fromDocument(document);
          }).toList();
          return ListView.builder(
            itemCount: TransactionList.length,
            itemBuilder: (context, index) {
              TransactionData documents = TransactionList[index];
              return ListTile(
                title: Text(
                    '${documents.type} - ${documents.description} - ${documents.username}'),
                subtitle: Text('Total: ${documents.total}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailPage(
                        transaction: documents,
                      ),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Confirmation'),
                          content: const Text(
                              'Are you sure you want to delete this item?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                print(documents.timestamp);
                                deleteTransaction(
                                    '${documents.timestamp}-${documents.total}');
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionAddPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void deleteTransaction(String doc) {
    FirebaseFirestore.instance.collection('transactions').doc(doc).delete();
  }
}
