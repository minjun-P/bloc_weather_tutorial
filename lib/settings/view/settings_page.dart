import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/weather/cubit/weather_cubit.dart';
import 'package:flutter_weather/weather/models/weather.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage._();

  // IMPORTANT
  // 특이하게 스태틱 메소드와 private constructor를 통해 이 페이지에 대한 접근이
  // 라우틀 통해서, 그리고 특정 cubit을 받아야만 가능함을 명시한다.
  // 그에 반해서 하단 build에는 cubit, blocProvider와는 무관한 뷰 수준의 코드만 언급함으로써
  // 이 클래스 내부 안에서 코드만으로 여러 의도를 나타내었다. 신선하게 충격적인 코드 구성쓰...
  static Route<void> route(WeatherCubit weatherCubit) {
    return MaterialPageRoute(
      // IMPORTANT
      // BlocProvider.value를 사용하여 기존의 Cubit을 재사용하는 부분. 아마 쓰게 되면 자주 쓰일
      // 부분이다.
      // MaterialPageRoute로 다른 스크린으로 가게 되는 경우에는 InheritedWidget을 통해
      // Providing 되는 Cubit을 받아먹을 수 없기 때문에 이래 하나 싶다.
      builder: (_) => BlocProvider.value(
        value: weatherCubit,
        child: const SettingsPage._(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("settings"),
      ),
      body: ListView(
        children: <Widget>[
          BlocBuilder<WeatherCubit, WeatherState>(
            buildWhen: (previous, current) =>
                previous.temperatureUnits != current.temperatureUnits,
            builder: (context, state) {
              return ListTile(
                title: const Text('Temperature Units'),
                isThreeLine: true,
                subtitle: const Text(
                  'Use metric measurements for temperature units.',
                ),
                trailing: Switch(
                  value: state.temperatureUnits.isCelsius,
                  onChanged: (_) => context.read<WeatherCubit>().toggleUnits(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
