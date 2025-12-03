# Estrutura do Projeto PI_Japao

Este documento descreve a organização completa do projeto seguindo a arquitetura MVVM.

## 📁 Estrutura de Pastas

```
PI_Japao/
├── Backend/                    # Backend Swift Vapor
│   ├── Package.swift
│   ├── Sources/
│   │   └── App/
│   │       ├── Controllers/    # Controllers da API
│   │       ├── Models/         # Modelos do banco de dados
│   │       ├── Migrations/     # Migrações do banco
│   │       ├── Services/       # Serviços (MessageService)
│   │       ├── configure.swift
│   │       ├── entrypoint.swift
│   │       └── routes.swift
│   └── README.md
│
├── ESP32/                      # Código para ESP32
│   ├── esp32_beacon_scanner.ino
│   ├── platformio.ini
│   └── README.md
│
├── PI_Japao/                   # Projeto iOS (SwiftUI)
│   ├── PI_Japao.xcodeproj/     # Projeto Xcode
│   └── PI_Japao/               # Código fonte
│       ├── PI_JapaoApp.swift   # Entry point do app
│       │
│       ├── Models/              # Modelos de dados
│       │   └── Models.swift    # Enums e tipos compartilhados
│       │
│       ├── Views/               # Camada de apresentação (MVVM)
│       │   ├── ContentView.swift
│       │   ├── DashboardView.swift
│       │   ├── BeaconsViews.swift
│       │   ├── StudentsViews.swift
│       │   ├── HistoryView.swift
│       │   └── SettingsView.swift
│       │
│       ├── ViewModels/          # Camada de lógica (MVVM)
│       │   ├── AttendanceManager.swift
│       │   ├── BeaconViewModel.swift
│       │   ├── StudentViewModel.swift
│       │   ├── DashboardViewModel.swift
│       │   ├── HistoryViewModel.swift
│       │   └── SettingsViewModel.swift
│       │
│       ├── Services/            # Camada de serviços
│       │   ├── APIService.swift         # Comunicação com backend
│       │   └── BeaconScannerService.swift # Detecção de beacons
│       │
│       └── Resources/          # Recursos do app
│           └── Assets.xcassets # Imagens e ícones
│
├── README.md                    # Documentação principal
└── GUIA_CADASTRO_BEACONS.md    # Guia de cadastro
```

## 🏗️ Arquitetura MVVM

### Models
- **Models.swift**: Define enums e tipos compartilhados (`SessionKind`, `AttendanceStatus`)

### Views
- **ContentView**: TabView principal com navegação
- **DashboardView**: Dashboard com sessões atuais
- **BeaconsViews**: Lista e formulário de beacons
- **StudentsViews**: Lista e formulário de alunos
- **HistoryView**: Histórico de sessões
- **SettingsView**: Configurações do sistema

### ViewModels
- **AttendanceManager**: Orquestra detecção de beacons e comunicação com backend
- **BeaconViewModel**: Gerencia CRUD de beacons
- **StudentViewModel**: Gerencia CRUD de alunos
- **DashboardViewModel**: Gerencia estado do dashboard
- **HistoryViewModel**: Gerencia histórico de sessões
- **SettingsViewModel**: Gerencia configurações

### Services
- **APIService**: Cliente HTTP para comunicação com backend REST
- **BeaconScannerService**: Serviço de detecção de beacons usando CoreLocation

## 🔄 Fluxo de Dados

```
Views → ViewModels → Services → Backend API
  ↑                                    ↓
  └─────────── DTOs ←─────────────────┘
```

1. **Views** observam **ViewModels** usando `@Observable`
2. **ViewModels** usam **Services** para comunicação
3. **Services** fazem requisições HTTP para o **Backend**
4. **Backend** retorna DTOs que são convertidos e atualizam os **ViewModels**
5. **Views** são atualizadas automaticamente via SwiftUI

## 📦 Dependências

### iOS App
- SwiftUI (nativo)
- CoreLocation (nativo)
- Foundation (nativo)

### Backend
- Vapor 4.89.0+
- Fluent 4.8.0+
- FluentSQLiteDriver 4.4.0+

### ESP32
- Arduino BLE Library
- WiFi Library
- HTTPClient Library
- ArduinoJson

## 🚀 Como Usar

### 1. Backend
```bash
cd PI_Japao/Backend
swift run
```

### 2. App iOS
1. Abra `PI_Japao.xcodeproj` no Xcode
2. Configure a URL do backend em `Services/APIService.swift`
3. Execute no simulador ou dispositivo

### 3. ESP32
1. Abra `ESP32/esp32_beacon_scanner.ino` no Arduino IDE
2. Configure WiFi e URL do backend
3. Faça upload para o ESP32

## 📝 Convenções

### Nomenclatura
- **Views**: `*View.swift` (ex: `DashboardView.swift`)
- **ViewModels**: `*ViewModel.swift` (ex: `BeaconViewModel.swift`)
- **Services**: `*Service.swift` (ex: `APIService.swift`)
- **Models**: `Models.swift` ou `*Model.swift`

### Organização
- Cada View tem seu ViewModel correspondente
- Services são singletons quando apropriado
- DTOs são definidos junto com os Services que os usam

## 🔧 Manutenção

### Adicionar Nova View
1. Criar arquivo em `Views/`
2. Criar ViewModel correspondente em `ViewModels/`
3. Adicionar rota em `ContentView.swift` se necessário

### Adicionar Novo Endpoint
1. Adicionar método em `Services/APIService.swift`
2. Criar DTO se necessário
3. Usar no ViewModel apropriado

### Adicionar Nova Feature
1. Criar View e ViewModel
2. Adicionar Service se necessário
3. Atualizar backend se necessário
4. Testar fluxo completo

