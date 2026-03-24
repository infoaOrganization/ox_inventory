# release branch에 배포하는 방법
```sh scripts/publish.sh```

# 빌드 흐름
+ ```scripts/build.sh``` 실행 — 먼저 빌드
+ prepare_publish release — GitHub의 release 브랜치를 tmp/ 폴더에 clone (없으면 새로 생성)
+ build/* 파일들을 tmp/에 복사
+ finalize_publish release — tmp/에서 commit 후 release 브랜치에 push
