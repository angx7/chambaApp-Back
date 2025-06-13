import MongoDBVapor
import Vapor
import Crypto

func routes(_ app: Application) throws {
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

    app.post("login") { req async throws -> String in
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
            return "Login exitoso"
        } else {
            throw Abort(.unauthorized, reason: "Contraseña incorrecta")
        }
    }

   //obtener todos 
    app.get("prestadores") { req async throws -> [Prestador] in
    let collection = req.mongoDB.client.db("ChambaApp").collection("prestadores_detalle", withType: Prestador.self)

    let prestadores = try await collection.find().toArray()
    return prestadores
}

app.get("prestadores", ":id") { req async throws -> Prestador in
    guard let idString = req.parameters.get("id"),
          let objectId = try? BSONObjectID(idString) else {
        throw Abort(.badRequest, reason: "ID inválido")
    }

    let collection = req.mongoDB.client.db("ChambaApp").collection("prestadores_detalle", withType: Prestador.self)

    guard let prestador = try await collection.findOne(["_id": .objectID(objectId)]) else {
        throw Abort(.notFound, reason: "Prestador no encontrado")
    }

    return prestador
}





}



