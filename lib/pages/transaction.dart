import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionData {
  late String username;
  late String description;
  late String type;
  late double total;
  late DateTime timestamp;
  TransactionData({
    required this.username,
    required this.description,
    required this.type,
    required this.total,
    required this.timestamp,
  });
  factory TransactionData.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return TransactionData(
      username: data['username'],
      description: data['description'],
      type: data['type'],
      total: data['total'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class TransactionDetailPage extends StatefulWidget {
  final TransactionData transaction;
  TransactionDetailPage({required this.transaction});
  @override
  _TransactionDetailPageState createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late TransactionData _updatedMahasiswa;
  @override
  void initState() {
    super.initState();
    _updatedMahasiswa = widget.transaction;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mahasiswa Detail'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Username: ${_updatedMahasiswa.username}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Description: ${_updatedMahasiswa.description}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Total: ${_updatedMahasiswa.total}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Updated At: ${_updatedMahasiswa.timestamp}'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Menggunakan Navigator untuk membuka halaman Modify
              final updatedMahasiswa = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionModifyPage(transaction: _updatedMahasiswa),
                ),
              );
              // Memperbarui tampilan jika ada perubahan
              if (updatedMahasiswa != null) {
                setState(() {
                  _updatedMahasiswa = updatedMahasiswa as TransactionData;
                });
              }
            },
            child: const Text('Modify'),
          ),
        ],
      ),
    );
  }
}

class TransactionAddPage extends StatefulWidget {
  @override
  _TransactionAddPage createState() => _TransactionAddPage();
}

class _TransactionAddPage extends State<TransactionAddPage> {
  final TextEditingController nimController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nilaiController = TextEditingController();

  String selectedCategory = 'expenses';
  List<String> categories = ['expenses', 'incomes'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nimController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: nilaiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total',
              ),
            ),
            DropdownButton<String>(
              value: selectedCategory,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              underline: Container(
                height: 2,
                color: Colors.grey,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
                selectedCategory = newValue!;
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String username = nimController.text.trim();
                String description = namaController.text.trim();
                double total = double.tryParse(nilaiController.text) ?? 0.0;
                if (username.isNotEmpty && description.isNotEmpty) {
                  TransactionData newTransaction = TransactionData(
                    username: username,
                    description: description,
                    type: selectedCategory,
                    total: total,
                    timestamp: DateTime.now(),
                  );
                  addTransaction(newTransaction);
                  Navigator.pop(context);
                } else {
                  // Show an error message if input is invalid
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid Input'),
                        content: const Text('Please enter valid NIM and Name.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void addTransaction(TransactionData transaction) {
    FirebaseFirestore.instance
        .collection('transactions')
        .doc('${transaction.timestamp}-${transaction.total}')
        .set({
      'username': transaction.username,
      'description': transaction.description,
      'type': selectedCategory,
      'total': transaction.total,
      'timestamp': transaction.timestamp,
    });
  }
}

class TransactionModifyPage extends StatefulWidget {
  final TransactionData transaction;
  TransactionModifyPage({required this.transaction});
  @override
  _TransactionModifyPageState createState() => _TransactionModifyPageState();
}

class _TransactionModifyPageState extends State<TransactionModifyPage> {
  late TextEditingController namaController;
  late TextEditingController nilaiController;

  String selectedCategory = 'expenses';
  List<String> categories = ['expenses', 'incomes'];

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.transaction.username);
    nilaiController =
        TextEditingController(text: widget.transaction.total.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify Mahasiswa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${widget.transaction.username}'),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: nilaiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Timestamp'),
            ),
            DropdownButton<String>(
              value: selectedCategory,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              underline: Container(
                height: 2,
                color: Colors.grey,
              ),
              onChanged: (String? newValue) {
                // setState(() {
                //   selectedCategory = newValue!;
                // });
                selectedCategory = newValue!;
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String nama = namaController.text.trim();
                double nilai = double.tryParse(nilaiController.text) ?? 0.0;
                if (nama.isNotEmpty) {
                  TransactionData updatedTransaction = TransactionData(
                    username: widget.transaction.username,
                    description: nama,
                    type: selectedCategory,
                    total: nilai,
                    timestamp: DateTime.now(),
                  );
                  updateTransaction(updatedTransaction);
                  // Menggunakan Navigator untuk memberikan data kembali ke MahasiswaListPage
                  Navigator.pop(context, updatedTransaction);
                } else {
                  // Show an error message if input is invalid
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid Input'),
                        content: const Text('Please enter a valid Name.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Modify'),
            ),
          ],
        ),
      ),
    );
  }

  void updateTransaction(TransactionData transaction) {
    FirebaseFirestore.instance
        .collection('transactions')
        .doc(
            '${transaction.timestamp}-${transaction.total}') // need to set a function to select between transaction
        .update({
      'username': transaction.username,
      'description': transaction.description,
      'total': transaction.total,
      'timestamp': transaction.timestamp,
    });
  }
}
