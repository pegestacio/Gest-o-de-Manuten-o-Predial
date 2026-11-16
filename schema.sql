-- Gestão de Manutenção Predial — rode no SQL Editor do Supabase
create table public.perfis(
  id uuid primary key references auth.users on delete cascade,
  nome text not null,
  papel text not null default 'solicitante' check (papel in ('admin','gestor','solicitante','tecnico')));
create table public.chamados(
  id text primary key, num bigint, status text, prioridade text, categoria text, abertura bigint,
  solicitante_id uuid references auth.users, resp_id uuid references auth.users,
  doc jsonb not null default '{}', updated_at timestamptz default now());
create table public.materiais(id text primary key, doc jsonb not null default '{}');
create table public.config(id text primary key, doc jsonb not null default '{}');
insert into public.config values('sla','{"Urgente":4,"Alta":24,"Média":72,"Baixa":120}');

create or replace function public.papel() returns text language sql stable security definer set search_path=public as
$$ select papel from public.perfis where id=auth.uid() $$;
create or replace function public.novo_usuario() returns trigger language plpgsql security definer set search_path=public as
$$ begin insert into public.perfis(id,nome) values(new.id, split_part(new.email,'@',1)); return new; end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.novo_usuario();

alter table perfis enable row level security; alter table chamados enable row level security;
alter table materiais enable row level security; alter table config enable row level security;

create policy p_sel on perfis for select to authenticated using(true);
create policy p_upd on perfis for update to authenticated using(papel()='admin');

create policy c_sel on chamados for select to authenticated using(papel() in('admin','gestor') or solicitante_id=auth.uid() or resp_id=auth.uid());
create policy c_ins on chamados for insert to authenticated with check(solicitante_id=auth.uid());
create policy c_upd on chamados for update to authenticated using(papel() in('admin','gestor') or solicitante_id=auth.uid() or resp_id=auth.uid());
create policy c_del on chamados for delete to authenticated using(papel()='admin');

create policy m_sel on materiais for select to authenticated using(true);
create policy m_all on materiais for all to authenticated using(papel() in('admin','gestor')) with check(papel() in('admin','gestor'));
create policy g_sel on config for select to authenticated using(true);
create policy g_all on config for all to authenticated using(papel()='admin') with check(papel()='admin');

insert into storage.buckets(id,name,public) values('fotos','fotos',true) on conflict do nothing;
create policy f_ins on storage.objects for insert to authenticated with check(bucket_id='fotos');
alter publication supabase_realtime add table chamados, materiais, config;

-- Depois de criar sua conta no app, torne-se administrador:
-- update public.perfis set papel='admin' where id=(select id from auth.users where email='SEU_EMAIL');
