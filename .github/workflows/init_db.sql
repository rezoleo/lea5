SELECT pg_catalog.set_config('search_path', '', false);

-- sudo --user postgres createuser lea5 --createdb --pwprompt --echo
/*
Rails needs superuser privileges to disable referential integrity for fixtures to load in a correct order.
Without this, it crashes because of foreign key constraints
*/
CREATE ROLE lea5 PASSWORD 'md50235066ab783f00a60dd1ea78c9ec3b2' SUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN;
-- sudo --user postgres createdb lea5_development --owner=lea5 --echo
CREATE DATABASE lea5_development OWNER lea5;
-- sudo --user postgres createdb lea5_test --owner=lea5 --echo
CREATE DATABASE lea5_test OWNER lea5;
