# Sistema de Presença Escolar com Beacons

Sistema completo para avisar pais quando filhos chegam na escola usando beacons, ESP32 e app iOS.

## 📁 Estrutura do Projeto

```
Pi_Japao/
├── PI_Japao/             # Projeto principal
│   ├── Backend/          # Backend Swift Vapor
│   ├── ESP32/            # Código para ESP32
│   └── PI_Japao/         # Projeto iOS (SwiftUI + MVVM)
│       ├── Models/       # Modelos de dados
│       ├── Views/        # Camada de apresentação
│       ├── ViewModels/   # Camada de lógica
│       ├── Services/     # Serviços (API, Scanner)
│       └── Resources/    # Recursos (Assets)
└── README.md             # Este arquivo
```

📖 **Ver [PI_Japao/ESTRUTURA_PROJETO.md](PI_Japao/ESTRUTURA_PROJETO.md) para detalhes completos da arquitetura MVVM**

##  Início Rápido

### 1. Backend

```bash
cd PI_Japao/Backend
swift run
```

O servidor iniciará em `http://localhost:8080`

### 2. App iOS

1. Abra `PI_Japao/PI_Japao.xcodeproj` no Xcode
2. **Importante**: Se os arquivos não aparecerem, adicione manualmente:
   - Clique com botão direito no projeto → "Add Files to PI_Japao"
   - Adicione as pastas: `Views/`, `ViewModels/`, `Services/`, `Models/`, `Resources/`
3. Configure a URL do backend em `Services/APIService.swift` (padrão: `http://localhost:8080`)
4. Execute no simulador ou dispositivo

### 3. ESP32

1. Abra `PI_Japao/ESP32/esp32_beacon_scanner.ino` no Arduino IDE
2. Configure WiFi e URL do backend
3. Faça upload para o ESP32

##  Documentação

- **[PI_Japao/ESTRUTURA_PROJETO.md](PI_Japao/ESTRUTURA_PROJETO.md)** - Arquitetura MVVM completa
- **[PI_Japao/GUIA_CADASTRO_BEACONS.md](PI_Japao/GUIA_CADASTRO_BEACONS.md)** - Como cadastrar beacons e alunos
- **[PI_Japao/CONFIGURAR_XCODE.md](PI_Japao/CONFIGURAR_XCODE.md)** - Guia de configuração do Xcode
- **[PI_Japao/Backend/README.md](PI_Japao/Backend/README.md)** - Documentação do backend
- **[PI_Japao/ESP32/README.md](PI_Japao/ESP32/README.md)** - Guia de integração ESP32

##  Arquitetura MVVM

### Models
- `Models.swift` - Enums e tipos compartilhados

### Views
- `ContentView.swift` - TabView principal
- `DashboardView.swift` - Dashboard
- `BeaconsViews.swift` - Gerenciamento de beacons
- `StudentsViews.swift` - Gerenciamento de alunos
- `HistoryView.swift` - Histórico
- `SettingsView.swift` - Configurações

### ViewModels
- `AttendanceManager.swift` - Orquestrador principal
- `BeaconViewModel.swift` - Lógica de beacons
- `StudentViewModel.swift` - Lógica de alunos
- `DashboardViewModel.swift` - Lógica do dashboard
- `HistoryViewModel.swift` - Lógica do histórico
- `SettingsViewModel.swift` - Lógica de configurações

### Services
- `APIService.swift` - Cliente HTTP para backend
- `BeaconScannerService.swift` - Detecção de beacons (CoreLocation)

##  Fluxo de Funcionamento

1. **Cadastro**: Beacons são cadastrados no app e associados a alunos
2. **Detecção**: ESP32 detecta beacons próximos e envia para o backend
3. **Processamento**: Backend verifica se o beacon está cadastrado e dentro da janela de tempo
4. **Notificação**: Mensagens são enviadas aos pais (email/SMS) via templates configuráveis

##  API Endpoints

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

## ✅ Funcionalidades

- ✅ Cadastro de beacons
- ✅ Cadastro de alunos associados a beacons
- ✅ Detecção automática de beacons (apenas cadastrados)
- ✅ Sessões de presença e saída configuráveis
- ✅ Envio de mensagens aos pais
- ✅ Histórico de presenças
- ✅ Configuração de horários e mensagens
- ✅ Arquitetura MVVM limpa e testável

##  Configuração

### Backend
- Edite `PI_Japao/Backend/Sources/App/configure.swift` se necessário
- Banco de dados SQLite criado automaticamente em `attendance.db`

### App iOS
- Configure URL do backend em `PI_Japao/PI_Japao/Services/APIService.swift`
- Adicione permissões de localização no `Info.plist`:
  - `NSLocationAlwaysAndWhenInUseUsageDescription`
  - `NSLocationAlwaysUsageDescription`
  - `NSLocationWhenInUseUsageDescription`

### ESP32
- Configure WiFi em `PI_Japao/ESP32/esp32_beacon_scanner.ino`
- Configure URL do backend (use IP local da máquina)

##  Troubleshooting

### Arquivos não aparecem no Xcode
1. Clique com botão direito no projeto
2. Selecione "Add Files to PI_Japao"
3. Adicione as pastas: `Views/`, `ViewModels/`, `Services/`, `Models/`, `Resources/`
4. Certifique-se de marcar "Create groups" e "Add to targets: PI_Japao"
5. Veja [PI_Japao/CONFIGURAR_XCODE.md](PI_Japao/CONFIGURAR_XCODE.md) para detalhes

### Backend não inicia
- Verifique se a porta 8080 está livre
- Confirme que todas as dependências estão instaladas: `swift package resolve`

### ESP32 não detecta beacons
- Verifique se o BLE está habilitado
- Confirme que o beacon está transmitindo
- Verifique a distância (máximo ~10 metros)

##  Suporte

Para mais informações, consulte:
- [PI_Japao/ESTRUTURA_PROJETO.md](PI_Japao/ESTRUTURA_PROJETO.md) - Arquitetura detalhada
- [PI_Japao/GUIA_CADASTRO_BEACONS.md](PI_Japao/GUIA_CADASTRO_BEACONS.md) - Guia de uso
- [PI_Japao/Backend/README.md](PI_Japao/Backend/README.md) - Documentação do backend
- [PI_Japao/ESP32/README.md](PI_Japao/ESP32/README.md) - Guia ESP32
