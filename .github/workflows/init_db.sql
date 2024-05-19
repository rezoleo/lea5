SELECT pg_catalog.set_config('search_path', '', false);

-- sudo --user postgres createuser lea5 --createdb --pwprompt --echo
/*
Rails needs superuser privileges to disable referential integrity for fixtures to load in a correct order.
Without this, it crashes because of foreign key constraints
TODO: Check which permissions exactly are required and if we can avoid creating a superuser
      (This is not that important since it is only used during tests, the production user can be a normal user)
*/
CREATE ROLE lea5 PASSWORD 'SCRAM-SHA-256$4096:0vqJhONUNwcuf1qtMlZSLA==$EI4D9sE2vsYuQRMlGVlfNQeZjryX951jo5fx44A6iOg=:c7Pk+AZ3mMNmnxs9aGP8+MtxPWLyfl2kPyrQr40ILoY=' SUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN;
-- sudo --user postgres createdb lea5_development --owner=lea5 --echo
CREATE DATABASE lea5_development OWNER lea5;
-- sudo --user postgres createdb lea5_test --owner=lea5 --echo
CREATE DATABASE lea5_test OWNER lea5;
