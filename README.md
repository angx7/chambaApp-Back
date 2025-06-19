# ChambaApp Backend

**ChambaApp** es una API REST desarrollada con [Vapor](https://github.com/vapor/vapor) y conectada a una base de datos **MongoDB**. Sirve como backend para la aplicación móvil [ChambaApp-Front](https://github.com/angx7/chambaApp-Front), que conecta usuarios con prestadores de servicios como jardineros, niñeras, plomeros, entre otros.

El backend ya se encuentra desplegado y funcionando en DigitalOcean:  
📡 http://137.184.82.172

---

## 📌 Funcionalidades principales

- Registro e inicio de sesión de usuarios
- Recuperación de contraseña
- Listado y filtrado de servicios y subservicios
- Gestión de prestadores y reseñas
- Autenticación segura y validación de campos

---

## 🗂 Estructura del proyecto

```
ChambaApp-Back/
├── Controllers/         # Controladores para cada endpoint
├── Models/              # Modelos de datos: Usuario, Prestador, Reseña, etc.
├── Config/              # Configuraciones de MongoDB y servicios
├── Routes/              # Definición de rutas de la API
├── main.swift           # Punto de entrada principal
├── Package.swift        # Dependencias del proyecto
└── Utilities/           # Utilidades generales (middleware, validaciones, etc.)
```

---

## ⚙️ Tecnologías usadas

- Vapor 4 (Framework backend en Swift)
- MongoDB (Base de datos NoSQL)
- SwiftNIO (para operaciones no bloqueantes)
- DigitalOcean (Despliegue en producción)

---

## 🚀 Cómo levantar localmente

1. Clona el repositorio:

```bash
git clone https://github.com/angx7/chambaApp-Back.git
cd chambaApp-Back
```

2. Asegúrate de tener Swift 5.9+ y Vapor instalado. Si no lo tienes:

```bash
brew install vapor
```

3. Configura tu cadena de conexión a MongoDB en el archivo correspondiente del backend (`MongoDBConfig.swift`, `main.swift`, o donde se defina la conexión):

```swift
try app.mongoDB.configure(connectionString: "mongodb+srv://<usuario>:<contraseña>@cluster.mongodb.net/ChambaApp")
```

4. Corre el servidor local:

```bash
vapor run serve
```

---

## 📡 Producción

El servidor está desplegado en:

```
http://137.184.82.172
```

---

## 🧪 Estado actual

✅ Registro y login de usuarios  
✅ Manejo de prestadores  
✅ Consultas por subservicio  
✅ Recuperación de contraseña  
✅ Integración con frontend SwiftUI  
❌ No incluye tests automatizados

---

## 👥 Autores

Proyecto desarrollado por:

- Angel Alejandro Becerra Rojas [@angx7](https://github.com/angx7)
- Christian Axel Moreno Flores [@Kuripipeer](https://github.com/kuripipeer)
- Abraham Rodríguez Contreras [@bardodepacotilla2912](https://github.com/bardodepacotilla2912)
- Grecia Navarrete Mexicano [@GreciaNM](https://github.com/GreciaNM)
- Ximena Gutiérrez Pérez [@Xitony0407](https://github.com/Xitony0407)

---

## 📄 Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT.
