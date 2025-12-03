# Sistema de Presença Escolar com Beacons

Sistema completo para avisar pais quando filhos chegam na escola usando beacons, ESP32 e app iOS.

## Estrutura do Projeto

### Backend (Swift Vapor)
- **Localização**: `Backend/`
- **Tecnologias**: Swift Vapor, Fluent, SQLite
- **API REST** para gerenciar beacons, alunos, sessões e detecções

### App iOS (SwiftUI)
- **Localização**: `PI_Japao/`
- **Arquitetura**: MVVM
- **Tecnologias**: SwiftUI, CoreLocation (para detecção de beacons)

## Como Funciona

1. **Cadastro**: Beacons são cadastrados no app e associados a alunos
2. **Detecção**: ESP32 detecta beacons próximos e envia para o backend
3. **Processamento**: Backend verifica se o beacon está cadastrado e dentro da janela de tempo
4. **Notificação**: Mensagens são enviadas aos pais (email/SMS) via templates configuráveis

## Configuração

### Backend

1. Navegue até a pasta Backend:
```bash
cd Backend
```

2. Execute o servidor:
```bash
swift run
```

O servidor iniciará em `http://localhost:8080`

### App iOS

1. Abra o projeto no Xcode: `PI_Japao.xcodeproj`
2. Configure a URL do backend em `APIService.swift` (padrão: `http://localhost:8080`)
3. Adicione permissões de localização no `Info.plist`:
   - `NSLocationAlwaysAndWhenInUseUsageDescription`
   - `NSLocationAlwaysUsageDescription`
   - `NSLocationWhenInUseUsageDescription`

## Endpoints da API

### Beacons
- `GET /api/beacons` - Listar beacons
- `POST /api/beacons` - Criar beacon
- `GET /api/beacons/:id` - Buscar beacon
- `PUT /api/beacons/:id` - Atualizar beacon
- `DELETE /api/beacons/:id` - Deletar beacon

### Alunos
- `GET /api/students` - Listar alunos
- `POST /api/students` - Criar aluno
- `GET /api/students/:id` - Buscar aluno
- `PUT /api/students/:id` - Atualizar aluno
- `DELETE /api/students/:id` - Deletar aluno

### Detecções
- `POST /api/detections` - Registrar detecção (chamado pelo ESP32)

### Presença
- `GET /api/attendance/sessions` - Listar sessões
- `GET /api/attendance/sessions/:id` - Detalhes da sessão
- `GET /api/attendance/records` - Listar registros
- `GET /api/attendance/settings` - Buscar configurações
- `PUT /api/attendance/settings` - Atualizar configurações

## Integração com ESP32

O ESP32 deve fazer POST para `/api/detections` quando detectar um beacon:

```json
{
  "beaconID": "UUID_DO_BEACON",
  "timestamp": "2025-01-01T10:00:00Z"
}
```

## Estrutura MVVM

### ViewModels
- `BeaconViewModel` - Gerencia beacons
- `StudentViewModel` - Gerencia alunos
- `DashboardViewModel` - Dashboard principal
- `HistoryViewModel` - Histórico de sessões
- `SettingsViewModel` - Configurações
- `AttendanceManager` - Orquestra detecção de beacons

### Services
- `APIService` - Comunicação com backend
- `BeaconScannerService` - Detecção de beacons via CoreLocation

## Funcionalidades

- ✅ Cadastro de beacons
- ✅ Cadastro de alunos associados a beacons
- ✅ Detecção automática de beacons (apenas cadastrados)
- ✅ Sessões de presença e saída configuráveis
- ✅ Envio de mensagens aos pais
- ✅ Histórico de presenças
- ✅ Configuração de horários e mensagens

## Próximos Passos

1. Integrar serviço real de SMS (ex: Twilio)
2. Integrar serviço real de Email (ex: SendGrid)
3. Adicionar autenticação/autorização
4. Implementar notificações push no app
5. Dashboard web para visualização

