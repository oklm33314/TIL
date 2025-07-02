
# 📘 SQL 함수 & 실전 쿼리 정리

---

## 1️⃣ 날짜/시간 함수

| 함수 | 용도 | 예시 |
|------|------|------|
| `NOW()` | 현재 날짜+시간 | `SELECT NOW();` |
| `CURDATE()` | 현재 날짜만 | `SELECT CURDATE();` |
| `DATE_FORMAT()` | 날짜 형식 변환 | `DATE_FORMAT(birth, '%Y년 %m월')` |
| `DATEDIFF()` | 날짜 간 일수 차이 | `DATEDIFF(CURDATE(), birth)` |
| `TIMESTAMPDIFF()` | 기간 단위별 차이 | `TIMESTAMPDIFF(YEAR, birth, CURDATE())` |
| `DATE_ADD()` | 날짜 더하기 | `DATE_ADD(birth, INTERVAL 1 YEAR)` |
| `YEAR(), MONTH(), DAY()` | 날짜 요소 추출 | `YEAR(birth), MONTH(birth)` |

> 🔹 **핵심 FORMAT 기호**: `%Y`(년도), `%m`(월), `%d`(일), `%H`(시간), `%i`(분)

---

## 2️⃣ 숫자 함수

| 함수 | 용도 | 예시 |
|------|------|------|
| `ROUND()` | 반올림 | `ROUND(score, 1)` |
| `CEIL()` | 올림 | `CEIL(score)` |
| `FLOOR()` | 내림 | `FLOOR(score)` |
| `ABS()` | 절댓값 | `ABS(score - 80)` |
| `MOD()` | 나머지 | `MOD(id, 2)` |
| `POWER()` | 거듭제곱 | `POWER(score, 2)` |
| `SQRT()` | 제곱근 | `SQRT(score)` |

---

## 3️⃣ 조건부 함수

| 함수 | 용도 | 예시 |
|------|------|------|
| `IF()` | 단순 조건 | `IF(score >= 80, '우수', '보통')` |
| `CASE WHEN` | 다중 조건 | `CASE WHEN score >= 90 THEN 'A' ELSE 'B' END` |
| `IFNULL()` | NULL 처리 | `IFNULL(nickname, '미설정')` |
| `COALESCE()` | 첫 번째 NULL 아닌 값 | `COALESCE(nickname, name, 'Unknown')` |

---

## 4️⃣ 집계 함수 = 스프레드시트 함수

| SQL 집계함수 | 스프레드시트 함수 | 용도 |
|--------------|------------------|------|
| `COUNT(*)` | `=COUNT()` | 행 개수 세기 |
| `SUM()`     | `=SUM()`   | 합계 |
| `AVG()`     | `=AVERAGE()` | 평균 |
| `MIN()`     | `=MIN()`   | 최솟값 |
| `MAX()`     | `=MAX()`   | 최댓값 |

---

## 5️⃣ GROUP BY = 스프레드시트 피벗테이블

```sql
-- 카테고리별 매출 (피벗테이블의 행=카테고리, 값=매출합계)
SELECT
    category,                 -- 피벗테이블의 "행" 영역
    COUNT(*) AS 건수,         -- 피벗테이블의 "값" 영역
    SUM(total_amount) AS 매출액
FROM sales
GROUP BY category            -- 그룹핑 기준
ORDER BY 매출액 DESC;        -- 정렬
```

---

## 6️⃣ HAVING = 피벗테이블 필터

```sql
-- 매출 100만원 이상인 카테고리만 (피벗테이블 결과에 필터)
SELECT category, SUM(total_amount) AS 총매출
FROM sales
GROUP BY category
HAVING SUM(total_amount) >= 1000000;
```

| 구문 | 조건 시점 |
|------|-----------|
| `WHERE` | 개별 행 기준 (그룹핑 전) |
| `HAVING` | 그룹 결과 기준 (그룹핑 후) |

## ✅ WHERE vs HAVING 핵심 차이

| 구문   | 언제 쓰는가?                            | 예시 역할                        |
|--------|------------------------------------------|----------------------------------|
| `WHERE` | 그룹핑 전에, 행 하나하나를 조건으로 걸러냄 | 피벗 만들기 전 필터               |
| `HAVING`| `GROUP BY`로 묶은 뒤, 집계된 결과에 필터 적용 | 피벗 만들고 나서 값 필터 넣는 것 |

---

# 🔥 핵심 실전 쿼리 패턴

---

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
