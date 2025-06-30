# ✅ 오늘 현지가 Git으로 한 일 요약

## 🗂️ 1. Git 저장소 초기화 (로컬 폴더)

```bash
cd ~/TIL
git init
```

- `~/TIL` 폴더를 Git 저장소로 등록했어.
- `.git/` 숨김 폴더가 생기고, Git 명령어를 쓸 수 있게 됨.

## 🌐 2. GitHub 리포지토리 연결

```bash
git remote add origin https://github.com/oklm33314/TIL.git
```

- 로컬 Git과 GitHub 저장소를 연결함
- `origin`이라는 이름으로 GitHub 주소 등록

## 🧾 3. 파일 스테이징 & 커밋

```bash
git add .
git commit -m "sql basic"
```

- 모든 변경사항을 스테이징 후 "sql basic"이라는 메시지로 첫 커밋 기록

## ⚠️ 4. push 시도 → 오류 발생

```bash
git push -u origin main
```

- GitHub에 이미 README.md 등이 존재해서 충돌 발생
- GitHub 내용과 로컬 내용이 서로 **"서로 다른 히스토리"**여서 푸시 거부됨

## 🔀 5. 병합 처리 (pull & merge)

```bash
git pull origin main --allow-unrelated-histories
```

- GitHub의 기존 파일(README 등)과 로컬의 커밋을 병합
- 병합 후 MERGING 상태가 되어 커밋 필요

## ✅ 6. 병합 커밋

```bash
git commit -m "Merge GitHub and local changes"
```

- 병합 상태(MERGING)를 마무리함

## 🚀 7. 최종 push

```bash
git push -u origin main
```

- GitHub에 최종적으로 업로드 성공
- `-u` 옵션으로 main 브랜치와 origin/main 연동 완료

## 📝 기타 참고 사항

| 항목 | 설명 |
|------|------|
| MERGING 상태 | 병합 중. 커밋해야 벗어남 |
| -u 옵션 | 원격 브랜치(origin/main)와 로컬(main) 연동 |
| 충돌 해결 | pull → commit → push 순서 |
| LF ↔ CRLF 경고 | 줄바꿈 변환 알림 (무시 가능) |

## ✅ 최종 결과

- 로컬 폴더와 GitHub가 연결 완료
- `.sql`, `.md` 파일들이 GitHub에 정상 업로드됨
- 다음부터는 `git add .` → `commit` → `push`만으로 관리 가능!

```bash
git add .
git commit -m "sql basic"
git push origin main
``` 