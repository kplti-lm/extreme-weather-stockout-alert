-- src/db/schema.sql
-- Minimal and clear starter schema

-- Store catalog
DROP TABLE IF EXISTS public.stores CASCADE;
CREATE TABLE public.stores (
  store_id INTEGER PRIMARY KEY,     -- unique identifier
  name     TEXT NOT NULL,           -- human-readable store label
  region   TEXT NOT NULL,           -- quadrant classification (NE/NW/SE/SW)
  lat      DOUBLE PRECISION,        -- latitude (optional)
  lon      DOUBLE PRECISION         -- longitude (optional)
);

-- Daily sales facts
DROP TABLE IF EXISTS public.sales CASCADE;
CREATE TABLE public.sales (
  date      DATE NOT NULL,          -- calendar date
  store_id  INTEGER NOT NULL,       -- store reference
  sku       TEXT NOT NULL,          -- product code
  units     INTEGER NOT NULL,       -- units sold
  revenue   NUMERIC(12,2) NOT NULL  -- total revenue for date × store × sku (income)
);

-- Basic indexes to improve common filtering and joins
CREATE INDEX IF NOT EXISTS idx_sales_date   ON public.sales(date);
CREATE INDEX IF NOT EXISTS idx_sales_store  ON public.sales(store_id);

