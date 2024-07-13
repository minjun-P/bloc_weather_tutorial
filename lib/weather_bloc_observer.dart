import 'package:bloc/bloc.dart';

class WeatherBlocObserver extends BlocObserver {
  const WeatherBlocObserver();

  @override
  void onChange(BlocBase bloc, Change change) {
    // TODO: implement onChange
    super.onChange(bloc, change);
    print("${bloc.runtimeType} ${change}");
  }
}