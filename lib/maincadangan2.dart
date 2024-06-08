import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_grup1/crud_nonapp.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tubes_grup1/authentication.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAt1EOUDtipTYumGCYe09IuAiZ_oE8D3ig",
          authDomain: "tubes-kelompok1-1049c.firebaseapp.com",
          projectId: "tubes-kelompok1-1049c",
          storageBucket: "tubes-kelompok1-1049c.appspot.com",
          messagingSenderId: "640801654569",
          appId: "1:640801654569:android:b3eec852cd2c9c0fad9938"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Jika sudah mendapatkan instance SharedPreferences
            return snapshot.data!.getBool('isLoggedIn') == true
                ? MainPage()
                : LoginPage();
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      // Login successful, navigate to main page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } catch (e) {
      print('Error during login: $e');
      setState(() {
        errorMessage = 'Invalid email or password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login Page',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 10),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );
              },
              child: Text('Forgot Password'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  AuthService().signInWithGoogle();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isLoggedIn', true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                } catch (e) {
                  print(e);
                }
              },
              child: Text('Google-Sign-In'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String errorMessage = '';
  Future<void> signUp() async {
    try {
      if (passwordController.text.length < 6) {
        setState(() {
          errorMessage = 'Password should be at least 6 characters long';
        });
        return;
      }
      if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          errorMessage = 'Passwords do not match';
        });
        return;
      }
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Sign up successful, navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error during sign up: $e');
      setState(() {
        errorMessage = 'Sign up failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign Up Page',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password (min. 6 characters)',
                ),
              ),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
              SizedBox(height: 10),
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  String errorMessage = '';
  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );
      // Password reset email sent, navigate back to login page
      Navigator.pop(context);
    } catch (e) {
      print('Error during password reset: $e');
      setState(() {
        errorMessage = 'Password reset failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Forgot Password Page',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 10),
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: resetPassword,
                child: Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        title: Text('Main Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            // titleSpacing: 0,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Upload'),
                Tab(text: 'Download'),
                Tab(text: 'CRUD')
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Content for Tab 1
              Column(
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Text('Please Upload File !'),
                  ),
                  SizedBox(height: 20),
                  IconButton(
                    icon: Icon(Icons.upload_file),
                    onPressed: () async {
                      await uploadFile();
                    },
                  ),
                ],
              ),
              // Content for Tab 2
              Column(
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Text('Download File'),
                  ),
                  SizedBox(height: 20),
                  IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () async {
                      // Example: Download a file
                      await downloadFile();
                    },
                  ),
                ],
              ),
              // Content for Tab 3
              Column(
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Text('Go to Students Data'),
                  ),
                  IconButton(
                    icon: Icon(Icons.accessibility),
                    onPressed: () {
                      // Example: Download a file
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CRUD(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
