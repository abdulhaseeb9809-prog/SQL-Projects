CREATE database dannys_diner;
use dannys_diner;

CREATE TABLE sales ( -- creating sales table
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);


CREATE TABLE menu ( -- creating menu table
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);


CREATE TABLE members ( -- creating members table
  customer_id VARCHAR(1),
  join_date DATE
);