import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Attendance API - Sistema de Presença Escolar"
    }
    
    try app.register(collection: BeaconController())
    try app.register(collection: StudentController())
    try app.register(collection: DetectionController())
    try app.register(collection: AttendanceController())
}

