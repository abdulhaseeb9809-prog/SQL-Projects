Drop database if exists pizza_runner;

CREATE database pizza_runner;
use pizza_runner;

-- =====================
-- RUNNERS
-- =====================
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id int,
  registration_date DATE
);

-- =====================
-- CUSTOMER ORDERS
-- =====================
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id int,
  customer_id int,
  pizza_id int,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

-- =====================
-- RUNNER ORDERS
-- =====================
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time datetime,
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

-- =====================
-- PIZZA NAMES
-- =====================
DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);

-- =====================
-- PIZZA RECIPES
-- =====================
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

-- =====================
-- PIZZA TOPPINGS
-- =====================
DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

