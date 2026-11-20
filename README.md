# devenv_hj

임베디드 개발(C/C++, Rust, Python, Bash, TF-A / U-Boot / Linux, aarch64 크로스 컴파일)용
**Neovim + tmux** 개발 환경입니다. 새 PC에서 `git clone` 후 `./install.sh` 한 번이면 같은 환경이 됩니다.

- 지원 OS: **Linux** (Ubuntu/Debian, Fedora), **macOS**
- Neovim 0.11 이상 필요 (스크립트가 없으면 설치)
- 플러그인 버전은 `nvim/lazy-lock.json`에 고정되어 있어 어느 PC에서나 같은 버전이 설치됩니다

---

## 1. 설치

```bash
git clone https://github.com/hyeonjun-2/devenv_hj.git ~/.devenv_hj
cd ~/.devenv_hj
./install.sh
```

여러 번 실행해도 안전합니다. 이미 된 단계는 건너뛰고, 기존 설정 파일은 `*.bak-날짜시간`으로 백업한 뒤 바꿉니다.

### install.sh가 하는 일

| 단계 | Linux | macOS |
|---|---|---|
| 1. 시스템 패키지 | `apt-get` 또는 `dnf` (sudo 비밀번호 필요): git, curl, unzip, tmux, ripgrep, fd, fontconfig, wl-clipboard, xclip, nodejs, npm | Homebrew: git, curl, tmux, ripgrep, fd, node, neovim |
| 2. Neovim | PATH의 nvim이 0.11 미만이면 공식 릴리스를 `~/.local/opt`에 설치하고 `~/.local/bin/nvim`으로 링크 (sudo 불필요) | Homebrew |
| 3. 아이콘 폰트 | Symbols Nerd Font를 `~/.local/share/fonts`에 설치 + fontconfig 설정 | `font-symbols-only-nerd-font` (Homebrew cask) |
| 4. 설정 연결 | `~/.config/nvim` → `이 저장소/nvim`, `~/.tmux.conf` → `이 저장소/tmux/tmux.conf` (심볼릭 링크) | 같음 |
| 5. tmux 플러그인 | tpm 설치 후 플러그인 설치 | 같음 |
| 6. Neovim 플러그인 | `lazy-lock.json` 버전으로 설치 (`:Lazy restore`) | 같음 |
| 7. 언어 서버 | mason으로 `clangd`, `bash-language-server`, `rust-analyzer` 설치 | 같음 |

### 옵션

```bash
./install.sh --no-packages   # apt/dnf/brew 건너뛰기 (sudo 없이 설치할 때)
./install.sh --no-nvim       # Neovim 설치 건너뛰기 (이미 있는 것 사용)
./install.sh --no-font       # 폰트 건너뛰기
./install.sh --no-plugins    # 플러그인 / 언어 서버 다운로드 건너뛰기
NVIM_RELEASE=v0.12.0 ./install.sh   # Linux에서 특정 Neovim 버전 설치
```

macOS는 [Homebrew](https://brew.sh)를 먼저 설치해야 합니다.

### 설치 후

- **터미널 앱을 완전히 껐다 켜세요.** (새 폰트를 읽어야 아이콘이 보입니다. GNOME Terminal은 창을 전부 닫아야 함)
- `~/.local/bin`이 PATH에 없다는 경고가 나오면 `~/.bashrc`에 추가: `export PATH="$HOME/.local/bin:$PATH"`
- 이미 실행 중인 tmux가 있다면 `prefix + r`로 설정 다시 읽기

---

## 2. 설정을 바꾸고 다른 PC와 맞추기

`~/.config/nvim`과 `~/.tmux.conf`는 **이 저장소를 가리키는 링크**입니다. 어디서 고치든 이 저장소 파일이 바뀝니다.

```bash
# 이 PC에서 고친 뒤
cd ~/.devenv_hj && git add -A && git commit -m "..." && git push

# 다른 PC에서
cd ~/.devenv_hj && git pull && ./install.sh --no-packages
```

- 플러그인을 업데이트하면(`:Lazy update`) `nvim/lazy-lock.json`이 바뀝니다. 커밋하면 다른 PC도 같은 버전을 받습니다.
- 언어 서버를 추가하려면: `:Mason`에서 설치 → `nvim/lua/plugins/lsp.lua`의 `vim.lsp.enable({...})`에 이름 추가 → 다른 PC에서도 자동 설치되게 `install.sh`의 `MASON_TOOLS`에도 추가

---

## 3. 구성

```
devenv_hj/
├── install.sh                 # 설치 스크립트
├── scripts/mason-install.lua  # install.sh가 쓰는 언어 서버 설치 도우미
├── tmux/tmux.conf
└── nvim/                      # ~/.config/nvim
    ├── init.lua               # options → autocmds → lazy.nvim 순서로 불러옴
    ├── lazy-lock.json         # 플러그인 버전 고정
    └── lua/
        ├── config/
        │   ├── options.lua    # leader(Space), 검색, 줄 번호, 탭 표시, 창 나누는 방향 등
        │   ├── autocmds.lua   # 탭 4칸 표시, 마지막 커서 위치, 외부 변경 자동 반영(파일 감시), 창 크기 자동 조절
        │   └── lazy.lua       # lazy.nvim(플러그인 관리) 설정
        └── plugins/           # 플러그인 하나당 파일 하나
```

LazyVim 같은 배포판은 쓰지 않고, LazyVim의 설정 방식만 참고해서 **필요한 플러그인만 `lua/plugins/`에 하나씩** 넣었습니다.
플러그인을 끄려면 그 파일에 `enabled = false,`를 넣고, 지우려면 파일을 삭제한 뒤 `:Lazy`에서 `X`(clean)를 누르면 됩니다.

### 플러그인

| 플러그인 | 용도 |
|---|---|
| lazy.nvim | 플러그인 관리 |
| vscode.nvim | 테마 (VSCode Dark+, 배경 투명 → 터미널 배경 유지) |
| lualine.nvim / bufferline.nvim / mini.icons | 아래 상태줄 / 위쪽 버퍼 탭 / 파일 아이콘 |
| snacks.nvim | 파일·내용 검색(picker), 파일 트리(explorer), 들여쓰기 안내선, 부드러운 스크롤, 창 확대(zoom), 큰 파일 열 때 무거운 기능 끄기(bigfile) |
| which-key.nvim | 키를 누르다 멈추면 다음 키 목록 표시 |
| gitsigns.nvim | 줄 옆 git 변경 표시, 변경 단위 되돌리기·blame |
| aerial.nvim | 현재 파일의 함수·구조체 목록(outline)을 옆 창에 표시 |
| diffview.nvim | 바뀐 파일 전체를 한 화면에서 리뷰 (파일 목록 + 파일별 좌우 diff), 파일 변경 기록 |
| mason.nvim / nvim-lspconfig | 언어 서버 설치 / 언어 서버 기본 설정 |
| blink.cmp | 자동완성 |
| mini.pairs | 괄호·따옴표 자동 닫기 |

### 주요 설정

- leader 키: `Space` (아래 표의 `Space ff`는 Space를 누른 뒤 f, f)
- 줄 번호 + 상대 줄 번호, 표시 칸(sign column) 항상 표시, 상태줄 하나만(`laststatus = 3`)
- 탭은 `»`, 줄 끝 공백은 `·`로 표시. **탭은 4칸 너비로 표시** (파일에는 탭 문자 그대로 저장. TF-A처럼 8칸 기준으로 정렬된 코드는 정렬이 조금 어긋나 보일 수 있음)
- 새 창은 오른쪽 / 아래에 열림
- 검색: 소문자로만 쓰면 대소문자 무시, 대문자가 섞이면 구분 (`ignorecase` + `smartcase`)
- 파일을 다시 열면 마지막 커서 위치에서 시작 (`/tmp` 아래 파일은 nvim 기본 설정상 기록 안 됨)
- nvim 밖에서 바뀐 파일(git checkout 등)은 nvim으로 돌아올 때 자동으로 다시 읽음 (수정 중인 파일은 제외)
- 터미널 크기가 바뀌면 나눠진 창 크기를 자동으로 고르게 맞춤
- 진단(diagnostics)은 **에러만** 표시 (경고·힌트는 받지 않음. 다시 보려면 `lsp.lua`의 `Drop warnings...` 블록 삭제)

---

## 4. 키 정리

### Neovim

| 분류 | 키 | 동작 |
|---|---|---|
| 찾기 | `Space ff` | 파일 이름으로 찾기 |
| | `Space fg` | 프로젝트 전체 내용 검색 |
| | `Space fw` | 커서 아래 단어로 검색 (`grep -w`) |
| | `Space fb` | 열린 버퍼 목록 |
| | (검색 창 안) `Enter` / `Ctrl-v` / `Ctrl-s` / `Ctrl-t` | 현재 창 / 오른쪽 창 / 아래 창 / 새 탭에 열기 |
| 파일 트리 | `Space e` | 왼쪽 파일 트리 열기/닫기 (트리 안에서 `?`로 키 목록) |
| 코드 이동 | `Ctrl-]` | 정의로 이동 (대상 파일이 이미 다른 창에 있으면 그 창으로) |
| | `Space gd` | 정의를 옆 창에 열기 |
| | `gD` | 헤더의 선언으로 이동 |
| | `Space ch` | `.c` ↔ `.h` 전환 (clangd) |
| | `Space cs` | 현재 파일의 함수 목록 열기/닫기 (aerial. 목록에서 `Enter`로 이동, `q`로 닫기) |
| | `Ctrl-o` / `Ctrl-i` | 뒤로 / 앞으로 |
| | `K` | 함수 원형·설명 보기 |
| | `grr` / `grn` / `gra` | 참조 찾기 / 이름 바꾸기 / 코드 수정 제안 |
| 에러 | `]d` / `[d` | 다음 / 이전 에러 |
| | `Ctrl-w d` | 커서 줄의 에러 메시지 크게 보기 |
| | `Space sd` | 에러 목록 |
| git | `]h` / `[h` | 다음 / 이전 변경 |
| | `Space ghp` / `Space ghr` / `Space ghs` | 변경 미리보기 / 되돌리기 / stage |
| | `Space ghb` / `Space ghd` | blame / 커밋 버전과 좌우 비교 |
| | `Space ghi` | 코드 안에서 diff처럼 보기 켜기/끄기 (바뀐 줄 색칠, 지운 줄 표시, 바뀐 글자 강조) |
| | `Space gv` | 바뀐 파일 전체 리뷰 열기/닫기 (diffview. `Tab`/`Shift-Tab` 다음/이전 파일, `X` 되돌리기, `g?` 도움말) |
| | `Space gf` | 현재 파일의 커밋 기록 (diffview) |
| 창 | `Ctrl-w v` / `Ctrl-w s` | 오른쪽 / 아래로 나누기 |
| | `Ctrl-w h/j/k/l` | 창 이동 |
| | `Space wm` | 현재 창 확대 / 원래대로 |
| Markdown | `Space mp` | 지금 md 파일을 저장하고 Chrome **새 창**에서 열기 (Chrome이 없으면 기본 앱). Markdown Viewer의 Auto reload를 켜면 `:w`마다 새로고침 |
| 버퍼 | `]b` / `[b` | 다음 / 이전 버퍼 |
| | `:bd` | 버퍼 닫기 (`:q`는 창만 닫음. 마지막 창이면 nvim 종료) |
| 자동완성 (입력 모드) | `Ctrl-n` / `Ctrl-p`, `Enter` | 고르기, 확정 |
| | `Ctrl-l` | 목록 직접 띄우기 / 설명 창 토글 (`Ctrl-Space` 대신) |
| | `Ctrl-e` | 목록 닫기 |

### tmux (prefix = `Ctrl-b`)

| 키 | 동작 |
|---|---|
| `prefix \` / `prefix -` | 좌우 / 위아래로 나누기 (현재 경로 유지) |
| `prefix h/j/k/l` | pane 이동 |
| `prefix H/J/K/L` | pane 크기 조절 |
| `prefix z` | pane 확대 / 원래대로 |
| `prefix Tab` | 직전 창(window)으로 |
| `prefix [` → `v` → `y` | 복사 모드 → 선택 → 클립보드로 복사 |
| `prefix r` | 설정 다시 읽기 |
| `prefix Ctrl-s` / `prefix Ctrl-r` | 세션 저장 / 복원 (15분마다 자동 저장, tmux를 새로 켜면 마지막 저장 상태로 자동 복원) |
| `prefix a` / `prefix m` | 현재 창 activity 알림 / 10초 silence 알림 토글 |

---

## 5. C/C++ 프로젝트에서 clangd 쓰기

clangd가 정확하게 동작하려면 프로젝트 루트에 **`compile_commands.json`**(파일별 실제 컴파일 옵션)이 있어야 합니다.
이게 있으면 `#ifdef CONFIG_*`, 플랫폼별 include 경로까지 실제 빌드 기준으로 분석합니다.

| 프로젝트 | 만드는 방법 |
|---|---|
| TF-A | `make ... clean` 후 `bear --output <tf-a 루트>/compile_commands.json -- make ...` |
| U-Boot | 빌드 후 `./scripts/gen_compile_commands.py` |
| Linux | 빌드 후 `./scripts/clang-tools/gen_compile_commands.py` (또는 `make compile_commands.json`) |
| CMake | `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` |
| 일반 Make | `bear -- make` |

TF-A 예 (upstream, FVP 플랫폼):

```bash
cd trusted-firmware-a
make PLAT=fvp CROSS_COMPILE=aarch64-none-elf- realclean
bear -- make PLAT=fvp CROSS_COMPILE=aarch64-none-elf- all
```

빌드를 다른 디렉토리의 Makefile/스크립트가 대신 실행한다면 `bear --output <tf-a 루트>/compile_commands.json -- <빌드 명령>`처럼
출력 위치를 소스 루트로 지정하세요. 래퍼 Makefile의 `clean` 타깃이 실제로 TF-A를 지우는지도 확인하세요.

알아둘 점:

- `bear`는 실제로 컴파일된 파일만 기록합니다. 이미 빌드된 상태면 빈 파일(`[]`)이 됩니다 → clean 후 빌드.
- 빌드 설정(PLAT, 빌드 옵션 등)을 바꾸면 다시 만드세요.
- **빌드에 들어가지 않는 파일**은 비슷한 파일의 옵션을 빌려 분석해서 가짜 에러가 날 수 있습니다.
  (예: `ENABLE_BACKTRACE=0`일 때 `common/backtrace/backtrace.c`)
- 어셈블리(`.S`) 함수는 clangd로 정의를 찾을 수 없습니다 → `Space fw` 검색이나 ctags.
- buildroot가 소스를 복사해서 빌드하는 경우(`*_OVERRIDE_SRCDIR`), 그 결과로 만든 `compile_commands.json`은
  복사본 경로를 가리킵니다. 원본 폴더에서 `make O=...`로 빌드해서 만드는 게 좋습니다.
- clangd 색인 캐시는 프로젝트 루트의 `.cache/clangd/`에 생깁니다. `compile_commands.json`과 함께 git에서 제외하세요
  (`.git/info/exclude` 등).
- 크로스 컴파일러 헤더를 찾도록 `--query-driver`에 `~/toolchains/**/bin/*-gcc`, `/opt/**/bin/*-gcc`, `/usr/bin/*-gcc*`, buildroot `**/host/bin/*-gcc`가
  허용되어 있습니다 (`nvim/lua/plugins/lsp.lua`). 다른 위치의 툴체인을 쓰면 여기에 추가하세요.

---

## 6. 알려진 주의점

- **macOS 경로는 아직 실제 Mac에서 테스트하지 않았습니다.** (Linux는 빈 HOME에서 전체 설치 → 재실행 → clangd 동작까지 확인)
- `Ctrl-Space`가 런처(ulauncher, Spotlight 등)와 겹쳐서 자동완성 목록 열기는 `Ctrl-l`로 바꿨습니다.
- GNOME Terminal은 `Ctrl+PgUp/PgDn`을 탭 전환에 써서 nvim에서 쓰지 않습니다.
- tmux 클립보드: Wayland는 `wl-copy`, X11은 `xclip`, macOS는 `pbcopy`를 자동으로 사용합니다.
- 터미널 설정(GNOME Terminal 프로필, 셸 `.bashrc` 등)은 이 저장소에 포함되어 있지 않습니다.

## 7. 되돌리기

```bash
rm ~/.config/nvim ~/.tmux.conf                     # 링크 삭제
mv ~/.config/nvim.bak-<날짜> ~/.config/nvim         # 설치 전 백업이 있으면 복원
mv ~/.tmux.conf.bak-<날짜> ~/.tmux.conf
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim   # 플러그인·언어 서버·캐시
```
