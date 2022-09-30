-----
connect testBel/1 @ORCL;
-----

-- Create table
--drop table Organisations;
create table Organisations
(
  id      number(9) not null, -- long not null, тут 11, а >=12 версии можно указать sequence  или uniqueidentyfier -> RAW(16) + sys_guid()
  --id      raw(16) default sys_guid() not null, -- raw(16) не удалось напрямую редактировать из Delphi, Table:( а видиме - можно, наприм. в Lookup
  orgname varchar2(200)
);
-- Add comments for table 
comment on table Organisations  is 'Организации';
-- Add comments to the columns 
comment on column Organisations.id
  is 'Первичный ключ';
comment on column Organisations.orgname
  is 'Наименование организации';
-- Create/Recreate primary, unique and foreign key constraints 
alter table Organisations     add constraint PK_Organisations primary key (ID); -- нельзя если тип "long:
-----
-----
--drop table OrgKeys;
create table OrgKeys
(
  id      number(9) not null, -- id
  --id      raw(16) default sys_guid() not null,
  Key     varchar2(32), -- ключ (guid)
  BegDate date, -- дата начала действия(date)
  EndDate date, -- дата окончания действия(date)
  IdOrg   number(9), -- идентификатор организации
  --IdOrg   raw(16), -- идентификатор организации
  Block   char(1) -- индикатор блокировки 0/1
);
-- Add comments for table 
comment on table OrgKeys  is 'Организации и их ключи (1 орг, м.б. несколько ключей)';
-- Add comments to the columns 
comment on column OrgKeys.id  is 'Первичный ключ';
comment on column OrgKeys.Key      is 'ключ (guid)';
comment on column OrgKeys.BegDate  is 'дата начала действия(date)';
comment on column OrgKeys.EndDate  is 'дата окончания действия(date)';
comment on column OrgKeys.IdOrg    is 'идентификатор организации';
comment on column OrgKeys.Block    is 'индикатор блокировки 0/1';
-- Create/Recreate primary, unique and foreign key constraints 
alter table OrgKeys     add constraint PK_OrgKeys primary key (ID); -- нельзя если тип "long:
-- Add/modify columns 
-- alter table ORGKEYS modify idorg raw(16);
-- Create/Recreate primary, unique and foreign key constraints 
alter table ORGKEYS
  add constraint FK_ORGKEYS_ORGS foreign key (IDORG)
  references organisations (ID) on delete cascade;
-----
--drop   SEQUENCE organisations_seq;
CREATE SEQUENCE organisations_seq
  MINVALUE 1
  MAXVALUE 999999999
  START WITH 10
  INCREMENT BY 1
  CACHE 3;
--drop   SEQUENCE organisations_seq;
CREATE SEQUENCE orgkeys_seq
  MINVALUE 1
  MAXVALUE 999999999
  START WITH 10
  INCREMENT BY 1
  CACHE 3;

--
-- триггеры
CREATE OR REPLACE TRIGGER organisations_tr
  BEFORE INSERT 
  ON organisations
  FOR EACH ROW
  WHEN (new.id is null)
DECLARE
  v_id organisations.id%TYPE;
BEGIN
  select organisations_seq.nextval INTO v_id FROM DUAL;
  :new.id := v_id;
END organisations_tr;
/
CREATE OR REPLACE TRIGGER orgkeys_tr
  BEFORE INSERT 
  ON orgkeys
  FOR EACH ROW
  WHEN (new.id is null)
DECLARE
  v_id orgkeys.id%TYPE;
BEGIN
  select orgkeys_seq.nextval INTO v_id FROM DUAL;
  :new.id := v_id;
END orgkeys_tr;
/
-----
-- стартовые
insert into Organisations (orgname) values('Организация №1');
insert into Organisations (orgname) values('Рога и копыта');
insert into Organisations (orgname) values('Стройтрест');
insert into Organisations (orgname) values('Заготовка');
select * from Organisations;
----- Стартовые
--select * from organisations;
--select * from orgkeys
truncate table OrgKeys;
insert into orgkeys  (key, begdate, enddate, idorg, block)
 values  (sys_guid(), to_date('01.01.2020', 'dd.mm.yyyy'), to_date('30.06.2020', 'dd.mm.yyyy'), (select id from organisations where orgname = 'Заготовка'), 1);
insert into orgkeys  (key, begdate, enddate, idorg, block)
 values  (sys_guid(), to_date('01.07.2020', 'dd.mm.yyyy'), to_date('31.12.2020', 'dd.mm.yyyy'), (select id from organisations where orgname = 'Заготовка'), 0);

insert into orgkeys  (key, begdate, enddate, idorg, block)
 values  (sys_guid(), to_date('01.01.2020', 'dd.mm.yyyy'), to_date('01.11.2020', 'dd.mm.yyyy'), (select id from organisations where orgname = 'Стройтрест'), 1);
insert into orgkeys  (key, begdate, enddate, idorg, block)
 values  (sys_guid(), to_date('01.11.2021', 'dd.mm.yyyy'), to_date('01.07.2021', 'dd.mm.yyyy'), (select id from organisations where orgname = 'Стройтрест'), 1);
insert into orgkeys  (key, begdate, enddate, idorg, block)
 values  (sys_guid(), to_date('02.07.2021', 'dd.mm.yyyy'), to_date('21.09.2022', 'dd.mm.yyyy'), (select id from organisations where orgname = 'Стройтрест'), 0);
-----
