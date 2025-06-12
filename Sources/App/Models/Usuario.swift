//
//  Usuario.swift
//  VaporExample
//
//  Created by Angel Becerra Rojas on 11/06/25.
//

import Vapor
import MongoDBVapor

struct Usuario: Content, Codable {
    var id: BSONObjectID?
    var nombreCompleto: String
    var fechaNacimiento: String
    var domicilio: String
    var cp: String
    var usuario: String
    var contrasena: String
}
