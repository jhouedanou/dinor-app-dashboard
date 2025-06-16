-- Script d'initialisation pour Supabase Local
-- Créer les rôles nécessaires pour PostgREST

-- Rôle pour les utilisateurs authentifiés
CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'authenticatorpassword';

-- Rôle pour les utilisateurs anonymes
CREATE ROLE anon NOLOGIN;
GRANT anon TO authenticator;

-- Rôle pour les utilisateurs authentifiés
CREATE ROLE authenticated NOLOGIN;
GRANT authenticated TO authenticator;

-- Rôle de service avec tous les privilèges
CREATE ROLE service_role NOLOGIN BYPASSRLS;
GRANT service_role TO authenticator;

-- Donner les permissions de base
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT CREATE ON SCHEMA public TO anon, authenticated, service_role;

-- Permettre aux rôles de créer des tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role;

-- Extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto"; 