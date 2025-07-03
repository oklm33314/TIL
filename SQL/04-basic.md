 16~19 LEC, p08 -->16만 복습함


# 수업내용


# 🎯 오늘 배운 핵심 요약 - SQL 서브쿼리 & JOIN

---

## 🎯 오늘 배운 핵심 내용

- 서브쿼리 기초: 쿼리 안의 쿼리로 조건 만들기  
- JOIN 기초: 여러 테이블 연결하여 정보 합치기  
- GROUP BY + JOIN: 연결된 데이터를 그룹별로 집계하기  

---

## 🔍 1. 서브쿼리 (Subquery) - 쿼리 안의 쿼리

### 💡 서브쿼리란?
> 다른 쿼리의 결과를 조건이나 값으로 사용하는 쿼리

💬 일상 언어로: "평균보다 높은 매출의 주문들을 보여줘"

### 🧪 예제

```sql
-- 1단계: 평균 구하기
SELECT AVG(total_amount) FROM sales;  -- 결과: 612,862

-- 2단계: 평균보다 높은 주문 찾기
SELECT * FROM sales WHERE total_amount > 612862;

-- ✨ 서브쿼리로 한번에!
SELECT * FROM sales
WHERE total_amount > (SELECT AVG(total_amount) FROM sales);
```

---

### 🎯 서브쿼리 기본 패턴들

#### 1. 평균과 비교
```sql
SELECT
    product_name,
    total_amount,
    total_amount - (SELECT AVG(total_amount) FROM sales) AS 평균차이
FROM sales
WHERE total_amount > (SELECT AVG(total_amount) FROM sales);
```

#### 2. 최대/최소값 찾기
```sql
-- 가장 비싼 주문
SELECT * FROM sales
WHERE total_amount = (SELECT MAX(total_amount) FROM sales);

-- 가장 최근 주문들
SELECT * FROM sales
WHERE order_date = (SELECT MAX(order_date) FROM sales);
```

#### 3. 목록에 포함된 것들 (IN 사용)
```sql
-- VIP 고객들의 모든 주문
SELECT * FROM sales
WHERE customer_id IN (
    SELECT customer_id FROM customers
    WHERE customer_type = 'VIP'
)
ORDER BY total_amount DESC;

-- 전자제품을 구매한 적 있는 고객들의 모든 주문
SELECT * FROM sales
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM sales
    WHERE category = '전자제품'
);
```

### 💡 서브쿼리 핵심 포인트
- 괄호 필수: `(SELECT ...)`
- 단일 값 vs 여러 값: `=`는 단일 값, `IN`은 여러 값
- 실행 순서: 서브쿼리 먼저 → 외부 쿼리 나중

---

## 🔗 2. JOIN - 테이블 연결하기

### 💡 JOIN이 왜 필요한가?

```sql
-- 😨고객 이름과 주문 정보를 함께 보고 싶은데...
-- 서브쿼리 방식 (복잡하고 비효율적)
SELECT
    customer_id,
    product_name,
    total_amount,
    (SELECT customer_name FROM customers WHERE customer_id = s.customer_id) AS customer_name,
    (SELECT customer_type FROM customers WHERE customer_id = s.customer_id) AS customer_type
FROM sales s;

-- JOIN 방식 (간단하고 효율적) ➡️⭐해결책!!
SELECT
    c.customer_name,
    c.customer_type,
    s.product_name,
    s.total_amount
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id;
```

---

### 🎯 INNER JOIN vs LEFT JOIN

#### INNER JOIN = 교집합 (둘 다 있는 것만)

```sql
SELECT c.customer_name, s.product_name
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id;
```

#### LEFT JOIN = 왼쪽 기준 (왼쪽은 다 보여줌)

```sql
SELECT c.customer_name, s.product_name
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id;
```

---

### 🔧 JOIN 기본 문법

```sql
SELECT 컬럼들
FROM 테이블1 별명1
[INNER/LEFT] JOIN 테이블2 별명2
ON 연결조건
WHERE 추가조건;
```

---

### 🎯 JOIN 실전 예시

#### 1. VIP 고객들의 구매 내역
```sql
SELECT
    c.customer_name,
    c.customer_type,
    s.product_name,
    s.total_amount
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
WHERE c.customer_type = 'VIP'
ORDER BY s.total_amount DESC;
```

#### 2. 주문 없는 잠재 고객 찾기
```sql
SELECT
    c.customer_name,
    c.customer_type,
    c.join_date
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
WHERE s.customer_id IS NULL;
```

---

## 📊 3. GROUP BY + JOIN - 연결된 데이터 집계하기

### 💡 GROUP BY + JOIN이 왜 필요한가?

💬 질문: "각 고객 유형별로 평균 구매금액이 얼마인가?"
--  → 고객 정보(customers) + 주문 정보(sales) 연결 + 그룹별 집계 필요

---

### 🎯 기본 패턴 예시

#### 1. 고객 유형별 평균 구매금액

```sql
SELECT
    c.customer_type AS 고객유형,
    COUNT(*) AS 주문건수,
    AVG(s.total_amount) AS 평균구매금액,
    SUM(s.total_amount) AS 총매출액
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_type
ORDER BY 평균구매금액 DESC;
```

#### 2. 모든 고객의 구매 현황

```sql
SELECT
    c.customer_name AS 고객명,
    c.customer_type AS 고객유형,
    COUNT(s.id) AS 주문횟수,
    COALESCE(SUM(s.total_amount), 0) AS 총구매액,
    COALESCE(AVG(s.total_amount), 0) AS 평균주문액,
    CASE
        WHEN COUNT(s.id) = 0 THEN '잠재고객'
        WHEN COUNT(s.id) >= 5 THEN '충성고객'
        ELSE '일반고객'
    END AS 고객분류
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type
ORDER BY 총구매액 DESC;
```

---

## 🚨 GROUP BY + JOIN 주의사항

### 1. GROUP BY에 포함할 컬럼들

```sql
-- ❌ 오류 예시
SELECT c.customer_name, COUNT(*)
FROM customers c JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id;  -- customer_name 빠짐

-- ✅ 올바른 형태
SELECT c.customer_name, COUNT(*)
FROM customers c JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name;
```

### 2. LEFT JOIN에서 COUNT 사용

```sql
-- ❌ 잘못된 예시 (NULL도 카운트됨)
SELECT c.customer_name, COUNT(*) AS 주문횟수
FROM customers c LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name;

-- ✅ 올바른 예시 (s.id만 카운트)
SELECT c.customer_name, COUNT(s.id) AS 주문횟수
FROM customers c LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name;
```

### 3. NULL 값 처리

```sql
SELECT
    c.customer_name,
    COALESCE(SUM(s.total_amount), 0) AS 총구매액,
    COALESCE(MAX(s.order_date), '주문없음') AS 최근주문일
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name;
```

---

## 🎯 핵심 패턴 정리

### 1. 서브쿼리 패턴

| 상황         | 패턴                                 | 예시             |
|--------------|--------------------------------------|------------------|
| 평균과 비교    | `WHERE 컬럼 > (SELECT AVG...)`         | 평균보다 높은 매출 |
| 최대/최소 찾기 | `WHERE 컬럼 = (SELECT MAX...)`         | 최고 매출 주문    |
| 목록 포함      | `WHERE 컬럼 IN (SELECT...)`            | VIP 고객 주문들   |

### 2. JOIN 선택 기준

| 상황             | JOIN 종류     | 이유                        |
|------------------|---------------|-----------------------------|
| 실제 거래 고객만 분석 | INNER JOIN   | 양쪽에 데이터 있는 것만 사용 |
| 전체 고객 현황 파악   | LEFT JOIN    | 모든 고객 포함 필요          |

### 3. GROUP BY + JOIN 템플릿

```sql
SELECT
    그룹컬럼,
    COUNT(오른쪽테이블.id) AS 개수,
    COALESCE(SUM(숫자컬럼), 0) AS 합계,
    COALESCE(AVG(숫자컬럼), 0) AS 평균
FROM 왼쪽테이블 별명1
LEFT JOIN 오른쪽테이블 별명2 ON 연결조건
GROUP BY 그룹컬럼들
ORDER BY 정렬기준;
```

---

## 💡 자주 하는 실수들

### 1. 별명 안 쓰기

```sql
-- ❌ 실수
SELECT customer_name, product_name
FROM customers JOIN sales ON customer_id = customer_id;

-- ✅ 올바름
SELECT c.customer_name, s.product_name
FROM customers c JOIN sales s ON c.customer_id = s.customer_id;
```

### 2. GROUP BY 빼먹기

```sql
-- ❌ 실수
SELECT customer_name, COUNT(*) FROM customers;  -- 오류

-- ✅ 올바름
SELECT customer_name, COUNT(*) FROM sales GROUP BY customer_name;
```

### 3. LEFT JOIN에서 COUNT(*) 사용

```sql
-- ❌ 실수 (주문 없어도 1로 나옴)
SELECT c.customer_name, COUNT(*)
FROM customers c LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name;

-- ✅ 올바름 (s.id 기준으로 카운트)
SELECT c.customer_name, COUNT(s.id)
FROM customers c LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name;
```

---

## 🏠 복습 과제

1. 각 카테고리별 평균 매출보다 높은 주문들 (서브쿼리)  
2. 모든 고객의 주문 통계 (LEFT JOIN + GROUP BY)  
3. 주문 없는 고객들 찾기 (LEFT JOIN + WHERE NULL)  
4. VIP 고객들의 카테고리별 구매 패턴 (INNER JOIN + GROUP BY)  

---

