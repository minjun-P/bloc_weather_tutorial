# bloc_whether_tutorial

[Bloc 공식 Wheater Tutorial](https://bloclibrary.dev/ko/tutorials/flutter-weather/#settingspage)을 참조하여 작업한 프로젝트입니다.
이 프로젝트는 Bloc 패턴을 사용하여 Wheater 앱을 만드는 과정을 담고 있습니다. 이 프로젝트의 목적은 사내 상태관리 도입을 위해 Bloc을 익히는데 있습니다.

## 주목할 만한 점들
- `IMPORTANT`라고 주석을 달아놓아, Bloc을 이해하는데 핵심적인 부분을 표시해두었습니다.
  - 더불어, 이 튜토리얼 자체의 코드 수준이 꽤나 높아서 좀 신선하고 좋았던 코드가 있는 부분도 해당 주석을 달아놓았습니다.
- 이 프로젝트는 특이하게도 Data Layer, Repository Layer를 굳이 별도의 패키지로 나누었습니다.
  - 실효성은 잘 모르겠으나, 이렇게 나누어 작업하는 것을 보고, 레포지토리란 근본적으로 무엇인가에 대해 생각해볼 수 있었습니다.
- 참고로 이 프로젝트는 Bloc class가 아니라 Cubit class로 작업하였습니다.
  - 그래서 처음 보는 사람이 보기엔 난이도가 낮아 괜찮을 듯.
### 1. 위젯 트리 상(InheritedWidget 방식) 에서 Repository 까지도 주입한다.
- 원래도 Provider 패키지처럼 InheritedWidget을 사용하여 상태를 전파하는 방식은 알고 있었지만, 이렇게 Repository까지도 주입하는 방식은 처음 봤다.
- 그러고 context.read 해서 주입된 것으로 예상되는 repo를 가져다 쓰는 코드가 있다. (IMPORTANT 처리 해놓음)

### 2. ViewModel(여기선 Cubit) 간 논리적 인과관계가 있는 경우에는 참조하는 대신에 View에서 판단을 통해 연속 실행을 해준다.
- View로 내려서 이렇게 처리하는 경우는 꽤나 일반적인 것 같았다.
  - 다만 좀 좋지 않다고 느꼈던 것은, View 곳곳에 ViewModel 간 인과관계를 나타내는 코드가 명령형으로 산재하게 된다는 점이다.
    - 이 부분은 좀 더 고민해봐야 할 것 같다. (특히, 이런 코드가 많아지면 어떻게 될지)

> 참조할 만한 아티클이 Bloc 공식문서에 있다. Cubit이 아니라 Bloc에 대한 내용이지만 참조할 것.\
> [Bloc간 통신](https://bloclibrary.dev/ko/architecture/#bloc%EA%B0%84-%ED%86%B5%EC%8B%A0)