# 🎯 오늘 학습한 핵심 내용

## 오전: MySQL 고급 기능 완성
- 테이블 관계 설계 (1:1, 1:N, N:M)
- 고급 JOIN (FULL OUTER, CROSS, Self JOIN)
- 고급 서브쿼리 (ANY, ALL, EXISTS vs IN)

## 오후: PostgreSQL 기초 & 성능 체감
- PostgreSQL vs MySQL 비교
- PostgreSQL 특화 데이터 타입
- 대용량 데이터 생성 & 성능 측정
- EXPLAIN 분석 방법

---

## 🔗 1. 테이블 관계 설계 완전 정리

### ✅ 1.1 관계 유형별 특징

#### 1:1 관계 (One-to-One)
**사용 사례**: 직원 ↔ 직원상세정보 (보안상 분리)
```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30)
);

CREATE TABLE employee_details (
    emp_id INT PRIMARY KEY,
    social_number VARCHAR(20),
    salary DECIMAL(10,2),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE
);
```
💡 특징:
- 보안/성능상 테이블 분리
- 같은 Primary Key 사용
- CASCADE 옵션으로 데이터 일관성 유지

#### ✅ 1:N 관계 (One-to-Many)
**사용 사례**: 고객 ↔ 주문 (가장 흔한 관계)
```sql

-- customers (1) ↔ sales (N)

-- 외래키는 항상 'N'쪽에 위치
-- 부모 삭제 시 자식 데이터 처리 방법 고려
-- 실무에서 가장 자주 사용
```

#### ✅ N:M 관계 (Many-to-Many)
**사용 사례**: 학생 ↔ 수업
```sql
CREATE TABLE students (student_id INT PRIMARY KEY, student_name VARCHAR(50));
CREATE TABLE courses (course_id INT PRIMARY KEY, course_name VARCHAR(100));

-- 중간 테이블 (Junction Table) 필수
CREATE TABLE student_courses (
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade VARCHAR(5),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
```
💡 특징:
- 반드시 중간 테이블 필요
- 중간 테이블에 추가 속성 저장 가능
- 복합 기본키 사용

---

## 🔗 2. 고급 JOIN 패턴

### 2.1 FULL OUTER JOIN (MySQL에서 구현)
```sql
SELECT c.customer_name, s.product_name, 'LEFT에서' AS 출처
FROM customers c LEFT JOIN sales s ON c.customer_id = s.customer_id
UNION
SELECT c.customer_name, s.product_name, 'RIGHT에서' AS 출처
FROM customers c RIGHT JOIN sales s ON c.customer_id = s.customer_id
WHERE c.customer_id IS NULL;
```
💡 실무 사용: 데이터 무결성 검사, 마스터 데이터 통합 등에 활용

### 2.2 CROSS JOIN (카르테시안 곱)
```sql
SELECT c.customer_name, p.product_name, p.selling_price
FROM customers c
CROSS JOIN products p
WHERE c.customer_type = 'VIP'
ORDER BY c.customer_name, p.selling_price DESC;
```
💡 실무 사용: 추천 시스템(구매하지 않은 상품 찾기), 날짜별 기준 테이블 생성, 시나리오 분석 

### 2.3 Self JOIN (같은 테이블끼리)
```sql
-- 직원-상사 관계, 고객 유사성 분석 등
SELECT
    직원.emp_name AS 직원명,
    상사.emp_name AS 상사명
FROM employees 직원
LEFT JOIN employees 상사 ON 직원.manager_id = 상사.emp_id;
-- 💡 실무 활용: 조직도 구성, 연속 주문 분석, 고객 구매 패턴 유사성 
```

---

## ⚡ 3. 고급 서브쿼리 연산자

### 3.1 ANY 연산자 - '하나라도 만족하면'
```sql
SELECT product_name, total_amount
FROM sales
WHERE total_amount > ANY (
    SELECT s.total_amount
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    WHERE c.customer_type = 'VIP'
);

-- 동일한 의미:
WHERE total_amount > (SELECT MIN(total_amount) FROM vip_orders);

-- 💡 ANY 대표 사례:
-- - 어떤 기준보다라도 높은/낮은 값 찾기
-- - 여러 임계값 중 하나라도 넘는 경우
-- - 다중 조건 중 일부만 만족해도 되는 경우
```

### 3.2 ALL 연산자
```sql
SELECT product_name, total_amount
FROM sales
WHERE total_amount > ALL (
    SELECT s.total_amount
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    WHERE c.customer_type = 'VIP'
);

-- 동일한 의미:
WHERE total_amount > (SELECT MAX(total_amount) FROM vip_orders);

-- 💡 ALL 대표 사례:
-- - 모든 기준을 넘어서는 값 찾기
-- - 절대적 우위 조건
-- - 모든 카테고리/그룹보다 높은 성과
```

### 3.3 EXISTS vs IN 성능 비교
```sql
-- 동일한 결과, 다른 성능

-- IN 방식
SELECT customer_name FROM customers
WHERE customer_id IN (SELECT customer_id FROM sales WHERE category = '전자제품');

-- EXISTS 방식
SELECT customer_name FROM customers c
WHERE EXISTS (SELECT 1 FROM sales s WHERE s.customer_id = c.customer_id AND s.category = '전자제품');

-- 💡 선택 기준:
-- EXISTS: 큰 테이블, 복잡한 조건, 존재 여부만 확인
-- IN: 작은 값 목록, 간단한 조건
```

---

## 🆚 4. PostgreSQL vs MySQL 핵심 차이점

### 4.1 철학 및 목적
| 측면 | MySQL | PostgreSQL |
|------|-------|------------|
| 철학 | 빠르고 간단 | 표준 준수, 고급 기능 |
| 대상 | 웹 애플리케이션 | 엔터프라이즈, 분석 |
| 강점 | 단순 읽기 성능 | 복잡한 쿼리 최적화 |

### 4.2 데이터 타입 차이
- MySQL 기본 타입
```sql
INT, VARCHAR, TEXT, DATE, DATETIME, JSON(5.7+)
```
- PostgreSQL 고급 타입 예시
```sql
-- 배열 타입
tags TEXT[]
scores INTEGER[]

-- JSONB (바이너리 JSON - 검색 최적화)
metadata JSONB

-- 네트워크 타입
ip_address INET
mac_address MACADDR

-- 범위 타입
salary_range INT4RANGE
date_range DATERANGE

-- 기하학적 타입
location POINT
area POLYGON
```

### 4.3 성능 특성

- 단순 읽기: MySQL 빠름
```sql
MySQL: 10,000 QPS (우수)
PostgreSQL: 8,000 QPS
→ 웹 애플리케이션에서 MySQL 유리
```

- 복잡한 쿼리: PostgreSQL 우수
```sql
복잡한 분석 쿼리
MySQL: 15초 (제한적)
PostgreSQL: 8초 (우수)
→ 데이터 분석에서 PostgreSQL 유리
```

---

## 📊 5. PostgreSQL 특화 기능

### 5.1 강력한 데이터 생성
```sql
-- generate_series 함수 (MySQL에 없음)
SELECT generate_series(1, 1000000) AS id;
SELECT generate_series('2024-01-01'::date, '2024-12-31'::date, '1 day') AS dates;

-- 100만 건 대용량 데이터 한 번에 생성
CREATE TABLE large_orders AS
SELECT
    generate_series(1, 1000000) AS order_id,
    'CUST-' || LPAD((random() * 50000)::text, 6, '0') AS customer_id,
    (random() * 1000000)::NUMERIC(12,2) AS amount,
    -- 배열 타입 활용
    ARRAY['전자제품', '의류', '생활용품'][CEIL(random() * 3)::int] AS categories,
    -- JSONB 활용
    jsonb_build_object('payment', 'card', 'express', random() < 0.3) AS details
FROM generate_series(1, 1000000);
```

### 5.2 고급 검색 기능
```sql
-- 배열 검색
SELECT * FROM orders WHERE '전자제품' = ANY(categories);

-- JSONB 검색 (인덱스 지원)
SELECT * FROM orders WHERE details @> '{"express": true}';

-- 범위 검색
SELECT * FROM products WHERE price_range @> 50000;
```

---

## 🔍 6. EXPLAIN 분석 비교

### 6.1 MySQL EXPLAIN
```sql
-- 테이블 형태 출력
EXPLAIN SELECT * FROM sales WHERE customer_id = 'C001';

-- 주요 컬럼:
-- type: const > eq_ref > ref > range > index > ALL
-- Extra: Using index (좋음), Using filesort (주의)

```

### 6.2 PostgreSQL EXPLAIN ANALYZE
```sql
-- 트리 형태 출력, 더 상세함
EXPLAIN ANALYZE SELECT * FROM large_orders WHERE customer_id = 'CUST-025000';

-- 정보:
-- cost=0.42..8.45 (시작비용..총비용)
-- actual time=0.123..0.125 (실제 시간)
-- rows=1 (예상 행 수)
-- Buffers: shared hit=3 (메모리 사용량)

```

---

## 💡 실무 선택 가이드

### 🎯 MySQL이 유리한 경우
- 웹 애플리케이션 (블로그, 전자상거래)
- 단순 CRUD 작업이 주된 경우
- 빠른 개발과 배포 필요
- 공유 호스팅 환경
- 제한된 메모리 환경 환경

### 🎯 PostgreSQL이 유리한 경우
- 복잡한 비지니스 로직 (ERP, CRM) 
- 데이터 분석 및 리포팅
- 고급 JSON 처리
- 고급 SQL 기능 필요
- 데이터 무결성이 중요한 금융/회계 시스템 