import 'dart:async';

import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen
    extends StatefulWidget {

  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen>
  createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {

    super.initState();

    Timer(

      const Duration(seconds: 3),

          () {

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (context) =>

            const LoginScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFFFF5F7),

      body: Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Container(

              padding:
              const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                BorderRadius.circular(30),

                boxShadow: [

                  BoxShadow(

                    color:
                    Colors.black.withOpacity(0.08),

                    blurRadius: 15,

                    offset:
                    const Offset(0, 5),
                  ),
                ],
              ),

              child: Image.asset(

                'assets/images/logo_koko.jpg',

                height: 140,
              ),
            ),

            const SizedBox(height: 30),

            const Text(

              'Koko Studio',

              style: TextStyle(

                fontSize: 34,

                fontWeight:
                FontWeight.bold,

                color:
                Color(0xFFD9A5B3),
              ),
            ),

            const SizedBox(height: 10),

            const Text(

              'Belleza • Elegancia • Estilo',

              style: TextStyle(

                fontSize: 18,

                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(

              color:
              Color(0xFFD9A5B3),
            ),
          ],
        ),
      ),
    );
  }
}