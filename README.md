# homeservicesv

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Variables de entorno

Este proyecto usa Supabase y requiere un archivo `.env` local.

1. Copia `.env.example` como `.env`.
2. Llena los valores reales de Supabase y buckets en tu máquina o entorno de despliegue.
3. No subas `.env` a GitHub.

El archivo `.env` real queda ignorado por Git por seguridad.

## Modo demo/local sin Supabase

La app puede ejecutarse sin `.env` ni proyecto Supabase conectado. En ese caso entra en modo demo/local:

- login y registro permiten navegar como cliente o trabajador demo;
- las pantallas no deben fallar por falta de Supabase;
- los datos persistentes reales quedan pendientes hasta conectar una base de datos nueva.

Cuando la app esté funcional a nivel de flujo, se puede crear un nuevo proyecto Supabase, ejecutar el SQL definitivo y configurar las keys localmente en VS Code sin subirlas a GitHub.
