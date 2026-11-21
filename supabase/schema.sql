-- MachineShop database setup (run once in the Supabase SQL Editor on a new project)
-- Also in the dashboard: Authentication > Providers > Email > turn OFF "Allow new users to sign up".

-- ========== TABLES ==========
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null check (role in ('admin','secretary','worker'))
);

create table specialties (
  id serial primary key,
  name text unique not null
);

create table worker_specialties (
  worker_id uuid references profiles(id) on delete cascade,
  specialty_id int references specialties(id) on delete cascade,
  primary key (worker_id, specialty_id)
);

create table job_orders (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  customer_phone text,
  description text,
  price numeric(10,2),
  photo_path text,
  status text not null default 'pending'
    check (status in ('pending','in_progress','done')),
  created_by uuid references profiles(id),
  created_at timestamptz default now(),
  completed_at timestamptz
);

create table job_tasks (
  id uuid primary key default gen_random_uuid(),
  job_order_id uuid not null references job_orders(id) on delete cascade,
  specialty_id int not null references specialties(id),
  assigned_to uuid not null references profiles(id),
  notes text,
  status text not null default 'pending'
    check (status in ('pending','in_progress','done')),
  completed_at timestamptz,
  created_at timestamptz default now()
);

insert into specialties (name) values
  ('Reboring'), ('Resurfacing'), ('Torno'), ('Welding');

-- ========== HELPER ==========
create function current_role_name() returns text
language sql stable security definer as $$
  select role from profiles where id = auth.uid()
$$;

-- ========== SECURITY (ROW LEVEL SECURITY) ==========
alter table profiles enable row level security;
alter table specialties enable row level security;
alter table worker_specialties enable row level security;
alter table job_orders enable row level security;
alter table job_tasks enable row level security;

create policy "read profiles" on profiles
  for select to authenticated using (true);
create policy "read specialties" on specialties
  for select to authenticated using (true);
create policy "read worker specialties" on worker_specialties
  for select to authenticated using (true);

create policy "secretary full access jobs" on job_orders
  for all to authenticated
  using (current_role_name() in ('secretary','admin'))
  with check (current_role_name() in ('secretary','admin'));

create policy "worker reads jobs they have tasks in" on job_orders
  for select to authenticated
  using (exists (
    select 1 from job_tasks t
    where t.job_order_id = job_orders.id and t.assigned_to = auth.uid()
  ));

create policy "secretary full access tasks" on job_tasks
  for all to authenticated
  using (current_role_name() in ('secretary','admin'))
  with check (current_role_name() in ('secretary','admin'));

create policy "worker sees own tasks" on job_tasks
  for select to authenticated using (assigned_to = auth.uid());

create policy "worker updates own tasks" on job_tasks
  for update to authenticated
  using (assigned_to = auth.uid())
  with check (assigned_to = auth.uid());

-- ========== A JOB IS DONE WHEN ALL ITS TASKS ARE DONE ==========
create function sync_job_status() returns trigger
language plpgsql security definer as $$
declare all_done boolean;
begin
  select not exists (
    select 1 from job_tasks
    where job_order_id = new.job_order_id and status <> 'done'
  ) into all_done;

  update job_orders
  set status = case when all_done then 'done' else 'in_progress' end,
      completed_at = case when all_done then now() else null end
  where id = new.job_order_id;

  return new;
end $$;

create trigger task_status_sync
after update of status on job_tasks
for each row execute function sync_job_status();

-- ========== LIVE UPDATES ==========
alter publication supabase_realtime add table job_orders, job_tasks;

-- ========== PHOTO STORAGE ==========
insert into storage.buckets (id, name, public)
values ('job-photos', 'job-photos', false)
on conflict do nothing;

create policy "secretary uploads photos" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'job-photos'
              and current_role_name() in ('secretary','admin'));

create policy "logged in users read photos" on storage.objects
  for select to authenticated
  using (bucket_id = 'job-photos');

-- ========== CREATING AN ACCOUNT (done by the admin) ==========
-- 1. Authentication > Users > Add user (tick "Auto Confirm User").
-- 2. Then run, with that user's email:
--
--   insert into profiles (id, full_name, role)
--   select id, 'Juan Dela Cruz', 'worker' from auth.users where email = 'juan@example.com';
--
--   insert into worker_specialties (worker_id, specialty_id)
--   select u.id, s.id from auth.users u, specialties s
--   where u.email = 'juan@example.com' and s.name in ('Reboring', 'Welding');
