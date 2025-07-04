05-basic
진도: lec 20~21, p09

# 🎯 오늘 배운 핵심 내용

- **UNION**: 여러 쿼리 결과 합치기  
- **서브쿼리 반환 유형**: 스칼라, 벡터, 매트릭스  
- **Inline View & View**: 쿼리 재사용과 가상 테이블  
- **SQL 작성 주의사항**: JOIN, GROUP BY 등 실수 방지

---

## 🔗 1. UNION - 여러 쿼리 결과 합치기

### 💡 UNION의 개념
여러 SELECT 쿼리의 결과를 세로로(행 방향) 합치는 기능

```sql
-- 기본 UNION 사용법
SELECT '고객 테이블' AS 구분, COUNT(*) AS 데이터수 FROM customers
UNION ALL
SELECT '매출 테이블' AS 구분, COUNT(*) AS 데이터수 FROM sales;

-- UNION vs UNION ALL
SELECT customer_type FROM customers  -- 중복 제거
UNION
SELECT customer_type FROM customers;

SELECT customer_type FROM customers  -- 중복 포함
UNION ALL
SELECT customer_type FROM customers;
```

### 🎯 UNION 실전 활용: 통합 리포트 만들기

```sql
-- 카테고리별 + 고객유형별 통합 분석
SELECT
    '카테고리별' AS 분석유형,
    category AS 구분,
    COUNT(*) AS 건수,
    SUM(total_amount) AS 총액
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY category

UNION ALL

SELECT
    '고객유형별' AS 분석유형,
    customer_type AS 구분,
    COUNT(*) AS 건수,
    SUM(total_amount) AS 총액
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY customer_type

ORDER BY 분석유형, 총액 DESC;
```

### ⚠️ UNION 주의사항

- 컬럼 수 일치: 모든 SELECT문의 컬럼 개수가 같아야 함  
- 데이터 타입 호환: 같은 위치의 컬럼은 데이터 타입이 호환되어야 함  
- 컬럼명: 첫 번째 SELECT문의 컬럼명이 최종 결과에 사용됨

---

## 📊 2. 서브쿼리 반환 유형

### 🔢 스칼라 (Scalar) 서브쿼리 (1행 1열)

```sql
SELECT
    product_name,
    total_amount,
    (SELECT AVG(total_amount) FROM sales) AS 전체평균,
    total_amount - (SELECT AVG(total_amount) FROM sales) AS 평균차이
FROM sales
WHERE total_amount > (SELECT AVG(total_amount) FROM sales);
```

### 📋 복수행 벡터 (Vector) 서브쿼리 (여러 행, 1열)

```sql
-- VIP 고객들의 주문 내역
SELECT * FROM sales
WHERE customer_id IN (
    SELECT customer_id FROM customers WHERE customer_type = 'VIP'
);

-- 전자제품 구매 고객
SELECT * FROM sales
WHERE customer_id IN (
    SELECT DISTINCT customer_id FROM sales WHERE category = '전자제품'
);
```

### 📋 매트릭스 (Matrix) 서브쿼리 (Inline View) 
여러 행, 여러 열 반환 주로 EXISTS나 FROM

```sql
SELECT c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT s.customer_id, s.product_name, s.total_amount
    FROM sales s
    WHERE s.customer_id = c.customer_id
    AND s.total_amount >= 1000000
);
```

### 🎯 서브쿼리 유형 요약

| 유형     | 반환값     | 사용 위치        | 연산자        | 예시                                 |
|----------|------------|------------------|----------------|--------------------------------------|
| 스칼라   | 1행 1열    | SELECT, WHERE    | =, >, <        | `WHERE amount > (SELECT AVG...)`    |
| 벡터     | 여러 행 1열| WHERE, HAVING    | IN, ANY, ALL   | `WHERE id IN (SELECT...)`           |
| 매트릭스 | 여러 행 여러 열 | FROM, EXISTS | EXISTS         | `WHERE EXISTS (SELECT...)`          |

---

## 📋 3. Inline View & View

### 💡 Inline View
FROM절에 사용되는 서브쿼리 = 임시테이블

```sql
SELECT *
FROM (
    SELECT
        category,
        AVG(total_amount) AS 평균매출,
        COUNT(*) AS 주문건수
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY category
) AS category_stats
WHERE 평균매출 >= 500000;

-- 복잡한 고객 분석
SELECT
    고객상태,
    COUNT(*) AS 고객수,
    AVG(총매출액) AS 평균매출액
FROM (
    SELECT
        c.customer_name,
        SUM(s.total_amount) AS 총매출액,
        CASE
            WHEN MAX(s.order_date) IS NULL THEN '미구매'
            WHEN DATEDIFF(CURDATE(), MAX(s.order_date)) <= 30 THEN '활성'
            ELSE '휴면'
        END AS 고객상태
    FROM customers c
    LEFT JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.customer_name
) AS customer_analysis
GROUP BY 고객상태;
```

### 📋 View (뷰)
복잡한 쿼리를 재사용 가능한 가상 테이블로 저장

```sql
-- View 생성
CREATE VIEW customer_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS 주문횟수,
    COALESCE(SUM(s.total_amount), 0) AS 총구매액,
    COALESCE(AVG(s.total_amount), 0) AS 평균주문액
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type;

-- 사용
SELECT * FROM customer_summary WHERE 주문횟수 >= 5;
SELECT * FROM customer_summary WHERE customer_type = 'VIP';

-- 삭제
DROP VIEW customer_summary;
```

### 🔄 Inline View vs View 비교

| 항목       | Inline View       | View                   |
|------------|-------------------|------------------------|
| 저장 여부  | 일회용             | DB에 저장              |
| 재사용     | 불가능             | 가능                   |
| 성능       | 매번 실행          | 미리 정의 후 재사용     |
| 사용 용도  | 복잡한 일회성 쿼리 | 자주 사용하는 복잡 쿼리 |

---

## ⚠️ 4. SQL 작성 주의사항

### 🔗 JOIN 관련

```sql
#### 1️⃣ 별명(Alias) 필수 사용
-- ❌ 잘못된 예
SELECT customer_name, product_name
FROM customers
JOIN sales ON customer_id = customer_id;

-- ✅ 올바른 예
SELECT c.customer_name, s.product_name
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id;

#### 2️⃣ JOIN 조건 누락 방지 
-- ❌ 조건 없는 JOIN → 카르테시안 곱
SELECT c.customer_name, s.product_name
FROM customers c, sales s;

-- ✅ 명시적 JOIN
SELECT c.customer_name, s.product_name
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id;

#### 3️⃣ LEFT JOIN에서 COUNT 주의
-- ❌ 잘못된 COUNT
SELECT c.customer_name, COUNT(*) AS 주문횟수
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name;

-- ✅ COUNT 시 특정 컬럼 지정
SELECT c.customer_name, COUNT(s.id) AS 주문횟수
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name;
```

### 📊 GROUP BY 관련 주의 사항

#### 1.SELECT 컬럼은 모두 GROUP BY에 포함
```sql
-- ❌ 오류: GROUP BY 누락
SELECT customer_name, customer_type, COUNT(*)
FROM customers
GROUP BY customer_name;

-- ✅ 올바른 방법 (GROUP BY 전체 컬럼 포함)
SELECT customer_name, customer_type, COUNT(*)
FROM customers
GROUP BY customer_name, customer_type;
```
#### 2.HAVIN vs WHERE 구분 
```sql
-- WHERE: 그룹 전 조건
SELECT customer_type, COUNT(*)
FROM customers
WHERE join_date >= '2024-01-01'
GROUP BY customer_type;

-- HAVING: 그룹 후 조건
SELECT customer_type, COUNT(*)
FROM customers
GROUP BY customer_type
HAVING COUNT(*) >= 10;
```

### 🔄 서브쿼리 주의사항

####  1. 스칼라 서브퀴리는 단일 값만 
```sql
-- ❌ 오류: 스칼라 서브쿼리에 다중 행 반환
SELECT product_name, (SELECT customer_id FROM sales)
FROM products;

-- ✅ 단일 값 반환으로 수정
SELECT product_name, (SELECT COUNT(*) FROM sales WHERE product_name = p.product_name)
FROM products p;
```
#### 2. NULL 처리
```sql
-- LEFT JOIN에서 NULL 처리
SELECT
    c.customer_name,
    COALESCE(SUM(s.total_amount), 0) AS 총구매액,
    COALESCE(MAX(s.order_date), '주문없음') AS 최근주문일
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name;
```

---

## 💡 핵심 패턴 정리

### 🎯 문제 해결 접근법

- 문제를 단계별로 분해하기  
- 인라인 뷰로 복잡한 집계 후 필터링  
- INNER / LEFT JOIN 적절히 선택  
- NULL 값 처리 항상 고려  

### 📝 SQL 작성 체크리스트

- [ ] 테이블 별명(Alias) 사용했는가?  
- [ ] JOIN 조건을 정확히 걸었는가?  
- [ ] GROUP BY 컬럼 모두 포함했는가?  
- [ ] LEFT JOIN에서 COUNT(특정 컬럼) 사용했는가?  
- [ ] NULL 값 처리했는가?  
- [ ] 서브쿼리 반환 유형이 올바른가?  
