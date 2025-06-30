# ✏️ 현지의 SQL 수업 정리 

## 1. 🔍 데이터베이스 기본 개념

- **정확도가 매우 중요한 DB라면 → SQL 사용**
- **정규화**하여 데이터를 저장함 (데이터 중복 제거, 구조적 저장)
- SQL은 데이터를 **조회하고 조작**하는 언어
- **DB → 데이터 → 테이블(구조)** 로 구성됨

## 2. 🔗 데이터베이스 종류에 따른 선택

| 상황 | 추천 DB |
|------|---------|
| 관계형 데이터를 다루고 싶을 때 | **SQL(Relational DB)** |
| 그래프 구조(예: 친구 관계, SNS, 비행기 노선 등)를 다루고 싶을 때 | **그래프 DB (Graph Database)** |

## 3. 📐 설계와 구조 (스키마 & 모델링)

- **모델링**: 데이터를 저장하기 전 **무엇을, 어떻게** 저장할지 고민하고 설계
- **스키마(Schema)**: 데이터 구조를 짜는 것 = DB의 설계도
- **DDL (Data Definition Language)**: 테이블 구조 등을 정의할 때 사용
  - 예: `CREATE`, `ALTER`, `DROP`
- **DML (Data Manipulation Language)**: 데이터를 다룰 때 사용
  - 예: `INSERT`, `UPDATE`, `DELETE`, `SELECT`
- 테이블마다 **Primary Key**는 **하나만 존재**

## 4. ⚙️ 주요 용어 설명

- **Server**: 데이터를 **요청받고 처리해주는 쪽**
- **Client**: 데이터를 **요청하는 쪽**
- **Convention (관습)**: 국룰, 일반적으로 통용되는 코드 스타일이나 규칙
- **Structured (스트럭처)**: 정해진 형식이나 약속이 있는 구조
- **Query (쿼리)**: 데이터베이스에 **질문(요청)**을 하는 것
- **VARCHAR**: **가변 길이 문자열** 타입

## 5. ⚠️ 주의할 점

- SQL은 `;`(세미콜론)를 기준으로 구문 종료를 인식함 → 꼭 붙이기!
- **컨트롤 + 엔터**: 쿼리 실행 단축키
- **불문율**: SQL에서는 `Primary Key는 하나`, `세미콜론으로 끝내기` 같은 룰은 사실상 **암묵적 표준**


# MySQL 1일차 요약본
#####

## 📊 데이터베이스 핵심 개념

### 스키마(Schema)
- **정의**: 데이터베이스의 구조와 제약조건을 정의한 것
- **포함 요소**: 테이블 구조, 데이터 타입, 제약조건, 관계 등
- **역할**: 데이터가 어떻게 저장되고 관리될지 설계도 역할

### DDL vs DML

| 구분 | DDL (Data Definition Language) | DML (Data Manipulation Language) |
|------|-------------------------------|-----------------------------------|
| **목적** | 데이터베이스 구조 정의/변경 | 데이터 조작 |
| **대상** | 테이블, 데이터베이스, 스키마 | 데이터 (행) |
| **주요 명령어** | CREATE, ALTER, DROP | INSERT, SELECT, UPDATE, DELETE |
| **실행 결과** | 구조 변경 | 데이터 변경 |

---

## 🗄️ 데이터베이스 관리 (DDL) ➡️ 데이터 정의어

```sql
-- 데이터베이스 생성
CREATE DATABASE database_name;

-- 데이터베이스 선택
USE database_name;

-- 데이터베이스 목록 조회
SHOW DATABASES;

-- 데이터베이스 삭제
DROP DATABASE IF EXISTS database_name;
```

---

## 📋 테이블 관리 (DDL) ➡️ 데이터 조작어

### 테이블 생성
```sql
CREATE TABLE table_name (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) NOT NULL,
  email VARCHAR(50) UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 테이블 구조 확인
```sql
-- 테이블 목록
SHOW TABLES;

-- 테이블 구조
DESC table_name;
```

### 테이블 구조 변경
```sql
-- 컬럼 추가
ALTER TABLE table_name ADD COLUMN column_name datatype;

-- 컬럼 수정
ALTER TABLE table_name MODIFY COLUMN column_name new_datatype;

-- 컬럼 삭제
ALTER TABLE table_name DROP COLUMN column_name;
```

### 테이블 삭제
```sql
DROP TABLE IF EXISTS table_name;
```

---

## 📝 데이터 조작 (DML)

### INSERT - 데이터 입력
```sql
-- 단일 행 입력
INSERT INTO table_name (column1, column2) VALUES (value1, value2);

-- 다중 행 입력
INSERT INTO table_name (column1, column2) VALUES 
(value1, value2),
(value3, value4);
```

### SELECT - 데이터 조회
```sql
-- 전체 조회
SELECT * FROM table_name;

-- 특정 컬럼 조회
SELECT column1, column2 FROM table_name;

-- 조건부 조회
SELECT * FROM table_name WHERE condition;
```

### UPDATE - 데이터 수정
```sql
UPDATE table_name SET column1 = value1 WHERE condition;
```

### DELETE - 데이터 삭제
```sql
DELETE FROM table_name WHERE condition;
```
##### **테이블 모든 데이터 삭제될 위험!** ➡️ Safe Update Mode 설정
---

## 🔐 주요 제약조건

### PRIMARY KEY
- **목적**: 각 행의 고유 식별자
- **특징**: 중복 불가, NULL 불가, 테이블당 1개
```sql
id INT AUTO_INCREMENT PRIMARY KEY
```

### NOT NULL
- **목적**: 필수 입력 강제
- **특징**: 빈 값 입력 불가
```sql
name VARCHAR(30) NOT NULL
```

### UNIQUE
- **목적**: 중복 값 방지
- **특징**: 중복 불가, NULL 허용, 여러 개 가능
```sql
email VARCHAR(50) UNIQUE
```

### DEFAULT
- **목적**: 기본값 자동 입력
- **특징**: 값 미입력 시 기본값 사용
```sql
status VARCHAR(10) DEFAULT 'active'
created_at DATETIME DEFAULT CURRENT_TIMESTAMP
```

### AUTO_INCREMENT
- **목적**: 숫자 자동 증가
- **특징**: 주로 PRIMARY KEY와 함께 사용
```sql
id INT AUTO_INCREMENT PRIMARY KEY
```

---

## 📊 주요 데이터 타입

| 타입 | 설명 | 예시 |
|------|------|------|
| `INT` | 정수 | `age INT` |
| `VARCHAR(n)` | 가변 문자열 | `name VARCHAR(50)` |
| `TEXT` | 긴 문자열 | `content TEXT` |
| `DATE` | 날짜 | `birth_date DATE` |
| `DATETIME` | 날짜+시간 | `created_at DATETIME` |

---

## ⚠️ 주의사항

### 안전한 쿼리 작성
```sql
-- ❌ 위험 (모든 데이터 영향)
UPDATE users SET status = 'inactive';
DELETE FROM users;

-- ✅ 안전 (조건 지정)
UPDATE users SET status = 'inactive' WHERE id = 1;
DELETE FROM users WHERE status = 'deleted';
```

### WHERE 절 필수 상황
- UPDATE: 특정 데이터만 수정
- DELETE: 특정 데이터만 삭제
- SELECT: 조건에 맞는 데이터만 조회

### IF EXISTS 사용
```sql
-- 에러 방지
DROP TABLE IF EXISTS table_name;
DROP DATABASE IF EXISTS database_name;
```

---

## 🎯 핵심 포인트

1. **DDL**로 구조를 만들고, **DML**로 데이터를 다룬다
2. **스키마**는 데이터베이스의 설계도
3. **제약조건**은 데이터 무결성 보장
4. **WHERE 절**은 안전한 데이터 조작의 핵심
5. **PRIMARY KEY + AUTO_INCREMENT**는 기본 패턴
6. **DEFAULT + CURRENT_TIMESTAMP**로 자동 시간 입력