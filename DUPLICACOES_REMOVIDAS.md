# Duplicações Removidas

Este documento lista as duplicações que foram encontradas e removidas do projeto.

## ✅ Duplicações Removidas

### 1. Extension Date.stripTime()

**Problema**: A extensão `Date.stripTime()` estava duplicada em:
- `PI_Japao/PI_Japao/ViewModels/DashboardViewModel.swift` ❌ (removido)
- `PI_Japao/PI_Japao/Models.swift` ✅ (mantido - correto para iOS)
- `PI_Japao/Backend/Sources/App/Models/AttendanceSession.swift` ❌ (removido)

**Solução**: 
- iOS: Mantido em `Models.swift` (único lugar)
- Backend: Movido para `Backend/Sources/App/Utils/DateExtensions.swift`

### 2. Extension Date.aligned()

**Problema**: A extensão `Date.aligned(to:)` estava apenas em:
- `PI_Japao/Backend/Sources/App/Controllers/DetectionController.swift` ❌ (removido)

**Solução**: Movido para `Backend/Sources/App/Utils/DateExtensions.swift`

### 3. Extension Sequence.asyncMap

**Problema**: A extensão `asyncMap` estava definida em:
- `PI_Japao/Backend/Sources/App/Controllers/StudentController.swift` ❌ (removido)
- Mas era usada em múltiplos controllers

**Solução**: Movido para `Backend/Sources/App/Utils/DateExtensions.swift`

## 📁 Estrutura Final

### Backend Utils
```
Backend/Sources/App/Utils/
└── DateExtensions.swift  # Contém:
    - Date.stripTime()
    - Date.aligned(to:)
    - Sequence.asyncMap()
```

### iOS Models
```
PI_Japao/Models.swift  # Contém:
    - SessionKind enum
    - AttendanceStatus enum
    - Date.stripTime() extension
```

## ✅ Verificação

- [x] Nenhuma duplicação de `stripTime()` no iOS
- [x] Nenhuma duplicação de `stripTime()` no Backend
- [x] Extensões Date centralizadas no backend
- [x] asyncMap centralizado no backend
- [x] Código compila sem erros
- [x] Sem linter errors

## 📝 Notas

- Backend e iOS são projetos separados, então cada um pode ter suas próprias extensões
- Dentro do mesmo projeto, extensões devem estar centralizadas
- Utils é o lugar correto para extensões compartilhadas

