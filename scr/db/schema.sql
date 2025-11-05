-- src/db/schema.sql
-- Esquema mínimo y claro para iniciar
-- Catálogo de tiendas
DROP TABLE IF EXISTS public.tiendas CASCADE;
CREATE TABLE public.tiendas (
  id_tienda INTEGER PRIMARY KEY,   -- identificador único
  nombre    TEXT NOT NULL,         -- etiqueta legible
  region    TEXT NOT NULL,         -- zona para agregaciones
  lat       DOUBLE PRECISION,      -- coordenadas (opcional)
  lon       DOUBLE PRECISION
);

-- Hechos de ventas diarias
DROP TABLE IF EXISTS public.ventas CASCADE;
CREATE TABLE public.ventas (
  fecha     DATE NOT NULL,         -- día
  id_tienda INTEGER NOT NULL,      -- tienda
  sku       TEXT NOT NULL,         -- producto
  unidades  INTEGER NOT NULL,      -- cantidad vendida
  ingresos  NUMERIC(12,2) NOT NULL -- monto total del día-producto
);

-- Índices simples (aceleran filtros y joins frecuentes)
CREATE INDEX IF NOT EXISTS idx_ventas_fecha  ON public.ventas(fecha);
CREATE INDEX IF NOT EXISTS idx_ventas_tienda ON public.ventas(id_tienda);

