
# 📘 SQL 함수 & 실전 쿼리 정리

# 몰랐던 거


## ✅ WHERE / GROUP BY / HAVING / ORDER BY 핵심 차이 요약표

| 구문       | 역할/목적                             | 사용하는 위치       | 예시 대상                       |
|------------|----------------------------------------|----------------------|----------------------------------|
| `WHERE`    | 행(데이터)을 미리 필터링                | `SELECT` 전에        | `price > 1000`, `region = '서울'` |
| `GROUP BY` | 특정 기준으로 데이터를 묶음             | `WHERE` 다음         | `GROUP BY region`               |
| `HAVING`   | 그룹핑된 데이터에 조건 필터링           | `GROUP BY` 다음      | `HAVING COUNT(*) > 5`           |
| `ORDER BY` | 결과 정렬 (오름차순/내림차순)           | 전체 쿼리 마지막     | `ORDER BY price DESC`           |

# 📘 SQL 핵심 개념 정리

---

## ✅ SUBQUERY(서브쿼리)란?

> SELECT, FROM, WHERE 등의 절 안에 포함된 또 다른 SELECT문

즉, 쿼리 안에 들어가는 **작은 쿼리**예요.  
일반 쿼리가 결과를 바로 반환하는 것과 달리, 서브쿼리는 **중간 계산 결과를 제공**하는 용도입니다.

---

## ✅ FROM vs WHERE 차이

| 항목   | FROM                             | WHERE                                               |
|--------|----------------------------------|------------------------------------------------------|
| 역할   | 어디서 데이터를 가져올지 지정        | 가져온 데이터 중 어떤 행을 고를지 조건 걸기                   |
| 위치   | SELECT 바로 다음                  | FROM 다음                                           |
| 예시   | FROM sales                        | WHERE total_amount > 10000                         |
| 대상   | 테이블이나 서브쿼리                 | 각 행(row)                                          |
| 관계   | 데이터의 출처를 정함                | 출처에서 어떤 데이터만 쓸지 **필터링**함                   |

---

## ✅ FROM 위치

- `FROM`은 항상 `SELECT` 다음에 위치합니다.
- 단, `SELECT`가 길거나 복잡한 표현식을 포함하면 **코드상 아래로 밀릴 수 있어요**.

---

## ❌ WHERE SELECT MAX(...)처럼 쓰는 건 문법적으로 틀립니다.

### ✅ 왜 안 되는가?

SQL의 `WHERE` 절에는 반드시 **"조건"**을 줘야 해요.  
즉, **참(True) 또는 거짓(False)**이 되는 **비교문 또는 조건식**이 나와야 합니다.

---

### ✅ 올바른 형태

```sql
SELECT * 
FROM sales
WHERE order_date = (SELECT MAX(order_date) FROM sales);
```

- `(SELECT MAX(order_date) FROM sales)`가 **하나의 값** (예: `'2024-06-29'`)을 반환하고,
- 그걸 `order_date = ...` 비교문에서 사용하므로 문법적으로 맞습니다.

---

### ❌ 잘못된 형태

```sql
SELECT * 
FROM sales
WHERE SELECT MAX(order_date) FROM sales;
```

- `WHERE` 다음에 **비교식 없이 SELECT문만 단독으로 존재**해서 SQL이 이해를 못 해요.

> 💬 마치 이렇게 말하는 것과 같아요:  
> "어디서 주문했는지 알려줘. 아, 그냥 '가장 큰 날짜'라고만 말할게!"  
> → **비교 없이 단독 SELECT문은 조건이 아님!**

---

## 🧠 기억 포인트

- `SELECT`는 단독으로 `WHERE` 안에 들어갈 수 없습니다.
- 반드시 **비교 연산자와 함께 써야** 합니다.  
  예: `=`, `>`, `<`, `IN`, `EXISTS` 등

---



# 수업내용

### 1️⃣ 종합 통계 대시보드

```sql
SELECT
    COUNT(*) AS 총주문건수,
    COUNT(DISTINCT customer_id) AS 총고객수,
    SUM(total_amount) AS 총매출액,
    AVG(total_amount) AS 평균주문액,
    MAX(total_amount) AS 최대주문액
FROM sales;
```
중복제거 : SELECT DISTINCT city FROM users;
---

### 2️⃣ 월별 매출 트렌드

```sql
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS 월,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 월매출액
FROM sales
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY 월;
```

---

### 3️⃣ 우수 고객/영업사원 찾기

```sql
-- 월평균 매출 50만원 이상 영업사원
SELECT
    sales_rep,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 총매출,
    ROUND(SUM(total_amount) / COUNT(DISTINCT DATE_FORMAT(order_date, '%Y-%m')), 0) AS 월평균매출
FROM sales
GROUP BY sales_rep
HAVING 월평균매출 >= 500000
ORDER BY 월평균매출 DESC;
```

---

### 4️⃣ 교차분석 (크로스탭)

```sql
-- 지역별 카테고리 매출 분포
SELECT
    region,
    SUM(CASE WHEN category = '전자제품' THEN total_amount ELSE 0 END) AS 전자제품,
    SUM(CASE WHEN category = '의류' THEN total_amount ELSE 0 END) AS 의류,
    SUM(CASE WHEN category = '생활용품' THEN total_amount ELSE 0 END) AS 생활용품,
    SUM(CASE WHEN category = '식품' THEN total_amount ELSE 0 END) AS 식품
FROM sales
GROUP BY region;
```
