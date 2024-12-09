# Gestor Personal

Aplicación para la gestión de proyectos, tareas y recados personales.

## Tecnologías

- Frontend multiplataforma (Android/Web/Windows)
- Backend serverless con servicios AWS:
  - AWS Amplify
  - API Gateway
  - AWS Lambda
  - DynamoDB

## Estructura del Proyecto

```
gestor_personal/
├── frontend/     # Aplicación frontend multiplataforma
├── backend/      # Funciones Lambda y APIs
└── infrastructure/ # Configuración de infraestructura AWS
```

## Inicio Rápido

### Requisitos previos

### Instrucciones de configuración

## Arquitectura

La aplicación utiliza una arquitectura serverless con los siguientes componentes:

- **Frontend**: Construido con AWS Amplify para compatibilidad multiplataforma
- **Capa de API**: API Gateway para puntos de conexión RESTful
- **Lógica**: AWS Lambda para funciones de backend
- **Base de datos**: DynamoDB para almacenamiento de datos escalable
- **Autenticación**: AWS Cognito para gestión de usuarios

## Seguridad

- Autenticación de usuarios con AWS Cognito
