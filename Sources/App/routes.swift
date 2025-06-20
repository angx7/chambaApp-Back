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

    struct RegistroExitoso: Content {
        let status: String
        let id: String
    }
    app.post("usuarios") { req async throws -> RegistroExitoso in
        var usuario = try req.content.decode(Usuario.self)

        // Validación de campos obligatorios
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

        // Verifica que el usuario no exista
        if try await collection.findOne(["usuario": .string(usuario.usuario)]) != nil {
            throw Abort(.conflict, reason: "El usuario ya existe")
        }

        // Hashea la contraseña
        usuario.contrasena = try Bcrypt.hash(usuario.contrasena)

        // Inserta el usuario
        guard let result = try await collection.insertOne(usuario),
            case let .objectID(id) = result.insertedID
        else {
            throw Abort(.internalServerError, reason: "No se pudo obtener el ID del usuario")
        }

        // Devuelve el JSON limpio
        return RegistroExitoso(status: "ok", id: id.hex)
    }

    app.put("usuarios", ":id") { req async throws -> Usuario in
        guard let idString = req.parameters.get("id"),
            let objectId = try? BSONObjectID(idString)
        else {
            throw Abort(.badRequest, reason: "ID inválido")
        }

        let update = try req.content.decode(UsuarioUpdate.self)
        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "usuarios", withType: Usuario.self)

        // Obtén el usuario actual
        guard var usuarioActual = try await collection.findOne(["_id": .objectID(objectId)]) else {
            throw Abort(.notFound, reason: "Usuario no encontrado")
        }

        // Actualiza los campos permitidos
        usuarioActual.nombreCompleto = update.nombreCompleto
        usuarioActual.fechaNacimiento = update.fechaNacimiento
        usuarioActual.domicilio = update.domicilio
        usuarioActual.cp = update.cp
        usuarioActual.usuario = update.usuario

        // Solo actualiza la contraseña si viene en el request
        if let nuevaContrasena = update.contrasena, !nuevaContrasena.isEmpty {
            usuarioActual.contrasena = try Bcrypt.hash(nuevaContrasena)
        }

        try await collection.replaceOne(
            filter: ["_id": .objectID(objectId)], replacement: usuarioActual)
        usuarioActual.contrasena = ""
        return usuarioActual
    }

    app.delete("usuarios", ":id") { req async throws -> [String: String] in
        guard let idString = req.parameters.get("id"),
            let objectId = try? BSONObjectID(idString)
        else {
            throw Abort(.badRequest, reason: "ID inválido")
        }

        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "usuarios", withType: Usuario.self)

        let result = try await collection.deleteOne(["_id": .objectID(objectId)])
        guard let result = result, result.deletedCount > 0 else {
            throw Abort(.notFound, reason: "Usuario no encontrado")
        }

        return ["status": "ok"]
    }

    app.patch("usuarios", "contrasena") { req async throws -> [String: String] in
        struct RecuperarRequest: Content {
            let usuario: String
            let nuevaContrasena: String
        }

        let data = try req.content.decode(RecuperarRequest.self)

        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "usuarios", withType: Usuario.self)

        guard var usuarioActual = try await collection.findOne(["usuario": .string(data.usuario)])
        else {
            throw Abort(.notFound, reason: "Usuario no encontrado")
        }

        usuarioActual.contrasena = try Bcrypt.hash(data.nuevaContrasena)

        try await collection.replaceOne(
            filter: ["_id": .objectID(usuarioActual.id!)],
            replacement: usuarioActual
        )

        return ["status": "ok"]
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
