import Vapor
import MongoDBVapor

struct Prestador: Content {
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
}

struct Reseña: Content {
    var cliente: String
    var comentario: String
    var calificacion: Int
    var fecha: String
}

