# GitHub Pages preview

Este repo está preparado para publicar la app Flutter Web en GitHub Pages mediante GitHub Actions.

## Secrets requeridos

En GitHub, ir a:

`Settings > Secrets and variables > Actions > New repository secret`

Agregar:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `BUCKET_PERFIL_FOTOS`
- `BUCKET_DUI_DOCUMENTOS`
- `BUCKET_ANTECEDENTES_DOCUMENTOS`
- `BUCKET_SOLICITUDES_IMAGENES`
- `BUCKET_CHAT_IMAGENES`

Usar los mismos valores del `.env` local. No subir `.env` al repo.

## Activar Pages

Ir a:

`Settings > Pages`

En **Build and deployment**, seleccionar:

- Source: `GitHub Actions`

Después de un push a `main`, el workflow `Deploy Flutter Web to GitHub Pages` construirá y publicará la app.

URL esperada:

`https://lunabot099.github.io/homeservicesv/`

## Nota de seguridad

`SUPABASE_ANON_KEY` puede estar en una app frontend, pero la seguridad real debe estar en Supabase con RLS y policies correctas. Nunca usar `SERVICE_ROLE_KEY` en GitHub Pages ni en Flutter Web.
