import MongoDBVapor
import Vapor

struct Prestador: Content, Codable {
    var id: BSONObjectID?
    var nombre: String
    var edad: Int
    var telefono: String
    var subservicio: String
    var fotoURL: String
    var descripcion: String
    var experiencia: String
    var ubicacion: String
    var calificacion: Double
    var reseñas: [Reseña]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nombre, edad, telefono, subservicio, fotoURL, descripcion, experiencia, ubicacion,
            calificacion, reseñas
    }
}

struct Reseña: Content {
    var cliente: String
    var comentario: String
    var calificacion: Int
    var fecha: String
}
