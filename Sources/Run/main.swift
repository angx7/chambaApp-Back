import App
import MongoDBVapor
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let app = Application(env)
app.http.server.configuration.hostname = "0.0.0.0"
try configure(app)

defer {
    // Cleanup the application's MongoDB data.
    app.mongoDB.cleanup()
    // Clean up the driver's global state. The driver will no longer be usable from this program after this method is
    // called.
    cleanupMongoSwift()
//    app.shutdown()
}

try app.run()
