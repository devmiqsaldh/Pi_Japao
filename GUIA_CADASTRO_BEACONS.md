# Guia Completo: Cadastro de Beacons

Este guia explica passo a passo como cadastrar novos beacons no sistema.

## 📋 Pré-requisitos

1. **Backend rodando**: O servidor Swift Vapor deve estar em execução
2. **App iOS configurado**: App deve estar conectado ao backend
3. **UUID do Beacon**: Você precisa do UUID do seu beacon BLE

## 🔍 Como Obter o UUID do Beacon

### Opção 1: Usando App no iPhone/iPad
1. Instale um app de scanner BLE (ex: "BLE Scanner", "nRF Connect")
2. Abra o app e inicie o scan
3. Procure pelo seu beacon na lista
4. O UUID aparecerá no formato: `550e8400-e29b-41d4-a716-446655440000`

### Opção 2: Usando ESP32
1. Carregue o código `esp32_beacon_scanner.ino` no ESP32
2. Abra o Serial Monitor (115200 baud)
3. O ESP32 mostrará os UUIDs dos beacons detectados

### Opção 3: Usando Android
1. Instale "Beacon Scanner" ou "nRF Connect"
2. Escaneie e encontre seu beacon
3. Copie o UUID exibido

## 📱 Cadastro via App iOS

### Passo 1: Abrir a Tela de Beacons
1. Abra o app iOS
2. Vá para a aba **"Beacons"** (ícone de antena)

### Passo 2: Adicionar Novo Beacon
1. Toque no botão **"+"** no canto superior direito
2. Preencha o formulário:
   - **ID do Beacon**: Cole o UUID completo do beacon
     - Formato: `550e8400-e29b-41d4-a716-446655440000`
     - Deve ser um UUID válido (36 caracteres com hífens)
   - **Nome**: Nome descritivo (ex: "Beacon Aluno João Silva")
   - **Ativo**: Deixe marcado para ativar o beacon
3. Toque em **"Salvar"**

### Passo 3: Verificar Cadastro
- O beacon aparecerá na lista de beacons
- Você pode editar ou desativar depois

## 🔗 Associar Beacon a Aluno

### Passo 1: Cadastrar Aluno
1. Vá para a aba **"Alunos"** no app
2. Toque no botão **"+"** para adicionar
3. Preencha:
   - **Nome do Aluno**: Nome completo
   - **Email**: Email do responsável (opcional, mas recomendado)
   - **Telefone**: Telefone do responsável (opcional, mas recomendado)
   - **Beacon**: Selecione o beacon cadastrado no passo anterior
4. Toque em **"Salvar"**

### Passo 2: Verificar Associação
- O aluno aparecerá na lista com o beacon associado
- Você pode editar ou remover depois

## 🌐 Cadastro via API REST

Se preferir usar a API diretamente:

### Cadastrar Beacon
```bash
curl -X POST http://localhost:8080/api/beacons \
  -H "Content-Type: application/json" \
  -d '{
    "beaconID": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Beacon Aluno João Silva",
    "isActive": true
  }'
```

### Cadastrar Aluno
```bash
# Primeiro, obtenha o UUID do beacon cadastrado
curl http://localhost:8080/api/beacons

# Depois, cadastre o aluno usando o beaconID (UUID do beacon)
curl -X POST http://localhost:8080/api/students \
  -H "Content-Type: application/json" \
  -d '{
    "name": "João Silva",
    "email": "pai.joao@email.com",
    "phone": "+5511999999999",
    "beaconID": "UUID_DO_BEACON_AQUI"
  }'
```

## ✅ Fluxo Completo de Cadastro

```
1. Obter UUID do Beacon
   ↓
2. Cadastrar Beacon no App/API
   ↓
3. Cadastrar Aluno associado ao Beacon
   ↓
4. Configurar horários de presença/saída (aba Configurações)
   ↓
5. ESP32 detecta beacon e envia para backend
   ↓
6. Backend processa e envia notificação aos pais
```

## 🔧 Gerenciamento de Beacons

### Editar Beacon
1. Na lista de beacons, toque no beacon desejado
2. Altere os campos necessários
3. Toque em **"Salvar"**

### Ativar/Desativar Beacon
1. Na lista de beacons, use o toggle **"Ativo"**
2. Beacons desativados não serão processados pelo sistema

### Deletar Beacon
1. Na lista de beacons, deslize para a esquerda
2. Toque em **"Deletar"**
3. ⚠️ **Atenção**: Isso também removerá associações com alunos

## 📊 Verificar Detecções

### Via App
1. Vá para a aba **"Histórico"**
2. Veja as sessões de presença/saída
3. Toque em uma sessão para ver detalhes

### Via Backend Logs
Quando o ESP32 detecta um beacon, o backend mostra logs:
```
📧 EMAIL -> pai.joao@email.com: Presença registrada para João Silva às 08:15.
📱 SMS -> +5511999999999: Presença registrada para João Silva às 08:15.
```

## 🐛 Troubleshooting

### Beacon não aparece no scan
- Verifique se o beacon está ligado e transmitindo
- Confirme que o BLE está habilitado no dispositivo
- Verifique a distância (máximo ~10 metros)

### UUID inválido
- Confirme formato: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- Use apenas letras minúsculas e números
- Verifique se não há espaços extras

### Beacon cadastrado mas não detectado
- Verifique se o beacon está **Ativo** no app
- Confirme que há um aluno associado ao beacon
- Verifique se está dentro da janela de tempo configurada

### Detecção não envia notificação
- Verifique se o aluno tem email ou telefone cadastrado
- Confirme que está dentro do horário de presença/saída
- Verifique logs do backend para erros

## 💡 Dicas

1. **Nomenclatura**: Use nomes descritivos como "Beacon Aluno João Silva" para facilitar identificação
2. **Teste**: Sempre teste o cadastro antes de usar em produção
3. **Backup**: Mantenha uma lista dos UUIDs dos beacons cadastrados
4. **Organização**: Agrupe beacons por turma ou série no nome
5. **Validação**: Sempre valide o UUID antes de cadastrar

## 📞 Suporte

Se tiver problemas:
1. Verifique os logs do backend
2. Verifique os logs do ESP32 (Serial Monitor)
3. Confirme que todos os serviços estão rodando
4. Verifique conectividade de rede

