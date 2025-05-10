# Stable Diffusion App

Este proyecto consiste en una aplicación de generación de imágenes basada en Stable Diffusion, con un frontend web que se comunica con un backend basado en API.

## Estructura del proyecto

```bash
stable-diffusion-app/
├── docker-compose.yml               # Configuración Docker
├── backend/                         # Servicio API
│   ├── Dockerfile                   # Configuración para construir la imagen Docker
│   ├── main.py                      # Punto de entrada de la aplicación backend
│   └── requirements.txt             # Dependencias Python
├── frontend/                        # Interfaz de usuario web
│   ├── index.html                   # Página principal
│   ├── script.js                    # Lógica del frontend
│   └── styles.css                   # Estilos CSS
├── auto-updater.sh                  # Script que busca actualizaciones y reinicia Docker
├── setup-crontab-auto-updater.sh    # Script que programa actualizaciones automáticas cada 5 minutos
├── setup-docker-gpu.sh              # Script que instala Docker y configura soporte para GPU
└── docs/                            # Documentación
    ├── proyecto.tex                 # Documentación en LaTeX
    ├── sample.bib                   # Referencias bibliográficas
    └── diagrama-arquitectura.png    # Resumen de la arquitectura del sistema
```

## Requisitos previos

### Para ejecución con Docker:
- Docker
- Docker Compose
- Compatible con GPU NVIDIA (opcional, pero recomendado para mejor rendimiento)

### Para ejecución manual:
- Python 3.10 o superior (backend)
- Navegador web moderno (frontend)
- GPU NVIDIA con CUDA instalado (opcional, para mejor rendimiento)

## Instrucciones de instalación y ejecución

### Opción 1: Utilizando Docker (recomendado)

1. Instalar Docker con soporte para GPU (opcional):
```bash
./setup-docker-gpu.sh
```

2. Inicia los servicios con Docker Compose:
```bash
docker-compose up -d
```

3. Accede a la aplicación web en:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000

4. (Opcional) Habilitar actualización automática del repositorio cada 5 minutos:
```bash
./setup-crontab-auto-updater.sh
```

Este script añade una tarea programada que ejecuta auto-updater.sh cada 5 minutos.
Dicho script verifica si hay un nuevo commit en la rama main y, de ser así, actualiza el contenedor reiniciando la aplicación.

### Opción 2: Ejecución manual

#### Backend:

1. Navega al directorio del backend:
```bash
cd backend
```

2. Crea y activa un entorno virtual:
```bash
# Windows
python -m venv .venv
.venv\Scripts\activate

# Linux/Mac
python -m venv .venv
source .venv/bin/activate
```

3. Instala las dependencias:
```bash
pip install -r requirements.txt
```

4. Ejecuta el servidor backend:
```bash
uvicorn main:app
```

#### Frontend:

1. Ya que el frontend es estático, puedes servirlo con cualquier servidor web. Una opción sencilla es utilizar la extensión "Live Server" de VSCode o ejecutar:

```bash
# Si tienes Python instalado
cd frontend
python -m http.server 3000
```

2. Accede a la aplicación en tu navegador:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000

## Uso de la API

El backend ofrece los siguientes endpoints:

- `POST /generate` - Genera una imagen a partir de un prompt

## Solución de problemas

- **Error de GPU no disponible**: Verifica que los controladores NVIDIA estén instalados correctamente
- **Problemas de conexión entre frontend y backend**: Asegúrate de que ambos servicios estén ejecutándose y que las URLs estén configuradas correctamente
- **Errores de memoria**: Ajusta los parámetros del modelo o utiliza un dispositivo con más RAM/VRAM

## Recursos adicionales

Para más información sobre el proyecto, consulta la documentación disponible en la carpeta `docs/`.