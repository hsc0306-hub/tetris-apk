# LINK TETRIS

브라우저에서 실행되는 테트리스 게임입니다. 싱글 플레이, 멈춤/계속하기, 1:1 온라인 대전(PeerJS), Supabase 회원 로그인 및 일간·주간·월간 랭킹을 포함합니다.

## 파일 구성

- `index.html` : 게임 본체 (GitHub Pages 배포 진입 파일)
- `supabase_schema.sql` : Supabase 프로필/점수 테이블 및 RLS 정책
- `assets/icon-512.png` : 앱/웹 아이콘
- `assets/favicon.png` : 브라우저 아이콘
- `android-icons/` : Android mipmap 아이콘 리소스

## GitHub에 올리기

1. GitHub에서 새 Repository를 만듭니다.
2. 이 폴더의 모든 파일과 폴더를 저장소 루트에 업로드합니다.
3. `Settings → Pages → Build and deployment`에서 `Deploy from a branch`를 선택합니다.
4. Branch를 `main`, 폴더를 `/ (root)`로 지정하고 저장합니다.
5. 발급된 HTTPS 주소로 접속해 게임을 확인합니다.

## Supabase

현재 `index.html`에는 업로드하신 Supabase Project URL과 publishable/anon 공개 키가 이미 반영되어 있습니다. 이 키는 브라우저에 노출되는 공개 키이므로, `service_role` 또는 secret 키를 넣지 마세요. Supabase SQL Editor에서 `supabase_schema.sql`을 실행하고 Authentication의 Email/Kakao Provider 및 URL Configuration을 설정해야 로그인/랭킹이 동작합니다.

- Site URL: GitHub Pages의 실제 HTTPS 주소
- Redirect URLs: GitHub Pages 주소와 OAuth callback 이후 실제 복귀 주소
- Kakao Redirect URI: Supabase Dashboard에 표시되는 `https://<project-ref>.supabase.co/auth/v1/callback`

## 기능

- 싱글 플레이: `혼자 플레이 시작`
- 일시정지: `⏸ 멈춤` / `▶ 계속하기`
- 게임 오버 후 `다시 하기`
- 1:1 대전: 방 생성, 초대 링크/방 코드 참가 (PeerJS)
- 이메일/카카오 로그인, 닉네임 설정
- 일간/주간/월간 사용자별 최고 점수 랭킹

## 주의

- OAuth 로그인은 HTTPS 배포 주소와 Supabase/Kakao Redirect URL 설정이 정확해야 합니다.
- 카카오 Client Secret 및 Supabase `service_role` 키는 저장소에 절대 올리지 마세요.
- 현재 점수는 클라이언트에서 제출되므로 개발자 도구를 이용한 조작을 완전히 방지하지 못합니다. 공정한 대회 운영에는 서버 측 검증이 필요합니다.
- APK는 이 저장소 업로드만으로 자동 생성되지 않습니다. Android Studio/Capacitor 프로젝트 구성과 Android 앱의 OAuth 딥링크 설정 및 별도 빌드가 필요합니다.
