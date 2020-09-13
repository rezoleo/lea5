#!/usr/bin/env bash

sudo --user postgres -c "SELECT pg_catalog.set_config('search_path', '', false); CREATE ROLE lea5 PASSWORD 'lea5' NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN;"
sudo --user postgres createdb lea5_test --owner=lea5
