import Crypto
import MongoDBVapor
import Vapor

func routes(_ app: Application) throws {

    app.get("usuarios", ":id") { req async throws -> Usuario in
        guard let idString = req.parameters.get("id"),
            let objectId = try? BSONObjectID(idString)
        else {
            throw Abort(.badRequest, reason: "ID inválido")
        }

        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "usuarios", withType: Usuario.self)

        guard let usuario = try await collection.findOne(["_id": .objectID(objectId)]) else {
            throw Abort(.notFound, reason: "Usuario no encontrado")
        }

        return usuario
    }

    app.get("usuarios") { req async throws -> [Usuario] in
        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "usuarios", withType: Usuario.self)
        return try await collection.find().toArray()
    }

    app.post("usuarios") { req async throws -> Usuario in
        var usuario = try req.content.decode(Usuario.self)
        // Verifica que todos los campos requeridos estén completos
        guard !usuario.nombreCompleto.isEmpty,
            !usuario.fechaNacimiento.isEmpty,
            !usuario.domicilio.isEmpty,
            !usuario.cp.isEmpty,
            !usuario.usuario.isEmpty,
            !usuario.contrasena.isEmpty
        else {
            throw Abort(.badRequest, reason: "Todos los campos son obligatorios")
        }

        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "usuarios", withType: Usuario.self)

        // Verifica si el usuario ya existe
        if try await collection.findOne(["usuario": .string(usuario.usuario)]) != nil {
            throw Abort(.conflict, reason: "El usuario ya existe")
        }

        // Hashea la contraseña y el domicilio
        usuario.contrasena = try Bcrypt.hash(usuario.contrasena)
        usuario.domicilio = try Bcrypt.hash(usuario.domicilio)

        // Inserta el nuevo usuario
        try await collection.insertOne(usuario)
        return usuario
    }

    app.put("usuarios", ":id") { req async throws -> Usuario in
        guard let idString = req.parameters.get("id"),
              let objectId = try? BSONObjectID(idString)
        else {
            throw Abort(.badRequest, reason: "ID inválido")
        }

        var usuario = try req.content.decode(Usuario.self)
        usuario.id = objectId // Asigna el ID del usuario existente

        usuario.contrasena = try Bcrypt.hash(usuario.contrasena)
        usuario.domicilio = try Bcrypt.hash(usuario.domicilio)

        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "usuarios", withType: Usuario.self)

        try await collection.replaceOne(filter: ["_id": .objectID(objectId)], replacement: usuario)
        return usuario
    }

    app.post("login") { req async throws -> [String: String] in
        struct LoginRequest: Content {
            let usuario: String
            let contrasena: String
        }

        let login = try req.content.decode(LoginRequest.self)
        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "usuarios", withType: Usuario.self)

        // Busca el usuario por email
        guard let usuario = try await collection.findOne(["usuario": .string(login.usuario)]) else {
            throw Abort(.unauthorized, reason: "Usuario no encontrado")
        }
        // Verifica la contraseña (asumiendo que está almacenada en texto plano, pero deberías usar hash)
        if try Bcrypt.verify(login.contrasena, created: usuario.contrasena) {
            return ["status": "ok", "id": usuario.id?.hex ?? ""]
        } else {
            throw Abort(.unauthorized, reason: "Contraseña incorrecta")
        }
    }

    app.get("subservicios") { req async throws -> [Subservicio] in
        // Definir categorías válidas
        let categoriasValidas = ["Domestico", "Empresarial", "Otros"]

        // Obtener parámetro `categoria`
        guard let categoria = req.query[String.self, at: "categoria"] else {
            throw Abort(.badRequest, reason: "La categoría es requerida")
        }

        // Validar si está entre los permitidos
        guard categoriasValidas.contains(categoria) else {
            throw Abort(.badRequest, reason: "Categoría inválida")
        }

        // Buscar en la colección
        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "subservicios", withType: Subservicio.self)

        let filter: BSONDocument = ["categoria": .string(categoria)]

        // Retornar subservicios filtrados
        return try await collection.find(filter).toArray()
    }

    //obtener todos
    app.get("prestadores") { req async throws -> [Prestador] in
        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "prestadores_detalle", withType: Prestador.self)

        let prestadores = try await collection.find().toArray()
        return prestadores
    }

    app.get("prestadores", ":id") { req async throws -> Prestador in
        guard let idString = req.parameters.get("id"),
            let objectId = try? BSONObjectID(idString)
        else {
            throw Abort(.badRequest, reason: "ID inválido")
        }

        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "prestadores_detalle", withType: Prestador.self)

        guard let prestador = try await collection.findOne(["_id": .objectID(objectId)]) else {
            throw Abort(.notFound, reason: "Prestador no encontrado")
        }

        return prestador
    }

    app.get("prestadores", "subservicio", ":subservicio") { req async throws -> [Prestador] in
        guard let subservicio = req.parameters.get("subservicio") else {
            throw Abort(.badRequest, reason: "Subservicio no especificado")
        }

        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "prestadores_detalle", withType: Prestador.self)

        let prestadores = try await collection.find(["subservicio": .string(subservicio)]).toArray()
        return prestadores

    }

}
