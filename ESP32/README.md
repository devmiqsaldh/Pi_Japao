# Integração ESP32 com Sistema de Presença

Este guia explica como conectar a placa ESP32 ao sistema de presença escolar.

## Hardware Necessário

- ESP32 (qualquer modelo: ESP32-WROOM, ESP32-DevKit, etc.)
- Módulo Bluetooth Low Energy (BLE) - já integrado no ESP32
- Fonte de alimentação adequada (USB ou externa)
- Beacons BLE (iBeacon ou Eddystone)

## Arquitetura

```
Beacon BLE → ESP32 (detecta) → Backend API → App iOS → Notificação aos Pais
```

## Fluxo de Funcionamento

1. **ESP32 escaneia beacons BLE** na área próxima
2. **Quando detecta um beacon**, verifica se está na lista de beacons conhecidos
3. **Envia detecção para o backend** via HTTP POST
4. **Backend processa** e envia notificações aos pais

## Configuração do ESP32

### 1. Instalar Bibliotecas

No Arduino IDE ou PlatformIO, instale:
- `BLEDevice.h` (já incluído no ESP32)
- `WiFi.h` (para conexão HTTP)
- `HTTPClient.h` (para requisições HTTP)
- `ArduinoJson.h` (para JSON)

### 2. Configurar WiFi

Edite o arquivo `esp32_beacon_scanner.ino` com suas credenciais WiFi:
```cpp
const char* ssid = "SEU_WIFI_SSID";
const char* password = "SUA_SENHA_WIFI";
```

### 3. Configurar URL do Backend

```cpp
const char* backendURL = "http://SEU_IP:8080/api/detections";
```

## Como Funciona

1. ESP32 escaneia beacons a cada 5 segundos
2. Quando detecta um beacon com UUID conhecido, envia para o backend
3. Backend verifica se o beacon está cadastrado e processa a detecção
4. Se estiver dentro da janela de tempo, envia notificação aos pais

## Cadastro de Beacons

### Opção 1: Via App iOS (Recomendado)

1. Abra o app iOS
2. Vá na aba **"Beacons"**
3. Toque no botão **"+"** (Adicionar)
4. Preencha:
   - **ID do Beacon**: UUID do beacon (ex: `550e8400-e29b-41d4-a716-446655440000`)
   - **Nome**: Nome descritivo (ex: "Beacon Aluno João")
   - **Ativo**: Toggle para ativar/desativar
5. Toque em **"Salvar"**

### Opção 2: Via API REST

```bash
curl -X POST http://localhost:8080/api/beacons \
  -H "Content-Type: application/json" \
  -d '{
    "beaconID": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Beacon Aluno João",
    "isActive": true
  }'
```

## Associar Beacon a Aluno

1. No app iOS, vá na aba **"Alunos"**
2. Toque no botão **"+"** (Adicionar)
3. Preencha:
   - **Nome do Aluno**: Nome completo
   - **Email**: Email do responsável (opcional)
   - **Telefone**: Telefone do responsável (opcional)
   - **Beacon**: Selecione o beacon cadastrado
4. Toque em **"Salvar"**

## Testando

1. Certifique-se que o backend está rodando
2. Cadastre um beacon no app
3. Associe o beacon a um aluno
4. Ligue o ESP32 próximo ao beacon
5. Verifique os logs do backend para confirmar a detecção

## Troubleshooting

### ESP32 não detecta beacons
- Verifique se o BLE está habilitado
- Confirme que o beacon está transmitindo
- Verifique a distância (máximo ~10 metros)

### Detecções não chegam ao backend
- Verifique conexão WiFi do ESP32
- Confirme URL do backend está correta
- Verifique logs do ESP32 via Serial Monitor

### Backend retorna erro 404
- Confirme que o beaconID está correto
- Verifique se o beacon foi cadastrado no sistema
- Confirme formato UUID válido

