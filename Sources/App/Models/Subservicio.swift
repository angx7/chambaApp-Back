import MongoDBVapor
import Vapor

struct Subservicio: Content, Codable {
    var id: BSONObjectID?
    var nombre: String
    var descripcion: String
    var categoria: String
    var imagenURL: String
}
