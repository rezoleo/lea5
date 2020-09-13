SELECT pg_catalog.set_config('search_path', '', false);

-- sudo --user postgres createuser lea5 --createdb --pwprompt --echo
CREATE ROLE lea5 PASSWORD 'lea5' NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN;
-- sudo --user postgres createdb lea5_development --owner=lea5 --echo
CREATE DATABASE lea5_development OWNER lea5;
-- sudo --user postgres createdb lea5_test --owner=lea5 --echo
CREATE DATABASE lea5_test OWNER lea5;
