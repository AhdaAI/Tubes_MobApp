import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Mahasiswa {
  late int nim;
  late String nama;
  late double nilai;
  late DateTime updatedAt;
  Mahasiswa({
    required this.nim,
    required this.nama,
    required this.nilai,
    required this.updatedAt,
  });
  factory Mahasiswa.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Mahasiswa(
      nim: int.parse(document.id),
      nama: data['Nama'],
      nilai: data['Nilai'],
      updatedAt: (data['UpdatedAt'] as Timestamp).toDate(),
    );
  }
}

class CRUD extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mahasiswa List'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Nilai_Mahasiswa')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          List<Mahasiswa> mahasiswaList =
              snapshot.data!.docs.map((DocumentSnapshot document) {
            return Mahasiswa.fromDocument(document);
          }).toList();
          return ListView.builder(
            itemCount: mahasiswaList.length,
            itemBuilder: (context, index) {
              Mahasiswa mahasiswa = mahasiswaList[index];
              return ListTile(
                title: Text('${mahasiswa.nim} - ${mahasiswa.nama}'),
                subtitle: Text('Nilai: ${mahasiswa.nilai}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MahasiswaDetailPage(mahasiswa: mahasiswa),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Confirmation'),
                          content: Text(
                              'Are you sure you want to delete this item?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteMahasiswa(mahasiswa.nim);
                                Navigator.of(context).pop();
                              },
                              child: Text('Delete'),
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
              builder: (context) => MahasiswaAddPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void deleteMahasiswa(int nim) {
    FirebaseFirestore.instance
        .collection('Nilai_Mahasiswa')
        .doc('$nim')
        .delete();
  }
}

// ...
class MahasiswaDetailPage extends StatefulWidget {
  final Mahasiswa mahasiswa;
  MahasiswaDetailPage({required this.mahasiswa});
  @override
  _MahasiswaDetailPageState createState() => _MahasiswaDetailPageState();
}

class _MahasiswaDetailPageState extends State<MahasiswaDetailPage> {
  late Mahasiswa _updatedMahasiswa;
  @override
  void initState() {
    super.initState();
    _updatedMahasiswa = widget.mahasiswa;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mahasiswa Detail'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('NIM: ${_updatedMahasiswa.nim}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Nama: ${_updatedMahasiswa.nama}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Nilai: ${_updatedMahasiswa.nilai}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Updated At: ${_updatedMahasiswa.updatedAt}'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Menggunakan Navigator untuk membuka halaman Modify
              final updatedMahasiswa = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MahasiswaModifyPage(mahasiswa: _updatedMahasiswa),
                ),
              );
              // Memperbarui tampilan jika ada perubahan
              if (updatedMahasiswa != null) {
                setState(() {
                  _updatedMahasiswa = updatedMahasiswa as Mahasiswa;
                });
              }
            },
            child: Text('Modify'),
          ),
        ],
      ),
    );
  }
}

class MahasiswaAddPage extends StatelessWidget {
  final TextEditingController nimController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nilaiController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Mahasiswa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nimController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'NIM'),
            ),
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: nilaiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Nilai'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int nim = int.tryParse(nimController.text) ?? 0;
                String nama = namaController.text.trim();
                double nilai = double.tryParse(nilaiController.text) ?? 0.0;
                if (nim > 0 && nama.isNotEmpty) {
                  Mahasiswa newMahasiswa = Mahasiswa(
                    nim: nim,
                    nama: nama,
                    nilai: nilai,
                    updatedAt: DateTime.now(),
                  );
                  addMahasiswa(newMahasiswa);
                  Navigator.pop(context);
                } else {
                  // Show an error message if input is invalid
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Invalid Input'),
                        content: Text('Please enter valid NIM and Name.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void addMahasiswa(Mahasiswa mahasiswa) {
    FirebaseFirestore.instance
        .collection('Nilai_Mahasiswa')
        .doc('${mahasiswa.nim}')
        .set({
      'Nama': mahasiswa.nama,
      'Nilai': mahasiswa.nilai,
      'UpdatedAt': mahasiswa.updatedAt,
    });
  }
}

class MahasiswaModifyPage extends StatefulWidget {
  final Mahasiswa mahasiswa;
  MahasiswaModifyPage({required this.mahasiswa});
  @override
  _MahasiswaModifyPageState createState() => _MahasiswaModifyPageState();
}

class _MahasiswaModifyPageState extends State<MahasiswaModifyPage> {
  late TextEditingController namaController;
  late TextEditingController nilaiController;
  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.mahasiswa.nama);
    nilaiController =
        TextEditingController(text: widget.mahasiswa.nilai.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Mahasiswa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NIM: ${widget.mahasiswa.nim}'),
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: nilaiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Nilai'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String nama = namaController.text.trim();
                double nilai = double.tryParse(nilaiController.text) ?? 0.0;
                if (nama.isNotEmpty) {
                  Mahasiswa updatedMahasiswa = Mahasiswa(
                    nim: widget.mahasiswa.nim,
                    nama: nama,
                    nilai: nilai,
                    updatedAt: DateTime.now(),
                  );
                  updateMahasiswa(updatedMahasiswa);
                  // Menggunakan Navigator untuk memberikan data kembali ke MahasiswaListPage
                  Navigator.pop(context, updatedMahasiswa);
                } else {
                  // Show an error message if input is invalid
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Invalid Input'),
                        content: Text('Please enter a valid Name.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Modify'),
            ),
          ],
        ),
      ),
    );
  }

  void updateMahasiswa(Mahasiswa mahasiswa) {
    FirebaseFirestore.instance
        .collection('Nilai_Mahasiswa')
        .doc('${mahasiswa.nim}')
        .update({
      'Nama': mahasiswa.nama,
      'Nilai': mahasiswa.nilai,
      'UpdatedAt': mahasiswa.updatedAt,
    });
  }
}
