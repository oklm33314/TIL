# 📌 복합 인덱스 컬럼 순서의 중요성

복합 인덱스에서 **컬럼의 순서**는 매우 중요하며, 인덱스 성능에 큰 영향을 미칩니다.

## ✅ 기본 원칙
- 자주 사용되는 컬럼을 **앞에** 위치시킵니다.
- **선택도(데이터 중복도)**가 높은 컬럼을 **앞에** 배치하는 것이 좋습니다.
- `WHERE` 절에서 사용되는 **조건문의 순서**대로 인덱스를 구성하면 효율적입니다.

---

## 🔍 선택도(Selectivity)
- 선택도란 특정 컬럼의 **고유한 값의 수**를 의미합니다.
- 선택도가 높을수록 **검색 시 필터링 효과**가 커져 인덱스 성능 향상에 유리합니다.

---

## 🧾 WHERE 절 사용 순서
- 복합 인덱스는 **구성된 컬럼 순서대로 정렬**됩니다.
- `WHERE` 절에서 **앞쪽 컬럼부터 순서대로** 사용하는 것이 인덱스 효율을 높입니다.

---

## 🔃 ORDER BY 절 사용
- `ORDER BY` 절에서도 복합 인덱스를 사용할 수 있습니다.
- `WHERE` 절과 마찬가지로 **앞쪽 컬럼부터 순서대로** 사용해야 인덱스 효과를 볼 수 있습니다.

---

## 📊 카디널리티(Cardinality)
- **카디널리티**란 데이터 집합에서 **고유한 값의 개수**를 의미합니다.
- 카디널리티가 높은 컬럼을 앞에 배치하면 **인덱스 스캔 범위**를 줄일 수 있어 성능이 향상됩니다.

---

## ⚠️ UPDATE 빈도
- 자주 변경되는 컬럼에 인덱스를 걸면 **인덱스 업데이트 비용**이 증가해 성능이 저하될 수 있습니다.

---

## 💡 예시
- `users` 테이블에 `country`, `city`, `name` 컬럼이 있을 때,
- 검색 조건이 주로 `country`와 `city` 기준이라면 인덱스를 `(country, city, name)` 순서로 생성하는 것이 효과적입니다.

---

## ⚠️ 주의사항
- 복합 인덱스를 **무분별하게 많이 생성**하는 것은 지양해야 합니다.
- **실제 사용 빈도**와 **성능 요구사항**을 고려해 인덱스를 구성해야 합니다.
- 데이터베이스 시스템의 **특성**과 **인덱스 구조**를 이해하고 최적의 순서를 결정하세요.

# 수업내용

# MySQL EXPLAIN 및 인덱싱 완전 정복

## 🔍 MySQL EXPLAIN 기본 사용법

### MySQL EXPLAIN 문법

```sql
-- MySQL에서 사용했던 기본 형태들
USE lecture;

-- 1. 기본 EXPLAIN
EXPLAIN
SELECT * FROM sales WHERE total_amount > 500000;

-- 2. EXPLAIN EXTENDED (MySQL 5.1+)
EXPLAIN EXTENDED
SELECT * FROM sales WHERE total_amount > 500000;
SHOW WARNINGS;  -- 추가 정보 확인

-- 3. EXPLAIN FORMAT=JSON (MySQL 5.6+)
EXPLAIN FORMAT=JSON
SELECT * FROM sales WHERE total_amount > 500000;

-- 4. 실제 실행 통계 (MySQL 8.0+)
EXPLAIN ANALYZE
SELECT * FROM sales WHERE total_amount > 500000;
```

### MySQL EXPLAIN 결과 구조

```sql
EXPLAIN
SELECT c.customer_name, s.product_name, s.total_amount
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
WHERE c.customer_type = 'VIP';


-- 결과 컬럼들

| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
|----|-------------|-------|------|----------------|-----|---------|-----|------|--------|
| 1  | SIMPLE      | c     | ALL  | PRIMARY        | NULL| NULL    | NULL| 50   | Using where |
| 1  | SIMPLE      | s     | ref  | customer_id    | cust_id | 12 | c.id | 2 | NULL |
```

## 🆚 MySQL vs PostgreSQL EXPLAIN 비교

### 1. 출력 형태 차이

#### MySQL 방식 (테이블 형태)

```sql
EXPLAIN SELECT * FROM sales WHERE customer_id = 'C001';

-- 결과:
-- +----+-------------+-------+-------+-------------------+----------+---------+-------+------+-------+
-- | id | select_type | table | type  | possible_keys     | key      | key_len | ref   | rows | Extra |
-- +----+-------------+-------+-------+-------------------+----------+---------+-------+------+-------+
-- |  1 | SIMPLE      | sales | const | PRIMARY,cust_idx  | PRIMARY  | 12      | const |    1 | NULL  |
-- +----+-------------+-------+-------+-------------------+----------+---------+-------+------+-------+
```

#### PostgreSQL 방식 (트리 형태)

```sql
EXPLAIN SELECT * FROM large_orders WHERE customer_id = 'CUST-025000';
-- 결과:
-- Index Scan using idx_large_orders_customer_id on large_orders  (cost=0.42..8.45 rows=1 width=89)
--   Index Cond: (customer_id = 'CUST-025000'::text)
```


### 2. 정보 표현 방식 차이

#### MySQL 컬럼별 의미

```sql
-- MySQL EXPLAIN 컬럼 설명

-- id: SELECT 식별자 (중첩 쿼리에서 순서)
-- select_type:
--   - SIMPLE: 단순 SELECT
--   - PRIMARY: 외부 쿼리
--   - SUBQUERY: 서브쿼리
--   - DERIVED: 파생 테이블 (FROM 절 서브쿼리)

-- table: 참조되는 테이블명

-- type: 조인 타입 (성능 순서)
--   - system: 테이블에 행이 1개 또는 0개
--   - const: 기본키나 유니크키로 조회 (가장 빠름)
--   - eq_ref: 조인에서 기본키나 유니크키 사용
--   - ref: 인덱스 사용 (여러 행 반환 가능)
--   - range: 범위 조건으로 인덱스 사용
--   - index: 인덱스 전체 스캔
--   - ALL: 테이블 전체 스캔 (가장 느림)

-- rows: 예상 검사 행 수
-- Extra: 추가 정보
--   - Using where: WHERE 조건 사용
--   - Using index: 커버링 인덱스 사용
--   - Using temporary: 임시 테이블 사용
--   - Using filesort: 정렬을 위한 파일 소트
```

#### PostgreSQL 방식
```sql
-- PostgreSQL: 비용 기반 정보
-- cost=0.42..8.45: 시작비용..총비용
-- rows=1: 예상 반환 행 수
-- width=89: 행당 평균 바이트 수
-- actual time=0.123..0.125: 실제 실행 시간 (ANALYZE 시)
-- loops=1: 노드 실행 횟수
```

## 🔧 MySQL EXPLAIN 실전 분석

### MySQL에서 성능 문제 진단

```sql
-- 1. 인덱스 사용 확인
EXPLAIN
SELECT * FROM sales WHERE total_amount > 500000;

-- 나쁜 결과:
-- type: ALL (전체 테이블 스캔)
-- Extra: Using where

-- 좋은 결과:
-- type: range (범위 스캔)
-- key: idx_total_amount

-- 2. 조인 성능 확인
EXPLAIN
SELECT c.customer_name, COUNT(s.id)
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name;

-- 주의할 점:
-- type: ALL → 인덱스 필요
-- Extra: Using temporary → 메모리 부족
-- Extra: Using filesort → 정렬 최적화 필요
```


### MySQL 성능 최적화 패턴

```sql
-- 최적화 전후 비교

-- 1. 인덱스 없는 상태
EXPLAIN SELECT * FROM sales WHERE customer_id = 'C001';
-- type: ALL, rows: 120 (전체 스캔)

-- 인덱스 생성 후
ALTER TABLE sales ADD INDEX idx_customer_id (customer_id);
EXPLAIN SELECT * FROM sales WHERE customer_id = 'C001';
-- type: ref, rows: 3 (인덱스 사용)

-- 2. 복합 인덱스 활용
EXPLAIN SELECT * FROM sales
WHERE customer_id = 'C001' AND order_date >= '2024-01-01';

-- 단일 인덱스: type: ref, Extra: Using where
-- 복합 인덱스 생성 후: type: range, 더 효율적
ALTER TABLE sales ADD INDEX idx_customer_date (customer_id, order_date);
```



## 🎯 MySQL vs PostgreSQL EXPLAIN 요약

| 표현 방식 | MySQL | PostgreSQL |
|-----------|-------|------------|
| 출력 형태 | 테이블 형태 | 트리 형태 |
| 정보 밀도 | 간결함 | 상세함 |
| 가독성 | 초보자 친화적 | 전문가 친화적 |

## 기능 차이

| 기능 | MySQL | PostgreSQL |
|------|-------|------------|
| 비용 정보 | 제한적 | 매우 상세 |
| 실제 통계 | MySQL 8.0+ | 기본 지원 |
| 메모리 정보 | 제한적 | BUFFERS 옵션 |
| 출력 형식 | TEXT, JSON | TEXT, JSON, YAML, XML |

## 성능 분석 접근법
```sql
-- MySQL 접근법: type 컬럼 중심
-- const > eq_ref > ref > range > index > ALL
-- Extra 정보로 추가 최적화 포인트 확인

-- PostgreSQL 접근법: cost와 실제 시간 중심
-- 비용이 높은 노드 찾기 → 실제 시간 확인 → 최적화
```
## 실무 사용 팁

- MySQL: type = ALL, Using temporary, Using filesort → 성능 저하 요소
- PostgreSQL: 비용 추적, 통계 활용 가능

##  MYSQL에서 주의 할 점
```sql
-- 1. type = ALL인 경우 → 인덱스 검토
-- 2. Extra = Using temporary → 메모리/쿼리 최적화
-- 3. Extra = Using filesort → ORDER BY 최적화
-- 4. rows 수가 많은 경우 → 조건 추가 검토

```

## PostgreSQL 장점
```sql
-- 1. 더 정확한 비용 계산
-- 2. 실제 실행 통계 제공
-- 3. 메모리 사용량 추적 가능
-- 4. 더 세밀한 성능 튜닝 가능
```

---

# 📊 인덱싱 완전 정복

## 🎯 인덱스 성능 개선 결과 요약
### 💥 극적 성능 향상 사례

### 1. 단일 고객 검색 (customer_id)

```sql
🔍 쿼리: SELECT * FROM orders WHERE customer_id = 'CUST-12345'

📊 성능 비교:
   인덱스 없음: 100만 개 행 검사 → 느림
   인덱스 있음: 필요한 행만 검사 → 매우 빠름

⚡ 개선 효과: 수백 배 성능 향상
```

### 2. 범위 검색 (amount)

```sql
🔍 쿼리: SELECT * FROM orders WHERE amount BETWEEN 500000 AND 1000000

📊 성능 비교:
   인덱스 없음: 전체 테이블 스캔 → 느림
   인덱스 있음: 범위 내 데이터만 검사 → 빠름

⚡ 개선 효과: 2~3배 성능 향상
```

### 3. 복합 조건 검색 (region + amount)

```sql
🔍 쿼리: SELECT * FROM orders WHERE region = '서울' AND amount > 800000

📊 성능 비교:
   단일 인덱스: 한 조건만 인덱스 사용 → 보통
   복합 인덱스: 모든 조건이 인덱스 사용 → 매우 빠름

⚡ 개선 효과: 4~5배 성능 향상
```

## 🏗️ 인덱스 종류별 성능 특성

### 🌳 B-Tree 인덱스 vs #️⃣ Hash 인덱스

#### 📖 B-Tree 인덱스 (기본형)
- 📚 특징: 책의 목차처럼 계층적 구조
- 🎯 최적 용도: 범위 검색, 정렬 작업

| 검색 유형                      | 성능   | 지원 여부 |
|-------------------------------|--------|------------|
| 🔍 정확 일치 (=)              | ⭐⭐⭐⭐  | ✅         |
| 📊 범위 검색 (>, <, BETWEEN)  | ⭐⭐⭐⭐⭐ | ✅         |
| 📈 정렬 (ORDER BY)            | ⭐⭐⭐⭐⭐ | ✅         |
| 🔤 부분 일치 (LIKE 'ABC%')    | ⭐⭐⭐⭐  | ✅         |

#### #️⃣ Hash 인덱스
- 🏷️ 특징: 해시태그처럼 정확한 값으로 바로 접근
- 🎯 최적 용도: 정확한 일치 검색만

| 검색 유형                      | 성능   | 지원 여부 |
|-------------------------------|--------|------------|
| 🔍 정확 일치 (=)              | ⭐⭐⭐⭐⭐ | ✅         |
| 📊 범위 검색 (>, <, BETWEEN)  | ❌     | ❌         |
| 📈 정렬 (ORDER BY)            | ❌     | ❌         |
| 🔤 부분 일치 (LIKE 'ABC%')    | ❌     | ❌         |

---

### ⚡ 성능 비교 실례

#### 정확 일치 검색에서의 성능

```sql
Copy-- 이메일로 사용자 찾기
SELECT * FROM users WHERE email = 'user@example.com';
```

| 인덱스 종류     | 검색 속도      | 메모리 사용량 |
|----------------|----------------|----------------|
| B-Tree 인덱스  | 매우 빠름 ⭐⭐⭐⭐ | 보통           |
| Hash 인덱스    | 초고속 ⭐⭐⭐⭐⭐   | 적음           |

#### 범위 검색에서의 성능

```sql
Copy-- 특정 기간 주문 검색
SELECT * FROM orders WHERE order_date >= '2024-01-01' AND order_date <= '2024-01-31';
```

| 인덱스 종류     | 검색 속도      | 지원 여부 |
|----------------|----------------|------------|
| B-Tree 인덱스  | 매우 빠름 ⭐⭐⭐⭐⭐ | ✅         |
| Hash 인덱스    | 불가능 ❌       | ❌         |

---

### 🎯 실무 적용 가이드

#### ✅ B-Tree 인덱스를 선택해야 하는 경우
- 날짜 범위 검색: `"2024년 1월 주문"`
- 가격 범위 검색: `"50만원~100만원 상품"`
- 정렬이 필요한 경우: `"최신순 정렬"`
- 부분 일치 검색: `"김씨 성을 가진 고객"`
- 대부분의 일반적인 검색

#### ✅ Hash 인덱스를 선택해야 하는 경우
- 로그인 시스템: 이메일 정확 일치
- 상품 코드 검색: 정확한 코드만
- 사용자 ID 검색: 정확한 ID만
- 메모리 효율이 중요한 경우

❌ 범위 검색이 필요한 경우는 Hash 인덱스 부적합

---

### 📈 성능 향상 패턴 분석

#### 🏆 가장 큰 성능 향상을 보이는 경우

1. **고유값이 많은 컬럼 (고선택도)**  
   - 예시: `customer_id`, `email`, `주문번호`  
   - 특징: 각 값이 거의 유일함
   - B-Tree: ⭐⭐⭐⭐⭐  (최대 효과)
   - Hash: ⭐⭐⭐⭐⭐ (정확 일치 시 최고)

2. **자주 검색되는 컬럼**  
   - 예시: `상품명`, `사용자명`, `날짜`  
   - 특징: WHERE 절에서 자주 사용
   - B-Tree: ⭐⭐⭐⭐ (모든 검색 지원)
   - Hash: ⭐⭐⭐ (정확 일치만 지원)

3. **범위 검색이 많은 컬럼**  
   - 예시: `가격`, `날짜`, `수량`  
   - 특징: BETWEEN, >, < 연산 자주 사용
   - B-Tree: ⭐⭐⭐⭐⭐ (범위 검색 최적) 
   - Hash: ❌ (범위 검색 불가)

#### 📊 상대적으로 작은 성능 향상

1. **고유값이 적은 컬럼 (저선택도)**  
   - 예시: `성별`, `지역`, `상태값` 
   - 특징: 같은 값이 많이 반복됨 
   - B-Tree: ⭐⭐ (효과 제한적)  
   - Hash: ⭐⭐  (효과 제한적)

2. **자주 변경되는 컬럼**  
   - 예시: `재고수량`, `최종수정일`
   - 특징: UPDATE가 빈번함
   - B-Tree: ⭐  (인덱스 유지비용 높음)
   - Hash: ⭐  (인덱스 유지비용 높음)

---

### 🎯 실무 적용 가이드

1. **로그인 시스템**

```sql
Copy-- 사용자 로그인 검증
WHERE email = 'user@example.com' AND password = 'hashed_password'
→ Hash 인덱스 권장: (email) - 정확 일치만 필요
→ B-Tree 인덱스도 가능: (email, password) - 복합 조건
```

2. **고객 주문 조회**

```sql
Copy-- 특정 고객의 주문 내역
WHERE customer_id = 'CUST-12345'
→ B-Tree 인덱스 권장: (customer_id) - 정렬도 필요할 수 있음
→ Hash 인덱스도 가능: (customer_id) - 정확 일치만 필요
```


3. **날짜 범위 검색**

```sql
Copy-- 최근 1개월 주문
WHERE order_date >= '2024-01-01' AND order_date <= '2024-01-31'
→ B-Tree 인덱스 필수: (order_date) - Hash는 범위 검색 불가
```

---

### 🤔 인덱스 선택 기준 요약

#### ✅ B-Tree 인덱스를 선택하는 경우 (90% 이상)

- 🔍 다양한 검색 패턴이 예상될 때
- 📊 범위 검색이 필요할 때
- 📈 정렬이 필요할 때
- 🔤 부분 일치 검색이 필요할 때
- 💡 확실하지 않으면 B-Tree 선택

#### ✅ Hash 인덱스를 선택하는 경우 (10% 미만)

- 🎯 정확한 일치 검색만 사용할 때
- 💾 메모리 효율이 매우 중요할 때
- ⚡ 최대 성능이 필요한 특수한 경우
- 🔒 보안상 정확한 매칭만 허용할 때

---

### 🚀 성능 개선 효과 요약

#### 💰 비즈니스 임팩트

**사용자 경험 개선**
- Before: "왜 이렇게 느려?" (3초 이상 대기)
- After: "와, 빠르네!" (1초 이내 응답)

**시스템 자원 절약**
- CPU 사용률: 80% → 20%
- 메모리 사용량: 대폭 감소
- 서버 비용: 추가 서버 구매 불필요

**확장성 확보**
- 데이터 증가: 성능 저하 최소화
- 동시 사용자: 더 많은 사용자 처리 가능
- 미래 대비: 서비스 성장에 대응

#### 📊 성능 향상 수치 정리

| 검색 유형              | 인덱스 전 | B-Tree 후        | Hash 후         | 최적 선택 |
|-----------------------|-----------|------------------|------------------|------------|
| 🔍 단일 정확 검색     | 매우 느림 | 매우 빠름 ⭐⭐⭐⭐⭐ | 초고속 ⭐⭐⭐⭐⭐   | Hash 우세  |
| 📊 범위 검색          | 느림      | 매우 빠름 ⭐⭐⭐⭐⭐ | 불가능 ❌       | B-Tree 필수 |
| 🔗 복합 조건 검색     | 느림      | 매우 빠름 ⭐⭐⭐⭐⭐ | 제한적 ⭐⭐      | B-Tree 우세 |
| 📈 정렬 포함 검색     | 매우 느림 | 매우 빠름 ⭐⭐⭐⭐⭐ | 불가능 ❌       | B-Tree 필수 |

---

### 💡 핵심 메시지

> **🎯인덱스의 핵심 가치:  "인덱스는 검색 성능을 혁신적으로 개선시키는 데이터베이스의 핵심 도구"**

#### 🏆 성공적인 인덱스 설계 4원칙

1. 실제 쿼리 패턴 분석이 가장 중요
2. 적절한 인덱스 종류 선택 (B-Tree vs Hash)
3. 적절한 컬럼 선택과 순서 배치
4. 지속적인 모니터링과 최적화

#### 🤝 간단한 선택 가이드

- 확실하지 않으면 → **B-Tree**
- 정확한 일치만 필요하면 → **Hash 고려**
- 범위 검색이 있다면 → **B-Tree 필수**