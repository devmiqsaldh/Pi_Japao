# 🔌 Como Configurar o ESP32-WROOM-32 com Beacons

Este guia detalhado explica como conectar o ESP32-WROOM-32 ao sistema de presença escolar.

## 📦 Materiais Necessários

- ESP32-WROOM-32 (qualquer variante)
- Cabo USB para programação
- Beacons BLE (iBeacon ou Eddystone)
- Computador com Arduino IDE
- Rede WiFi 2.4GHz

## 🔧 Passo 1: Instalar Arduino IDE e Suporte ESP32

### 1.1 Baixar Arduino IDE
1. Acesse: https://www.arduino.cc/en/software
2. Baixe e instale a versão para seu sistema operacional

### 1.2 Adicionar Suporte para ESP32

1. Abra Arduino IDE
2. Vá em **File → Preferences**
3. Em **"Additional Board Manager URLs"**, adicione:
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
4. Clique em **OK**

### 1.3 Instalar Placa ESP32

1. Vá em **Tools → Board → Boards Manager**
2. Procure por **"esp32"**
3. Instale **"esp32 by Espressif Systems"**
4. Aguarde a instalação (pode demorar alguns minutos)

### 1.4 Instalar Bibliotecas

1. Vá em **Sketch → Include Library → Manage Libraries**
2. Instale:
   - **ArduinoJson** (versão 6.x ou superior)
   - **BLE** (geralmente já vem com ESP32)

## 📝 Passo 2: Configurar o Código

### 2.1 Abrir o Código

1. No Arduino IDE, abra: `PI_Japao/ESP32/esp32_beacon_scanner.ino`

### 2.2 Editar Configurações WiFi

Encontre as linhas 21-22 e edite:

```cpp
const char* ssid = "NOME_DO_SEU_WIFI";        // ← Coloque o nome da sua rede
const char* password = "SENHA_DO_WIFI";        // ← Coloque a senha do WiFi
```

**Importante**: 
- ESP32 só funciona com WiFi 2.4GHz (não suporta 5GHz)
- Certifique-se de que o WiFi está na mesma rede onde o backend está rodando

### 2.3 Configurar URL do Backend

Encontre a linha 25 e edite:

```cpp
const char* backendURL = "http://192.168.1.50:8080/api/detections";
```

**Como descobrir o IP do seu computador:**

**Mac/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```
Procure por algo como: `inet 192.168.1.50`

**Windows:**
```bash
ipconfig
```
Procure por "IPv4 Address" (geralmente algo como `192.168.1.50`)

**Exemplo:**
- Se seu IP for `192.168.1.50`, use: `http://192.168.1.50:8080/api/detections`
- Se seu IP for `192.168.0.100`, use: `http://192.168.0.100:8080/api/detections`

### 2.4 Ajustar Intervalos (Opcional)

Linhas 31-34:

```cpp
const int scanInterval = 5;    // Tempo entre scans (segundos)
const int scanDuration = 2;    // Duração de cada scan (segundos)
```

**Recomendações:**
- `scanInterval`: 5-10 segundos (mais rápido = mais bateria)
- `scanDuration`: 2-3 segundos (mais longo = mais detecções)

## 🔌 Passo 3: Fazer Upload para ESP32

### 3.1 Conectar ESP32

1. Conecte o ESP32 ao computador via cabo USB
2. Aguarde o sistema reconhecer o dispositivo

### 3.2 Configurar Porta e Placa

No Arduino IDE:

1. **Tools → Board → ESP32 Arduino → ESP32 Dev Module**
2. **Tools → Port →** Selecione a porta do ESP32
   - Mac: geralmente `/dev/cu.usbserial-XXXX` ou `/dev/cu.SLAB_USBtoUART`
   - Windows: geralmente `COM3`, `COM4`, etc.
   - Linux: geralmente `/dev/ttyUSB0` ou `/dev/ttyACM0`
3. **Tools → Upload Speed → 115200**

### 3.3 Fazer Upload

1. Clique no botão **Upload** (seta para a direita) ou pressione `Ctrl+U` (Windows/Linux) / `Cmd+U` (Mac)
2. Aguarde a compilação
3. Durante o upload, você pode precisar pressionar o botão **BOOT** no ESP32
4. Aguarde a mensagem "Done uploading"

## ✅ Passo 4: Verificar Funcionamento

### 4.1 Abrir Serial Monitor

1. Vá em **Tools → Serial Monitor**
2. Configure para **115200 baud** (canto inferior direito)
3. Você deve ver:

```
========================================
  ESP32 Beacon Scanner
  Sistema de Presença Escolar
========================================

📶 Conectando ao WiFi: SEU_WIFI
✅ WiFi conectado!
📡 IP: 192.168.1.XXX

🔵 Inicializando BLE...
✅ BLE inicializado!

🔍 Iniciando escaneamento de beacons...

📊 Dispositivos encontrados: X
```

### 4.2 Testar Detecção

1. Coloque um beacon BLE próximo ao ESP32 (dentro de ~10 metros)
2. No Serial Monitor, você deve ver:

```
🔍 Beacon detectado: 550e8400-e29b-41d4-a716-446655440000 (RSSI: -45 dBm)
📤 Enviando detecção para backend: 550e8400-e29b-41d4-a716-446655440000
📦 Payload: {"beaconID":"550e8400-e29b-41d4-a716-446655440000","timestamp":"..."}
✅ Resposta do servidor: 200
📥 Resposta: {"success":true,"message":"Detecção processada...","beaconID":"..."}
✅ Detecção processada com sucesso!
```

## 🔍 Passo 5: Obter UUID dos Beacons

### Opção 1: Via Serial Monitor do ESP32

1. Com o ESP32 rodando, coloque o beacon próximo
2. No Serial Monitor, aparecerá o UUID quando detectar
3. Copie o UUID completo

### Opção 2: Via App no iPhone/iPad

1. Instale "nRF Connect" ou "BLE Scanner" da App Store
2. Abra o app e toque em "Scan"
3. Procure seu beacon na lista
4. Toque no beacon para ver detalhes
5. Copie o UUID (formato: `550e8400-e29b-41d4-a716-446655440000`)

### Opção 3: Via Android

1. Instale "nRF Connect" ou "Beacon Scanner"
2. Abra e inicie o scan
3. Procure seu beacon e copie o UUID

## 📱 Passo 6: Cadastrar Beacon no App

1. No app iOS, vá em **Beacons**
2. Toque no botão **+** (Adicionar)
3. Preencha:
   - **ID do Beacon**: Cole o UUID completo do beacon
   - **Nome**: Nome descritivo (ex: "Beacon Aluno João")
   - **Ativo**: Deixe marcado
4. Toque em **Salvar**

## 👥 Passo 7: Associar Beacon a Aluno

1. No app, vá em **Alunos**
2. Toque no botão **+** (Adicionar)
3. Preencha:
   - **Nome do Aluno**: Nome completo
   - **Email**: Email do responsável (opcional)
   - **Telefone**: Telefone do responsável (opcional)
   - **Beacon**: Selecione o beacon cadastrado
4. Toque em **Salvar**

## 🎯 Passo 8: Testar Sistema Completo

### Checklist:

- [ ] Backend rodando (`swift run` na pasta Backend)
- [ ] ESP32 conectado e Serial Monitor aberto
- [ ] WiFi conectado (verificar no Serial Monitor)
- [ ] Beacon cadastrado no app
- [ ] Aluno associado ao beacon
- [ ] Horários configurados (aba Configurações)
- [ ] Beacon próximo ao ESP32

### O Que Deve Acontecer:

1. **ESP32 detecta beacon** → Serial Monitor mostra UUID
2. **ESP32 envia para backend** → Serial Monitor mostra "Enviando detecção"
3. **Backend processa** → Logs do backend mostram mensagem sendo enviada
4. **App atualiza** → Histórico mostra a detecção

## 🐛 Problemas Comuns

### ESP32 não conecta ao WiFi

**Sintomas**: Serial Monitor mostra "Falha ao conectar WiFi"

**Soluções**:
- Verifique SSID e senha
- Confirme que WiFi é 2.4GHz (ESP32 não suporta 5GHz)
- Verifique distância do roteador
- Tente reiniciar o ESP32

### ESP32 não detecta beacons

**Sintomas**: Serial Monitor mostra "Dispositivos encontrados: 0"

**Soluções**:
- Verifique se o beacon está ligado e transmitindo
- Aproxime o beacon (máximo ~10 metros)
- Alguns beacons precisam ser "ativados" antes de transmitir
- Verifique se o beacon está em modo iBeacon ou Eddystone

### Detecções não chegam ao backend

**Sintomas**: Serial Monitor mostra erro ao enviar

**Soluções**:
- Verifique URL do backend no código
- Confirme que backend está rodando
- Teste a URL no navegador: `http://SEU_IP:8080`
- Verifique se ESP32 e computador estão na mesma rede
- Verifique firewall (pode estar bloqueando porta 8080)

### Backend retorna erro 404

**Sintomas**: Serial Monitor mostra "Erro no servidor: 404"

**Soluções**:
- Verifique se o beacon está cadastrado no app
- Confirme que o UUID está correto
- Verifique se o beacon está **Ativo** no app

### Beacon detectado mas não processado

**Sintomas**: Backend retorna sucesso mas não envia mensagem

**Soluções**:
- Verifique se há aluno associado ao beacon
- Confirme que está dentro da janela de tempo configurada
- Verifique se aluno tem email ou telefone cadastrado

## 📊 Monitoramento

### Serial Monitor do ESP32

Mantenha o Serial Monitor aberto para ver:
- Status da conexão WiFi
- Beacons detectados
- Tentativas de envio ao backend
- Respostas do servidor

### Logs do Backend

No terminal onde o backend está rodando, você verá:
- Requisições recebidas
- Mensagens enviadas (email/SMS)
- Erros (se houver)

## 💡 Dicas

1. **Posicionamento**: Coloque o ESP32 em local centralizado para melhor cobertura
2. **Alimentação**: Use fonte USB adequada (pelo menos 500mA)
3. **Antena**: Não cubra a antena do ESP32 (área sem componentes)
4. **Teste**: Sempre teste com um beacon antes de usar em produção
5. **Backup**: Mantenha uma lista dos UUIDs dos beacons cadastrados

## 🔄 Atualizar Código

Se precisar atualizar o código do ESP32:

1. Edite o arquivo `.ino`
2. Faça upload novamente (mesmo processo do Passo 3)
3. O ESP32 reiniciará automaticamente

## 📞 Suporte

Se tiver problemas:
1. Verifique os logs do Serial Monitor
2. Verifique os logs do backend
3. Consulte `CONFIGURACAO_COMPLETA.md` para guia completo
4. Verifique se todos os componentes estão configurados corretamente

