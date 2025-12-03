# Como Configurar o Xcode Após Reorganização

Após mover os arquivos para a estrutura MVVM, você precisa atualizar o projeto no Xcode.

## Passo a Passo

### 1. Abrir o Projeto
```bash
open PI_Japao.xcodeproj
```

### 2. Remover Referências Antigas (se necessário)

1. No Xcode, selecione o projeto no navegador
2. Se houver arquivos com "?" (referências quebradas), selecione-os e delete (Delete → Remove Reference)

### 3. Adicionar Pastas Organizadas

#### Adicionar Pasta Views
1. Clique com botão direito em `PI_Japao` (pasta azul)
2. Selecione "Add Files to PI_Japao..."
3. Navegue até `PI_Japao/Views/`
4. **Importante**: 
   - Marque "Create groups" (não "Create folder references")
   - Marque "Add to targets: PI_Japao"
   - Clique em "Add"

#### Adicionar Pasta ViewModels
1. Repita o processo para `PI_Japao/ViewModels/`

#### Adicionar Pasta Services
1. Repita o processo para `PI_Japao/Services/`

#### Adicionar Pasta Models
1. Adicione o arquivo `PI_Japao/Models.swift`

#### Adicionar Pasta Resources
1. Adicione a pasta `PI_Japao/Resources/` (esta pode ser "Create folder references")

### 4. Verificar Estrutura Final

O projeto deve ter esta estrutura no Xcode:

```
PI_Japao
├── PI_JapaoApp.swift
├── Models
│   └── Models.swift
├── Views
│   ├── ContentView.swift
│   ├── DashboardView.swift
│   ├── BeaconsViews.swift
│   ├── StudentsViews.swift
│   ├── HistoryView.swift
│   └── SettingsView.swift
├── ViewModels
│   ├── AttendanceManager.swift
│   ├── BeaconViewModel.swift
│   ├── StudentViewModel.swift
│   ├── DashboardViewModel.swift
│   ├── HistoryViewModel.swift
│   └── SettingsViewModel.swift
├── Services
│   ├── APIService.swift
│   └── BeaconScannerService.swift
└── Resources
    └── Assets.xcassets
```

### 5. Verificar Build Settings

1. Selecione o projeto no navegador
2. Vá em "Build Settings"
3. Verifique que "Swift Language Version" está como "Swift 5" ou superior

### 6. Limpar e Recompilar

1. Menu: Product → Clean Build Folder (Shift+Cmd+K)
2. Menu: Product → Build (Cmd+B)

### 7. Verificar Erros

Se houver erros de import:
- Verifique que todos os arquivos estão no target correto
- Verifique que os grupos estão criados corretamente (pastas amarelas, não azuis)

## Estrutura de Grupos vs Pastas

- **Grupos (amarelos)**: Organização lógica no Xcode, arquivos podem estar em qualquer lugar
- **Pastas (azuis)**: Referências a pastas físicas no sistema de arquivos

Para este projeto, use **grupos** para Views, ViewModels, Services e Models.

## Troubleshooting

### Arquivos não aparecem
- Verifique que marcou "Add to targets: PI_Japao"
- Verifique que os arquivos existem fisicamente no sistema de arquivos

### Erros de compilação
- Limpe o build folder (Shift+Cmd+K)
- Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Reabra o projeto

### Imports não funcionam
- Verifique que os arquivos estão no mesmo target
- Verifique que não há duplicatas

