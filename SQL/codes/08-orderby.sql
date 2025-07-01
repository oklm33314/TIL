-- 08-orderby.sql
USE lecture;
-- 특정 컬럼을 기준으로 정렬함
-- 	ASC 오름차순 | DESC 내림차순 

SELECT * FROM students;

-- 이름 ㄱㄴㄷ 순으로 정렬 -> Default(기본) 정렬 방식 = ASC
SELECT* FROM students ORDER BY name;
SELECT* FROM students ORDER BY name ASC; -- 위와 결과 동일
SELECT* FROM students ORDER BY name DESC; 

-- 테이블 구조(스키마) 변경 -> 컬럼 추가 -> grade VARCHAR (1) -> 기본값으로  'B'
ALTER TABLE students ADD COLUMN grade VARCHAR(1) DEFAULT 'B';-- 안됨
-- 데이터 수정
UPDATE students SET grade = 'A' WHERE id BETWEEN 1 AND 3;
UPDATE students SET grade = 'C' WHERE id BETWEEN 8 AND 10;


-- 나이가 40미만인 학생들 중에서 학점 순 - 나이 많은 순으로 상위 5명 뽑기 LIMIT 5;
SELECT * -- 조회
FROM students -- 테이블 정하기
WHERE age < 40 -- 조건 걸기
ORDER BY grade, age DESC -- 정렬하기
LIMIT 5; -- 갯수 제한


