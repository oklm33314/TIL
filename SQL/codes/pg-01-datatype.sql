-- pg-01-datatype.sql
CREATE TABLE datatype_demo(
	-- mysql 에도 있음. 이름이 다를 수는 있다.
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	age INTEGER,
	salary NUMERIC(12, 2),
	is_active BOOLEAN DEFAULT TRUE,
	created_at TIMESTAMP DEFAULT NOW(),
	-- postgresql 특화 타입
	tags TEXT[],    -- 배열
	metadata JSONB,  -- JSONB JSON binary 타입
	ip_address INET, -- IP 주소 저장 전용
	location POINT,  -- 기하학 점(x, y)
	salary_range INT4RANGE -- 범위
);

SELECT * FROM datatype_demo;