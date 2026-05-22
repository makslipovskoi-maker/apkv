-- Выезды гостей санатория
-- Backend: Supabase/PostgreSQL. Выполните этот файл в Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  pin text not null unique,
  role text not null check (role in ('registrar', 'corps', 'driver', 'mechanic', 'manager')),
  name text not null,
  corps text,
  driver_name text,
  vehicle text,
  phone text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.vehicles (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  capacity integer not null default 0,
  description text,
  active boolean not null default true
);

create table if not exists public.drivers (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  phone text,
  vehicle text references public.vehicles(name) on update cascade,
  active boolean not null default true
);

create table if not exists public.requests (
  id uuid primary key default gen_random_uuid(),
  corps text not null,
  room text not null,
  guest_name text not null,
  people_count integer not null check (people_count > 0),
  baggage text,
  departure_date date not null,
  direction text not null,
  destination text,
  ticket_time time,
  transfer_needed boolean not null default true,
  comment text,
  status text not null default 'Новая заявка',
  created_by uuid references public.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  trip_code text unique,
  request_id uuid references public.requests(id) on delete set null,
  departure_date date not null,
  vehicle_time time,
  recommended_time time,
  corps text not null,
  room text not null,
  guest_name text not null,
  people_count integer not null check (people_count > 0),
  baggage text,
  direction text not null,
  destination text,
  ticket_time time,
  vehicle text references public.vehicles(name) on update cascade,
  driver_name text references public.drivers(name) on update cascade,
  driver_phone text,
  status text not null default 'В расписании',
  driver_confirmed_at timestamptz,
  mechanic_confirmed_at timestamptz,
  comment text,
  problem text,
  created_by uuid references public.users(id),
  updated_by uuid references public.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.changes (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references public.trips(id) on delete set null,
  request_id uuid references public.requests(id) on delete set null,
  corps text,
  room text,
  guest_name text,
  field_changed text not null,
  old_value text,
  new_value text,
  reason text,
  urgency text not null default 'обычное',
  created_by uuid references public.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.mechanic_status (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  vehicle text not null references public.vehicles(name) on update cascade,
  status text not null check (status in ('ГОТОВА', 'НЕ ГОТОВА', 'НУЖНА ЗАМЕНА', 'ПРОБЛЕМА')),
  comment text,
  confirmed_by uuid references public.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.action_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id),
  user_name text,
  role text,
  trip_id uuid references public.trips(id) on delete set null,
  action text not null,
  old_value text,
  new_value text,
  reason text,
  urgency text,
  created_at timestamptz not null default now()
);

create index if not exists idx_requests_departure_date on public.requests(departure_date);
create index if not exists idx_requests_corps on public.requests(corps);
create index if not exists idx_trips_departure_date on public.trips(departure_date);
create index if not exists idx_trips_driver_name on public.trips(driver_name);
create index if not exists idx_trips_status on public.trips(status);
create index if not exists idx_action_log_created_at on public.action_log(created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_trips_updated_at on public.trips;
create trigger trg_trips_updated_at
before update on public.trips
for each row execute function public.set_updated_at();

create or replace function public.set_trip_code()
returns trigger
language plpgsql
as $$
declare
  base_code text;
  next_number integer;
begin
  if new.trip_code is null or length(trim(new.trip_code)) = 0 then
    lock table public.trips in share row exclusive mode;
    base_code := to_char(new.departure_date, 'DD-MM');
    select coalesce(max(nullif(split_part(trip_code, '-', 3), '')::integer), 0) + 1
      into next_number
      from public.trips
      where departure_date = new.departure_date
        and trip_code like base_code || '-%';
    new.trip_code := base_code || '-' || lpad(next_number::text, 2, '0');
  end if;
  return new;
end;
$$;

drop trigger if exists trg_set_trip_code on public.trips;
create trigger trg_set_trip_code
before insert on public.trips
for each row execute function public.set_trip_code();

create or replace function public.login_by_pin(p_pin text)
returns table (
  id uuid,
  pin text,
  role text,
  name text,
  corps text,
  driver_name text,
  vehicle text,
  phone text,
  active boolean,
  created_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select id, pin, role, name, corps, driver_name, vehicle, phone, active, created_at
  from public.users
  where pin = p_pin and active = true
  limit 1;
$$;

grant usage on schema public to anon, authenticated;
grant select, insert, update on public.users to anon, authenticated;
grant select, insert, update on public.requests to anon, authenticated;
grant select, insert, update on public.trips to anon, authenticated;
grant select, insert, update on public.changes to anon, authenticated;
grant select, insert, update on public.mechanic_status to anon, authenticated;
grant select, insert, update on public.action_log to anon, authenticated;
grant select, insert, update on public.vehicles to anon, authenticated;
grant select, insert, update on public.drivers to anon, authenticated;
grant execute on function public.login_by_pin(text) to anon, authenticated;

alter table public.users enable row level security;
alter table public.requests enable row level security;
alter table public.trips enable row level security;
alter table public.changes enable row level security;
alter table public.mechanic_status enable row level security;
alter table public.action_log enable row level security;
alter table public.vehicles enable row level security;
alter table public.drivers enable row level security;

do $$
declare
  t text;
begin
  foreach t in array array['users','requests','trips','changes','mechanic_status','action_log','vehicles','drivers']
  loop
    execute format('drop policy if exists "anon_select_%s" on public.%I', t, t);
    execute format('create policy "anon_select_%s" on public.%I for select to anon, authenticated using (true)', t, t);
    execute format('drop policy if exists "anon_insert_%s" on public.%I', t, t);
    execute format('create policy "anon_insert_%s" on public.%I for insert to anon, authenticated with check (true)', t, t);
    execute format('drop policy if exists "anon_update_%s" on public.%I', t, t);
    execute format('create policy "anon_update_%s" on public.%I for update to anon, authenticated using (true) with check (true)', t, t);
  end loop;
end $$;

comment on table public.users is 'Пользователи приложения. PIN-коды можно менять в этой таблице.';
comment on table public.trips is 'Главный график выездов. Актуальным считается только график в приложении.';
