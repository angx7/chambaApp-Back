import MongoDBVapor
import Vapor

func routes(_ app: Application) throws {
    app.get("usuarios") { req async throws -> [Usuario] in
        let collection = req.mongoDB.client.db("ChambaApp").collection(
            "usuarios", withType: Usuario.self)
        return try await collection.find().toArray()
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
        if usuario.contrasena == login.contrasena {
            return "Login exitoso"
        } else {
            throw Abort(.unauthorized, reason: "Contraseña incorrecta")
        }
    }
}
