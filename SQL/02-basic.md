# 📘 SQL 중급 정리: SELECT, WHERE, 정렬, 데이터 타입, 문자열 함수

## 📚 핵심 개념 요약

```sql
SELECT 컬럼명 FROM 테이블명
WHERE 조건
ORDER BY 정렬기준
LIMIT 개수 OFFSET 개수;
```

---

## 🔍 WHERE 조건식

### 🔹 비교 연산자

| 연산자 | 의미       | 예시               |
|--------|------------|--------------------|
| =      | 같음       | `name = 'kim'`     |
| <>, != | 다름       | `id <> 1`          |
| >, >=  | 크거나 같음 | `id >= 2`          |
| <, <=  | 작거나 같음 | `age <= 30`        |
| AND    | 모두 만족   | `age > 20 AND id < 5` |
| OR     | 하나 만족   | `age < 20 OR age > 65` |

### 🔹 특수 연산자

| 연산자     | 의미         | 예시                            |
|------------|--------------|---------------------------------|
| BETWEEN    | 범위 검색     | `id BETWEEN 1 AND 3`            |
| IN         | 목록 검색     | `name IN ('kim', 'lee')`       |
| LIKE       | 패턴 검색     | `email LIKE '%test.com'`       |
| IS NULL    | NULL 확인     | `email IS NULL`                |
| IS NOT NULL| NOT NULL 확인 | `email IS NOT NULL`            |

### 🔹 LIKE 패턴 문자

- `%` : 0개 이상의 임의 문자  
- `_` : 정확히 1개의 임의 문자

---

## 🔗 논리 연산자 예시

```sql
-- AND: 모든 조건 만족
SELECT * FROM member WHERE name = 'kim' AND id >= 2;

-- OR: 하나 이상 조건 만족
SELECT * FROM member WHERE name = 'kim' OR name = 'lee';

-- NOT: 조건의 반대
SELECT * FROM member WHERE NOT name = 'kim';
```

---

## 📊 ORDER BY (정렬)

```sql
-- 기본 정렬 (오름차순)
SELECT * FROM member ORDER BY name;
SELECT * FROM member ORDER BY name ASC;

-- 내림차순 정렬
SELECT * FROM member ORDER BY created_at DESC;

-- 다중 컬럼 정렬 (우선순위: name → id)
SELECT * FROM member ORDER BY name ASC, id DESC;
```

---

## 📋 주요 데이터 타입

### 🔸 문자열 타입

| 타입      | 특징       | 사용 예시         |
|-----------|------------|------------------|
| CHAR(n)   | 고정 길이   | 주민번호, 우편번호 |
| VARCHAR(n)| 가변 길이   | 이름, 이메일       |
| TEXT      | 긴 문자열   | 게시글 내용       |

📎 참고: [당근 테크 블로그 - VARCHAR vs TEXT](https://medium.com/daangn/varchar-vs-text-230a718a22a1)

### 🔸 숫자 타입

| 타입         | 크기      | 사용 예시   |
|--------------|-----------|--------------|
| INT          | 4바이트   | ID, 개수     |
| FLOAT        | 4바이트 소수 | 점수, 비율 |
| DECIMAL(m,d) | 정확한 소수 | 금액, 정밀 계산 |

### 🔸 날짜 타입

| 타입     | 형식                  | 사용 예시     |
|----------|-----------------------|----------------|
| DATE     | `YYYY-MM-DD`          | 생년월일       |
| DATETIME | `YYYY-MM-DD HH:MM:SS` | 정확한 시점    |

---

## 🔤 문자열 함수

| 함수                      | 설명           | 예시                          | 결과     |
|---------------------------|----------------|-------------------------------|----------|
| `LENGTH(str)`             | 길이           | `LENGTH('hello')`             | `5`      |
| `CONCAT(str1, str2, ...)` | 문자열 연결    | `CONCAT('A', 'B')`            | `'AB'`   |
| `UPPER(str)`              | 대문자 변환    | `UPPER('hello')`              | `'HELLO'`|
| `LOWER(str)`              | 소문자 변환    | `LOWER('HELLO')`              | `'hello'`|
| `SUBSTRING(str, pos, len)`| 부분 추출      | `SUBSTRING('hello', 2, 3)`    | `'ell'`  |
| `REPLACE(str, old, new)`  | 문자 치환      | `REPLACE('hello', 'l', 'x')`  | `'hexxo'`|
| `LEFT(str, len)`          | 왼쪽부터 추출  | `LEFT('hello', 3)`            | `'hel'`  |
| `RIGHT(str, len)`         | 오른쪽부터 추출| `RIGHT('hello', 3)`           | `'llo'`  |
| `LOCATE(substr, str)`     | 위치 찾기      | `LOCATE('ll', 'hello')`       | `3`      |
| `TRIM(str)`               | 공백 제거      | `TRIM(' hello ')`             | `'hello'`|

---

## 💡 실무 활용 예시

### ✅ 이메일에서 사용자명 추출
```sql
SELECT
  email,
  SUBSTRING(email, 1, LOCATE('@', email) - 1) AS username
FROM member
WHERE email IS NOT NULL;
```

### ✅ 회원 정보 형식 만들기
```sql
SELECT CONCAT(name, '(', email, ')') AS member_info FROM member;
```

### ✅ 검색 조건 조합
```sql
-- 이름에 '수' 포함 & 이메일이 gmail
SELECT * FROM member
WHERE name LIKE '%수%'
  AND email LIKE '%gmail%';
```

---

## ⚠️ 주의사항

- `NULL` 값 비교 시 `= NULL` ❌ → `IS NULL` ✅  
- 문자열 함수는 **대용량 데이터** 처리 시 성능 주의  
- `ORDER BY`는 성능 저하 요소 → `LIMIT`, `OFFSET` 조합 활용

---

## 🎯 핵심 포인트 요약

- **WHERE 절**은 데이터 필터링의 핵심
- **ORDER BY**로 원하는 정렬 구현
- **데이터 타입 선택**이 성능과 저장공간에 영향
- **문자열 함수**로 다양한 데이터 가공 가능
- **조건 조합**으로 복잡한 검색도 구현 가능
