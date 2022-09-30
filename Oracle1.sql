-----
connect testBel/1 @ORCL;
-----

-- Create table
--drop table Organisations;
create table Organisations
(
  id      number(9) not null, -- long not null, ��� 11, � >=12 ������ ����� ������� sequence  ��� uniqueidentyfier -> RAW(16) + sys_guid()
  --id      raw(16) default sys_guid() not null, -- raw(16) �� ������� �������� ������������� �� Delphi, Table:( � ������ - �����, ������. � Lookup
  orgname varchar2(200)
);
-- Add comments for table 
comment on table Organisations  is '�����������';
-- Add comments to the columns 
comment on column Organisations.id
  is '��������� ����';
comment on column Organisations.orgname
  is '������������ �����������';
-- Create/Recreate primary, unique and foreign key constraints 
alter table Organisations     add constraint PK_Organisations primary key (ID); -- ������ ���� ��� "long:
-----
-----
--drop table OrgKeys;
create table OrgKeys
(
  id      number(9) not null, -- id
  --id      raw(16) default sys_guid() not null,
  Key     varchar2(32), -- ���� (guid)
  BegDate date, -- ���� ������ ��������(date)
  EndDate date, -- ���� ��������� ��������(date)
  IdOrg   number(9), -- ������������� �����������
  --IdOrg   raw(16), -- ������������� �����������
  Block   char(1) -- ��������� ���������� 0/1
);
-- Add comments for table 
comment on table OrgKeys  is '����������� � �� ����� (1 ���, �.�. ��������� ������)';
-- Add comments to the columns 
comment on column OrgKeys.id  is '��������� ����';
comment on column OrgKeys.Key      is '���� (guid)';
comment on column OrgKeys.BegDate  is '���� ������ ��������(date)';
comment on column OrgKeys.EndDate  is '���� ��������� ��������(date)';
comment on column OrgKeys.IdOrg    is '������������� �����������';
comment on column OrgKeys.Block    is '��������� ���������� 0/1';
-- Create/Recreate primary, unique and foreign key constraints 
alter table OrgKeys     add constraint PK_OrgKeys primary key (ID); -- ������ ���� ��� "long:
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
-- ��������
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
-- ���������
insert into Organisations (orgname) values('����������� �1');
insert into Organisations (orgname) values('���� � ������');
insert into Organisations (orgname) values('����������');
insert into Organisations (orgname) values('���������');
select * from Organisations;
----- ���������
--select * from organisations;
--select * from orgkeys
truncate table OrgKeys;
insert into orgkeys  (key, begdate, enddate, idorg, block)
 values  (sys_guid(), to_date('01.01.2020', 'dd.mm.yyyy'), to_date('30.06.2020', 'dd.mm.yyyy'), (select id from organisations where orgname = '���������'), 1);
insert into orgkeys  (key, begdate, enddate, idorg, block)
 values  (sys_guid(), to_date('01.07.2020', 'dd.mm.yyyy'), to_date('31.12.2020', 'dd.mm.yyyy'), (select id from organisations where orgname = '���������'), 0);

insert into orgkeys  (key, begdate, enddate, idorg, block)
 values  (sys_guid(), to_date('01.01.2020', 'dd.mm.yyyy'), to_date('01.11.2020', 'dd.mm.yyyy'), (select id from organisations where orgname = '����������'), 1);
insert into orgkeys  (key, begdate, enddate, idorg, block)
 values  (sys_guid(), to_date('01.11.2021', 'dd.mm.yyyy'), to_date('01.07.2021', 'dd.mm.yyyy'), (select id from organisations where orgname = '����������'), 1);
insert into orgkeys  (key, begdate, enddate, idorg, block)
 values  (sys_guid(), to_date('02.07.2021', 'dd.mm.yyyy'), to_date('21.09.2022', 'dd.mm.yyyy'), (select id from organisations where orgname = '����������'), 0);
-----
