import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/theme/cubit/theme_cubit.dart';
import 'package:flutter_weather/weather/view/weather_page.dart';
import 'package:weather_repository/weather_repository.dart';

import 'package:google_fonts/google_fonts.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key, required WeatherRepository weatherRepository})
      : _weatherRepository = weatherRepository;

  final WeatherRepository _weatherRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _weatherRepository,
      child: BlocProvider(
        create: (_) => ThemeCubit(),
        child: const WeatherAppView(),
      ),
    );
  }
}

class WeatherAppView extends StatelessWidget {
  const WeatherAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, Color>(
      builder: (context, color) {
        return MaterialApp(
          theme: ThemeData(
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              colorScheme: ColorScheme.fromSeed(seedColor: color),
              textTheme: GoogleFonts.rajdhaniTextTheme(),
          ),
          home: const WeatherPage(),
        );
      },
    );
  }
}
