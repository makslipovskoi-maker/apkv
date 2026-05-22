-- Стартовые данные. Запустите после 001_schema.sql.

insert into public.vehicles (name, capacity, description, active) values
  ('Автобус', 45, 'Для больших групп', true),
  ('Газель', 13, 'Для средних групп', true),
  ('Ларгус', 6, 'Для маленьких групп и срочных изменений', true)
on conflict (name) do update set
  capacity = excluded.capacity,
  description = excluded.description,
  active = excluded.active;

insert into public.drivers (name, phone, vehicle, active) values
  ('Павел', '+7 000 000-00-01', 'Газель', true),
  ('Виктор', '+7 000 000-00-02', 'Ларгус', true),
  ('Александр', '+7 000 000-00-03', 'Автобус', true)
on conflict (name) do update set
  phone = excluded.phone,
  vehicle = excluded.vehicle,
  active = excluded.active;

insert into public.users (pin, role, name, corps, driver_name, vehicle, phone, active) values
  ('1111', 'registrar', 'Регистратор', null, null, null, null, true),
  ('3001', 'corps', 'Администратор корпуса 1', 'Корпус 1', null, null, null, true),
  ('3002', 'corps', 'Администратор корпуса 2', 'Корпус 2', null, null, null, true),
  ('3003', 'corps', 'Администратор корпуса 3', 'Корпус 3', null, null, null, true),
  ('2101', 'driver', 'Павел', null, 'Павел', 'Газель', '+7 000 000-00-01', true),
  ('2102', 'driver', 'Виктор', null, 'Виктор', 'Ларгус', '+7 000 000-00-02', true),
  ('2103', 'driver', 'Александр', null, 'Александр', 'Автобус', '+7 000 000-00-03', true),
  ('5000', 'mechanic', 'Главный механик', null, null, null, null, true),
  ('9000', 'manager', 'Руководитель', null, null, null, null, true)
on conflict (pin) do update set
  role = excluded.role,
  name = excluded.name,
  corps = excluded.corps,
  driver_name = excluded.driver_name,
  vehicle = excluded.vehicle,
  phone = excluded.phone,
  active = excluded.active;
