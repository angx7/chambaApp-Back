import Vapor
import MongoDBVapor

struct Subservicio: Content, Codable {
    var id: String
    var nombre: String
    var descripcion: String
    var categoria: String
    var imagenURL: String
}