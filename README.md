・ 프로젝트 소개
  - 이 프로젝트는 Flutter를 사용하여 Google Maps를 연동한 위치 기반 서비스 앱 제작입니다.
  - 사용자는 자신이 정한 위치를 기준으로 주변 약국과 병원을 검색가능하고 일반의약품에 관련한 정보를 얻을 수 있습니다.
  - 앱은 실시간 데이터베이스(Firebase)를 활용하여 약의 정보와 약국과 병원의 위치 및 정보를 관리하며, 사용자에게 직관적이고 효율적인 UI를 제공합니다
    
・ 프로그램 설치 URL (데모 앱 다운로드 링크)
  - https://drive.google.com/file/d/13zWkf9hYahWQG4uSKm02zQDRxcmCjpst/view?usp=drive_link

・ App Description : 어플리케이션 사용방법 설명
  - 앱을 실행하여 병원과 약국의 위치와 정보를 조회 할 수 있고, 자신의 신체 정보를 가지고 BMI 측정 또한 할 수 있습니다.
  - 편의점 등 일반의약품들을 먹을 때 제대로 된 복용법과 약 정보를 알 수 있습니다.

・ 기능 소개 및 기능별 사용 방법 설명
  - 메인 화면에 있는 병원 약국 지도 펼치기 버튼을 누르면 병원과 약국의 위치가 표시된 마커가 지도에 있습니다.
  - 각 마커를 누르면 그 위치에 있는 병원과 약국의 정보를 조회 할 수 있습니다.
  - 그리고 BMI 측정 버튼을 눌러 설정 페이지에서 설정한 사용자 정보를 토대로 BMI를 측정 할 수 있는 페이지로 이동 할 수 있습니다.
  - 또한 메인 화면 아래 부분에는 심야약국의 대한 정보 또한 얻을 수 있습니다.
  - 약 정보 조회 페이지에서는 각 약품들에 대한 정보들이 리스트로 나열되어있고 검색바를 통해 검색을 할 수 있습니다. 그리고 복용 방법 보기 버튼을 누르면 복용 방법을 얻을 수 있는 페이지로 이동되게 됩니다.
  - 설정 페이지에서는 사용자 정보를 수정 할 수있고 병원,약국 지도에서 반경 몇 km 안에 있는 병원, 약국을 조회 할 것인지 수정 가능합니다.
    
・ 데모영상 : 3분 이하의 기술 시연 및 설명 영상 링크 (유튜브, 페이스북 등)
  - https://youtu.be/7-KGLpcTB2k?si=Wenf5X33O3wXo5B5
  
・ 팀 소개 : 팀원 및 역할 소개(산출물 코드 작성 기여도 명시)
  - 전우혁 : 팀장, 개발자 
  - 안기현 : 개발자

・ 제안서 상의 기능별 개발 여부 및 개발 담당자
  - 파이어베이스 데이터의 한계 상 응급실 실시간 현황을 보여주는 기능 구현 X, 사용자의 BMI를 수치를 기반으로 올바론 약물 복용 방법 및 정량 제공 구현 X
  - 위치 기반 의료 정보 제공 플랫폼 구축 -> 사용자의 실시간 위치를 불러오는 것은 구현 X, 대신 사용자가 원하는 위치를 중심으로 반경 0.5KM ~ 3.0KM 안에 있는 의료 정보 제공 (안기현)
  - 심야 약국에 대한 정보 제공 (안기현)
  - 각종 의약품에 대한 정보와 복용법 제공 (전우혁)
  - 사용자 정보를 가지고 건강 체크하는 기능 제공 (전우혁)
  - 각 데이터는 firebase와 연동하여 데이터를 가져와 화면에 표시 (안기현)

・ 개발 환경 및 사용한 라이브러리
  - 개발 환경 : Flutter, Android Studio, Firebase Realtime Database, Dart 언어
  - 사용한 라이브러리 : google_maps_flutter, firebase_core 및 firebase_database
