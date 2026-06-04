-- HomeServiceSV
-- 001_align_current_supabase_for_app.sql
-- Objetivo: alinear la base actual de Supabase con lo que la app Flutter espera.
-- Ejecutar manualmente en Supabase SQL Editor.

-- 1) Reseñas: la app maneja calificaciones bidireccionales.
-- La tabla actual tiene autor_id y tipo_resena; se agregan columnas compatibles
-- con el modelo usado por Flutter sin borrar datos existentes.
alter table public.resenas
  add column if not exists cliente_id uuid references public.perfiles(id) on delete set null,
  add column if not exists trabajador_id uuid references public.perfiles(id) on delete set null,
  add column if not exists emisor_id uuid references public.perfiles(id) on delete set null,
  add column if not exists tipo text,
  add column if not exists preguntas_rapidas text[];

-- Copia datos existentes cuando sea posible.
update public.resenas
set emisor_id = autor_id
where emisor_id is null
  and autor_id is not null;

update public.resenas
set tipo = tipo_resena
where tipo is null
  and tipo_resena is not null;

-- Valores por defecto seguros para nuevas reseñas.
alter table public.resenas
  alter column tipo set default 'cliente_a_trabajador';

-- 2) Solicitudes: la app usa estos campos en confirmación/tracking.
alter table public.solicitudes_servicio
  add column if not exists monto_acordado numeric,
  add column if not exists fecha_servicio timestamptz;

-- 3) Chats: opcional para limpieza futura de mensajes 7 días después.
-- La app ya fue ajustada para no depender de esta columna, pero dejarla ayuda
-- para automatización posterior.
alter table public.chats
  add column if not exists eliminar_mensajes_en timestamptz;

-- 4) Buckets de Storage requeridos por la app.
-- Si algún bucket ya existe, no se duplica.
insert into storage.buckets (id, name, public)
values
  ('perfil-fotos', 'perfil-fotos', true),
  ('dui-documentos', 'dui-documentos', false),
  ('antecedentes-documentos', 'antecedentes-documentos', false),
  ('solicitudes-imagenes', 'solicitudes-imagenes', true),
  ('chat-imagenes', 'chat-imagenes', true)
on conflict (id) do nothing;

-- Nota: si Supabase rechaza alguna policy de Storage al subir archivos,
-- el siguiente paso será crear políticas RLS específicas para cada bucket.
