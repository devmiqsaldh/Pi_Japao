# Attendance Backend - Swift Vapor

Backend para o sistema de presença escolar usando beacons.

## Estrutura

- **Models**: Beacon, Student, AttendanceSession, AttendanceRecord, AppSettings
- **Controllers**: BeaconController, StudentController, DetectionController, AttendanceController
- **Services**: MessageService (envio de mensagens)

## API Endpoints

### Beacons
- `GET /api/beacons` - Listar todos os beacons
- `POST /api/beacons` - Criar beacon
- `GET /api/beacons/:beaconID` - Buscar beacon
- `PUT /api/beacons/:beaconID` - Atualizar beacon
- `DELETE /api/beacons/:beaconID` - Deletar beacon

### Students
- `GET /api/students` - Listar todos os alunos
- `POST /api/students` - Criar aluno
- `GET /api/students/:studentID` - Buscar aluno
- `PUT /api/students/:studentID` - Atualizar aluno
- `DELETE /api/students/:studentID` - Deletar aluno

### Detections
- `POST /api/detections` - Registrar detecção de beacon (chamado pelo ESP32)

### Attendance
- `GET /api/attendance/sessions` - Listar sessões
- `GET /api/attendance/sessions/:sessionID` - Detalhes da sessão
- `GET /api/attendance/records` - Listar registros
- `GET /api/attendance/settings` - Buscar configurações
- `PUT /api/attendance/settings` - Atualizar configurações

## Como executar

```bash
cd Backend
swift run
```

O servidor iniciará em `http://localhost:8080`

## Integração com ESP32

O ESP32 deve fazer POST para `/api/detections` com:
```json
{
  "beaconID": "UUID_DO_BEACON",
  "timestamp": "2025-01-01T10:00:00Z"
}
```

