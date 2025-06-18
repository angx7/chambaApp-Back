//
//  Usuario.swift
//  VaporExample
//
//  Created by Angel Becerra Rojas on 11/06/25.
//

import MongoDBVapor
import Vapor

struct Usuario: Content, Codable {
    var id: BSONObjectID?
    var nombreCompleto: String
    var fechaNacimiento: String
    var domicilio: String
    var cp: String
    var usuario: String
    var contrasena: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nombreCompleto, fechaNacimiento, domicilio, cp, usuario, contrasena
    }
}

struct UsuarioUpdate: Content {
    var nombreCompleto: String
    var fechaNacimiento: String
    var domicilio: String
    var cp: String
    var usuario: String
    var contrasena: String?  // Opcional
}
