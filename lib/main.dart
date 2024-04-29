import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stickershub/navbar.dart';
import 'package:stickershub/screens/auth_page.dart';
import 'package:stickershub/screens/clicky_page.dart';
import 'package:stickershub/screens/collection_page.dart';
import 'package:stickershub/screens/login_page.dart';
import 'package:stickershub/screens/notfound_page.dart';
import 'package:stickershub/screens/profile_page.dart';
import 'package:stickershub/screens/register_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  MaterialColor blackSwatch = MaterialColor(
    Colors.black.value,
    const <int, Color>{
      50: Color(0xFF0D0D0D),
      100: Color(0xFF1A1A1A),
      200: Color(0xFF262626),
      300: Color(0xFF333333),
      400: Color(0xFF404040),
      500: Color(0xFF4D4D4D),
      600: Color(0xFF595959),
      700: Color(0xFF666666),
      800: Color(0xFF737373),
      900: Color(0xFF808080),
    },
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSwatch(
      primarySwatch: blackSwatch,
      brightness: Brightness.light,
      cardColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 255, 246, 235),
      errorColor: Colors.red,
    );
    return MaterialApp(
      title: 'StickersHub',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,

        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.background,
          shadowColor: Colors.grey.withOpacity(0.5),
          elevation: 0.0,
          centerTitle: true,
          scrolledUnderElevation: 2.0,
          toolbarHeight: 72.0,
          titleTextStyle: const TextStyle(
            color: Colors.black, 
            fontSize: 40.0, 
            fontWeight: FontWeight.normal,
            fontFamily: 'Goldplay',
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
          actionsIconTheme: const IconThemeData(
            color: Colors.black, 
            size: 33.0,
          ),
        ),

        dividerTheme: const DividerThemeData(
          color: Colors.grey,
          thickness: 1,
          space: 50,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return const Color.fromARGB(255, 200, 200, 200);
                }
                return const Color.fromARGB(255, 238, 187, 48);
              },
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey;
                }
                return Colors.white;
              },
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(const TextStyle(
              fontSize: 20,
              fontFamily: 'GoldPlay',
            )),
            shadowColor: MaterialStateProperty.all<Color>(Colors.black),
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.grey.withOpacity(0.5);
                }
                return null;
              },
            ),
          ),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black)
          )
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: colorScheme.background,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          iconTheme: MaterialStateProperty.all(
            const IconThemeData(
              color: Colors.black,
              size: 24.0,
            ),
          ),
          indicatorColor: Colors.transparent,
          overlayColor: const MaterialStatePropertyAll(Colors.transparent),
          labelTextStyle: MaterialStateProperty.all(const TextStyle(
            color: Colors.black,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Goldplay'
          )),
        ),

      ),

      onGenerateRoute: (RouteSettings settings) {

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const ClickyPage());
          case '/clicker':
            return MaterialPageRoute(builder: (_) => const ClickyPage());
          case '/collection':
            return MaterialPageRoute(builder: (_) => const CollectionPage());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfilePage());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());
          case '/trading':
            return MaterialPageRoute(builder: (_) => const NavBar(position: 0));
          case '/auth':
            return MaterialPageRoute(builder: (_) => const AuthCheckPage());
          default:
            return MaterialPageRoute(builder: (_) => const NotFoundPage());
        }
      },
      home: const AuthCheckPage(),
    );
  }
}