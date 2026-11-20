-- ShopTrack online shop: run once in Supabase > SQL Editor > New query > Run.
-- Safe to run again.

create table if not exists public.shops (
  owner uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  name text not null,
  phone text,
  created_at timestamptz not null default now()
);

create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  owner uuid not null default auth.uid() references auth.users(id) on delete cascade,
  product_id uuid,
  name text not null,
  description text,
  price numeric not null default 0,
  in_stock boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists listings_owner_idx on public.listings(owner);

alter table public.shops enable row level security;
alter table public.listings enable row level security;

-- Anyone (customers, no login) can read shops and listings.
drop policy if exists "shops public read" on public.shops;
create policy "shops public read" on public.shops
  for select to anon, authenticated using (true);

drop policy if exists "listings public read" on public.listings;
create policy "listings public read" on public.listings
  for select to anon, authenticated using (true);

-- Only the owner can add, change or delete their own rows.
drop policy if exists "shops owner write" on public.shops;
create policy "shops owner write" on public.shops
  for all to authenticated
  using (owner = auth.uid()) with check (owner = auth.uid());

drop policy if exists "listings owner write" on public.listings;
create policy "listings owner write" on public.listings
  for all to authenticated
  using (owner = auth.uid()) with check (owner = auth.uid());

grant select on public.shops, public.listings to anon;
grant select, insert, update, delete on public.shops, public.listings to authenticated;
