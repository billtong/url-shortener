@echo off 
Rem this is for creating environment local environment variable on win10
setx DATABASE_URL "postgres://postgres:postgres@localhost:5433/shorturl_?"
setx APP_BASE_URL "http://localhost:4000"
