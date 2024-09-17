import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'page1.dart';
import 'page2.dart';
import 'page3.dart';
import 'page4.dart';
import 'page5.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeFirebase();
    runApp(const MyApp());
  } catch (e) {
    runApp(FirebaseErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniEater',
      theme: ThemeData(useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    Page1(),
    Page2(),
    Page3(),
    Page4(),
    Page5(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniEater'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: Color.fromARGB(140, 3, 79, 154),
        selectedIndex: _selectedIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            label: '美食地圖',
          ),
          NavigationDestination(
            icon: Icon(Icons.question_mark_outlined),
            label: '選擇障礙？',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            label: '每日排程',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            label: '我的最愛',
          ),
          NavigationDestination(
            icon: Badge(
                label: Text('2'), child: Icon(Icons.notifications_outlined)),
            label: '最新動態',
          ),
        ],
      ),
    );
  }
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(Duration(seconds: 10));
  } catch (e) {
    print("Firebase initialization failed: $e");
    throw e;
  }
}

class FirebaseErrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Initialization Error'),
        ),
        body: const Center(
          child: Text('Failed to initialize Firebase. Please try again later.'),
        ),
      ),
    );
  }
}
