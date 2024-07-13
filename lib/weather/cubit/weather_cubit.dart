import 'package:equatable/equatable.dart';
import 'package:flutter_weather/weather/models/models.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

part 'weather_cubit.g.dart';
part 'weather_state.dart';

/// [HydratedCubit] 이란, 앱이 종료되어도 상태를 유지할 수 있게 해주는 Cubit의 확장판

/// 이 프로젝트에서 제일 핵심이 되는 ViewModel
class WeatherCubit extends HydratedCubit<WeatherState> {
  // 처음 블록을 Init할 때는 Repository만 주입 받는다.
  // WeatherState는 그냥 알아서 강한 종속성으로 초기 값 Init
  WeatherCubit(this._weatherRepository) : super(WeatherState());

  final WeatherRepository _weatherRepository;

  /// 도시를 받아서 날씨를 가져오는 함수 - 제일 기초가 되는 Method
  Future<void> fetchWeather(String? city) async {
    if (city == null || city.isEmpty) return;

    // 우선 갖고 있는 State를 로딩 상태로 변경
    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      final weather = Weather.fromRepository(
        // 주입 받은 Repository를 사용하여 데이터를 가져옴.
        // 여기선 레포지토리가 리턴하는 모델 또한 변환하여 사용하게 된다.
        // 이 부분은 좀 별로인 것 같긴 하네. 하위 모듈 단위로 쪼개면서 굳이 없어도 되는 모델 분리와
        // 변환 과정이 생긴 것 같다.
        await _weatherRepository.getWeather(city),
      );
      final units = state.temperatureUnits;
      final value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      // fetch 결과를 바탕으로 상태를 변경
      emit(
        state.copyWith(
          status: WeatherStatus.success,
          temperatureUnits: units,
          weather: weather.copyWith(temperature: Temperature(value: value)),
        ),
      );
      // 이런 문법이 있었구나...
    } on Exception {
      // 에러가 발생하면 상태를 실패로 변경 처리
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  /// 날씨를 새로 불러오는 함수
  /// 현재의 State를 고려하여 실행 여부와 실행 스타일이 결정될 것임.
  Future<void> refreshWeather() async {
    // 잘못된 케이스에 대한 판단을 ViewModel 내부의 state 값을 바탕으로 자체적으로 하네
    // 이러한 판단을 외부에 노출하지 않나? 아니면 외부에서도 판단하고 뷰모델 설계할 때도 자체적으로
    // 아래 들어와 있나 싶구만
    if (!state.status.isSuccess) return;
    if (state.weather == Weather.empty) return;
    try {
      final weather = Weather.fromRepository(
        await _weatherRepository.getWeather(state.weather.location),
      );
      final units = state.temperatureUnits;
      final value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(
        state.copyWith(
          status: WeatherStatus.success,
          temperatureUnits: units,
          weather: weather.copyWith(temperature: Temperature(value: value)),
        ),
      );
    } on Exception {
      emit(state);
    }
  }

  /// Repository를 통한 Fetch 없이, 자체적으로 ViewModel을 관리하는 메소드이다.
  /// ViewModel을 넓게 정의하고 여러 부분을 조금씩 수정하는 메소드가 여럿 존재할 수 있음을 보여주는 예
  void toggleUnits() {
    // 현재 State를 알아서 가져온다. 외부 판단이 필요 없음.
    // 당연한게 어차피 View는 이 ViewModel의 State에 종속되어 있을 것이고 그러므로
    // 유저에게서는 값이 아니라 액션만 받아와도 괜찮은 것임.
    final units = state.temperatureUnits.isFahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;

    // IsSuccess 상태가 아니라면 어차피 데이터가 없을테니 그냥 유닛만 바꾸고
    // 굳이 이미 있는 데이터를 확인하고 바꿀 필요가 없겠지
    if (!state.status.isSuccess) {
      emit(state.copyWith(temperatureUnits: units));
      return;
    }

    final weather = state.weather;
    // 아래 코드는 Equatable 을 사용했기 때문에 가능한 것임
    if (weather != Weather.empty) {
      final temperature = weather.temperature;
      // 현재 Units 에 따라 값을 다르게 표시해주기 위해 이렇게 바꿔주고
      // (근데 이걸 ViewModel에서 했어야 하나 싶네. 판단은 units필드만 보고 View에서 만들어줬어도 될 것 같다)
      final value = units.isCelsius
          ? temperature.value.toCelsius()
          : temperature.value.toFahrenheit();
      // 스테이트를 바꿔준다.
      emit(
        state.copyWith(
          temperatureUnits: units,
          weather: weather.copyWith(temperature: Temperature(value: value)),
        ),
      );
    }
  }

  @override
  WeatherState fromJson(Map<String, dynamic> json) =>
      WeatherState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeatherState state) => state.toJson();
}

// 이 튜토리얼 만든 양반 extension 진짜 좋아하네. 확실히 Extension이 편하긴 한 듯.
extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;
  double toCelsius() => (this - 32) * 5 / 9;
}