import 'dart:io';
import 'package:firebaseflutter/dashboard.dart';
import 'package:firebaseflutter/notifications_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:another_flushbar/flushbar.dart';



void main() async {
   WidgetsFlutterBinding.ensureInitialized();

   //for web
  if(kIsWeb){
    await Firebase.initializeApp(
      options: const FirebaseOptions(
         apiKey: "AIzaSyDtHvpkrqijGy5m5vRHeYZtNwfkveRsgxo",
         appId: "1:892165958267:web:4933db1de1a56d05e610de",
         messagingSenderId: "892165958267",
         projectId: "esp32-flutter-48c5b",
         storageBucket: "esp32-flutter-48c5b.appspot.com",
         databaseURL: "https://esp32-flutter-48c5b-default-rtdb.asia-southeast1.firebasedatabase.app",
        
        
         ));
   }else if(Platform.isAndroid){
    await Firebase.initializeApp(
      options: const FirebaseOptions(
         apiKey: "AIzaSyDtHvpkrqijGy5m5vRHeYZtNwfkveRsgxo",
         appId: "1:892165958267:android:4933db1de1a56d05e610de",
         messagingSenderId: "892165958267",
         projectId: "esp32-flutter-48c5b",
         storageBucket: "esp32-flutter-48c5b.appspot.com",
         databaseURL: "https://esp32-flutter-48c5b-default-rtdb.asia-southeast1.firebasedatabase.app",

         ));
   }else {
    await Firebase.initializeApp();
  }
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
       home: const LoginScreen(title: 'Inicio de Sesion'),
  
      routes: {
        '/home':(context) => const LoginScreen(title: 'Flutter Demo Home Page'),
              },
    );
  }

}

class LoginScreen extends StatefulWidget {
  final String title;
  const LoginScreen({super.key,required this.title});  

  @override 
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn =  GoogleSignIn(
    scopes: <String>['email'],  
    serverClientId: "892165958267-6hkhlfcnvstdjdcshrmp8gphctsb5npg.apps.googleusercontent.com",
    clientId: "892165958267-nfu7pjudc526m3tf094ucbfh3irdfpml.apps.googleusercontent.com"
    

  );
  GoogleSignInAccount? _currentUser;
  User? firebaseuser;
  
 
  @override
  void initState() {
   
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account)async {
      setState(() {
         _currentUser = account;         
     });
    if(_currentUser != null){
        Flushbar(
          title: 'Inicio de sesion correcto',
          message: '${_currentUser?.email} has iniciado sesion',
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          flushbarStyle: FlushbarStyle.FLOATING,
          duration: const Duration(seconds: 4),
        ).show(context);
      _handleFirebase();
      }
  
      } );
      _googleSignIn.signInSilently();
  }
 void _handleFirebase() async{
    GoogleSignInAuthentication? googleAuth = await _currentUser?.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth?.idToken , accessToken: googleAuth?.accessToken
    );
    final UserCredential credUser = await firebaseAuth.signInWithCredential(credential);
    if(credUser.user != null){
        firebaseuser = credUser.user!;
        setState(() {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>const Dashboard()));
        });
         
    }
    
  }
Future<void> _handleSignIn() async {
    try {
      
      await _googleSignIn.signIn();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:Container(
          height: (MediaQuery.of(context).orientation == Orientation.portrait)? MediaQuery.of(context).size.height*0.15 : MediaQuery.of(context).size.height*0.1, // maximum item width
          width:  (MediaQuery.of(context).orientation == Orientation.portrait)? MediaQuery.of(context).size.width*0.2: MediaQuery.of(context).size.height*0.1, // maximum item width
           decoration:const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/UTNLOGO.png'),fit: BoxFit.contain),shape: BoxShape.rectangle),),
           title: const Text('Google Sign in'),),
      body: Center(
         child:Column(
          mainAxisAlignment: (MediaQuery.of(context).orientation == Orientation.portrait)?MainAxisAlignment.center:MainAxisAlignment.start,
            children:[ 
             Container(
          height: (MediaQuery.of(context).orientation == Orientation.portrait)? MediaQuery.of(context).size.height*0.35 : MediaQuery.of(context).size.height*0.6, // maximum item width
          width:  (MediaQuery.of(context).orientation == Orientation.portrait)? MediaQuery.of(context).size.width*0.94: MediaQuery.of(context).size.width*0.45, // maximum item width
          decoration:const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/PortadaApp.png'),fit: BoxFit.fill),shape: BoxShape.rectangle),
        ),
          SizedBox(
            height: 50,
            width: 150,
            child: FloatingActionButton(
              onPressed:_handleSignIn,
              backgroundColor: Colors.white60,
              elevation: 10,
              child: const Text('Iniciar Sesion'),
            ),
            ),
         ])
        ),
        bottomSheet: const Text('Meza Lautaro & Ré Boris',style: TextStyle(fontSize: 20,fontStyle: FontStyle.italic,fontFamily: 'Times New Roman'),),
      );
  }
}





