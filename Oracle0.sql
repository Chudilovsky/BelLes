connect system/1 @ORCL;

-- Create the user 
create user testBel  identified by "1";
-- Grant/Revoke role privileges 
grant connect to testBel;
ALTER USER testBel QUOTA 100M ON users;
GRANT create session, create table, CREATE SEQUENCE, CREATE TRIGGER TO testBel;
