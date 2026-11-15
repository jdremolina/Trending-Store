-- ============================================================
-- Trending Store · Inventario
-- Pega TODO este archivo en Supabase → SQL Editor → New query → Run
-- Se puede ejecutar más de una vez sin dañar nada.
-- ============================================================

-- 1) Tabla única donde la app guarda lotes, ventas, caja y ajustes
create table if not exists public.docs (
  collection text not null,               -- 'lotes' | 'ventas' | 'caja' | 'config'
  id         text not null,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by uuid default auth.uid(),
  primary key (collection, id)
);

-- 2) Seguridad: solo usuarios con sesión iniciada pueden ver y editar
alter table public.docs enable row level security;

drop policy if exists "equipo_lee"    on public.docs;
drop policy if exists "equipo_crea"   on public.docs;
drop policy if exists "equipo_edita"  on public.docs;
drop policy if exists "equipo_borra"  on public.docs;
create policy "equipo_lee"   on public.docs for select to authenticated using (true);
create policy "equipo_crea"  on public.docs for insert to authenticated with check (true);
create policy "equipo_edita" on public.docs for update to authenticated using (true) with check (true);
create policy "equipo_borra" on public.docs for delete to authenticated using (true);

revoke all on public.docs from anon;
grant select, insert, update, delete on public.docs to authenticated;

-- 3) Tiempo real: que los cambios lleguen al instante a todos los dispositivos
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'docs'
  ) then
    alter publication supabase_realtime add table public.docs;
  end if;
end $$;

-- 4) Fotos de las prendas
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('fotos', 'fotos', true, 10485760, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = true;

drop policy if exists "fotos_subir"  on storage.objects;
drop policy if exists "fotos_borrar" on storage.objects;
drop policy if exists "fotos_ver"    on storage.objects;
create policy "fotos_subir"  on storage.objects for insert to authenticated with check (bucket_id = 'fotos');
create policy "fotos_borrar" on storage.objects for delete to authenticated using (bucket_id = 'fotos');
create policy "fotos_ver"    on storage.objects for select using (bucket_id = 'fotos');

-- 5) Datos del negocio para las facturas y valores por defecto
insert into public.docs (collection, id, data)
values ('config', 'general', jsonb_build_object(
  'negocio', 'Trending Store',
  'ciudad', 'Caucasia, Antioquia',
  'whatsapp', '+57 323 5734815',
  'instagram', '@trendingstore_____',
  'nit', '',
  'dolar', 4000,
  'impPct', 7,
  'aumento', 130000,
  'facturaInicial', 1,
  'cajaInicial', 0
))
on conflict (collection, id) do nothing;
