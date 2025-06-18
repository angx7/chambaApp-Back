import MongoDBVapor
import Vapor

struct Subservicio: Content, Codable {
    var id: BSONObjectID?
    var nombre: String
    var descripcion: String
    var categoria: String
    var imagenURL: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nombre, descripcion, categoria, imagenURL
    }
}
