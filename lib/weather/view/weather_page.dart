import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/search/view/search_page.dart';
import 'package:flutter_weather/theme/cubit/theme_cubit.dart';
import 'package:flutter_weather/weather/cubit/weather_cubit.dart';
import 'package:flutter_weather/settings/view/settings_page.dart';
import 'package:flutter_weather/weather/widgets/weather_empty.dart';
import 'package:flutter_weather/weather/widgets/weather_error.dart';
import 'package:flutter_weather/weather/widgets/weather_loading.dart';
import 'package:flutter_weather/weather/widgets/weather_populated.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // IMPORTANT: 주입된 Repository를 사용하는 코드 ( + Cubit을 주입하는 코드 )
      // InheritedWidget 방식 베이스로 여러 종속성이 주입되고 사용된다.
      create: (context) => WeatherCubit(context.read<WeatherRepository>()),
      child: const WeatherView(),
    );
  }
}

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  SettingsPage.route(
                    context.read<WeatherCubit>(),
                  ),
                );
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: Center(
        // [BlocConsumer]는 [BlocBuilder]와 [BlocListener]의 결합체이다.
        // 그냥 제일 강력한 놈. 위 2개는 경량화하여 분리한 놈들
        child: BlocConsumer<WeatherCubit, WeatherState>(
          listener: (context, state) {
            // IMPORTANT : ViewModel의 변화에 따라 다른 ViewModel을 업데이트하는 방법
            // 하나의 ViewModel의 변화가 다른 변화를 촉발하는 경우 이 연계 과정을
            // View에서 처리하는 모범사례 중 하나이다.
            if (state.status.isSuccess) {
              context.read<ThemeCubit>().updateTheme(state.weather);
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case WeatherStatus.initial:
                return const WeatherEmpty();
              case WeatherStatus.loading:
                return const WeatherLoading();
              case WeatherStatus.success:
                return WeatherPopulated(
                  weather: state.weather,
                  units: state.temperatureUnits,
                  onRefresh: () {
                    return context.read<WeatherCubit>().refreshWeather();
                  },
                );
              case WeatherStatus.failure:
                return const WeatherError();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search, semanticLabel: 'Search'),
        onPressed: () async {
          final city = await Navigator.of(context).push(SearchPage.route());
          // 현재 해당 context가 아직도 위젯트리에 존재하는지에 대해 검사
          if (!context.mounted) return;
          await context.read<WeatherCubit>().fetchWeather(city);
        },
      ),
    );
  }
}
