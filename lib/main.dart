import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:manitto_select/choose_manitto.dart';
import 'package:manitto_select/gradient_text.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '마니또 뽑기',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 38, 189),
        ),
      ),
      home: const MyHomePage(title: '마니또 뽑기'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 2, 23, 144),
              const Color.fromARGB(255, 39, 119, 225),
              const Color.fromARGB(255, 2, 23, 144),
            ],
          ),
        ),
        child: Center(
          child: Container(
            height: 600,
            width: 1000,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: <Widget>[
                Column(
                  children: [
                    GradientText(
                      text: "PRMITIVE",
                      gradient: RadialGradient(
                        colors: [
                          const Color.fromARGB(255, 2, 23, 144),
                          const Color.fromARGB(255, 28, 107, 210),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    GradientText(
                      text: "마니또 뽑기",
                      gradient: RadialGradient(
                        colors: [
                          const Color.fromARGB(255, 5, 19, 98),
                          const Color.fromARGB(255, 17, 35, 134),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 100),

                ElevatedButton(
                  onPressed: () {
                    if (!_isLoading) {
                      var md = ManittoDispenser();
                      debugPrint("pressed");

                      setState(() {
                        _isLoading = true;
                      });

                      md.setManitto().then((result) {
                        setState(() {
                          _isLoading = false;
                        });
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white,
                    shadowColor: Colors.black,
                    elevation: 2.0,
                    fixedSize: Size(200, 60),
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20.0,
                    ),
                    side: BorderSide(
                      color: Color.fromARGB(255, 2, 23, 144),
                      width: 1,
                    ),
                  ),
                  child:
                      _isLoading
                          ? CircularProgressIndicator()
                          : Text('뽑기', style: TextStyle(color: Colors.black)),
                ),

                SizedBox(height: 30),

                /*
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        isSelected = false;
                      },
                      child: Text('초기화', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 2.0,
                        fixedSize: Size(100, 30),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15.0,
                        ),
                        side: BorderSide(
                          color: Color.fromARGB(255, 145, 10, 10),
                          width: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
