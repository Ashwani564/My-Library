import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'blocs/reading_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'services/book_service.dart';
import 'services/reading_time_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BookService>(
          create: (context) => BookService(),
        ),
        RepositoryProvider<ReadingTimeService>(
          create: (context) => ReadingTimeService(prefs),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ReadingBloc>(
            create: (context) => ReadingBloc(
              bookService: context.read<BookService>(),
              readingTimeService: context.read<ReadingTimeService>(),
            ),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(prefs),
          ),
        ],
        child: MaterialApp(
          title: 'EPUB Reader',
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(
                fontFamily: 'Bookerly',
                color: Colors.white,
              ),
              bodyMedium: TextStyle(
                fontFamily: 'Bookerly',
                color: Colors.white,
              ),
            ),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
