# 🚀 Guia Completo de Configuração - Sistema de Presença Escolar

Este guia explica passo a passo como configurar todo o sistema, incluindo o ESP32-WROOM-32.

## 📋 Pré-requisitos

- Mac ou PC com macOS/Windows/Linux
- Xcode (para desenvolvimento iOS)
- Swift instalado (vem com Xcode)
- Arduino IDE ou PlatformIO
- ESP32-WROOM-32
- Beacons BLE (iBeacon ou Eddystone)
- Rede WiFi

## 🔧 Parte 1: Configuração do Backend

### 1.1 Instalar Dependências

```bash
cd PI_Japao/Backend
swift package resolve
```

### 1.2 Executar o Backend

```bash
swift run
```

O servidor iniciará em `http://localhost:8080`

**Importante**: Anote o IP da sua máquina na rede local:
- **Mac/Linux**: `ifconfig | grep "inet " | grep -v 127.0.0.1`
- **Windows**: `ipconfig` (procure por "IPv4 Address")

Exemplo: Se o IP for `192.168.1.50`, você usará `http://192.168.1.50:8080`

### 1.3 Verificar se está Funcionando

Abra no navegador: `http://localhost:8080`

Deve aparecer: "Attendance API - Sistema de Presença Escolar"

## 📱 Parte 2: Configuração do App iOS

### 2.1 Abrir o Projeto

1. Abra `PI_Japao/PI_Japao.xcodeproj` no Xcode
2. Se os arquivos não aparecerem, siga `PI_Japao/CONFIGURAR_XCODE.md`

### 2.2 Configurar URL do Backend

1. Execute o app no simulador ou dispositivo
2. Vá em **Configurações** (última aba)
3. Na seção **Conexão**, configure:
   - **URL do Backend**: `http://SEU_IP:8080`
   - Exemplo: `http://192.168.1.50:8080`
4. Toque em **Salvar**

### 2.3 Adicionar Permissões de Localização

1. No Xcode, abra `Info.plist` (ou adicione via Target Settings)
2. Adicione as seguintes chaves:

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>O app precisa de acesso à localização para detectar beacons BLE</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>O app precisa de acesso à localização para detectar beacons BLE</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>O app precisa de acesso à localização para detectar beacons BLE</string>
```

### 2.4 Testar Conexão

1. No app, vá para **Dashboard**
2. Se aparecer um banner vermelho no topo, a conexão falhou
3. Verifique:
   - Backend está rodando?
   - URL está correta?
   - Dispositivo e computador estão na mesma rede WiFi?

## 🔌 Parte 3: Configuração do ESP32-WROOM-32

### 3.1 Instalar Arduino IDE e Bibliotecas

1. Baixe Arduino IDE: https://www.arduino.cc/en/software
2. Instale o suporte para ESP32:
   - File → Preferences
   - Em "Additional Board Manager URLs", adicione:
     ```
     https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
     ```
   - Tools → Board → Boards Manager
   - Procure por "ESP32" e instale

3. Instale bibliotecas necessárias:
   - Sketch → Include Library → Manage Libraries
   - Instale:
     - **ArduinoJson** (versão 6.x)
     - **BLE** (já vem com ESP32)

### 3.2 Configurar o Código

1. Abra `PI_Japao/ESP32/esp32_beacon_scanner.ino` no Arduino IDE

2. **Edite as configurações** (linhas 21-28):

```cpp
// WiFi
const char* ssid = "NOME_DO_SEU_WIFI";        // ← Edite aqui
const char* password = "SENHA_DO_WIFI";       // ← Edite aqui

// Backend API
const char* backendURL = "http://192.168.1.50:8080/api/detections";
// ↑ Substitua 192.168.1.50 pelo IP do seu computador
```

3. **Configure o IP do backend**:
   - Use o IP que você descobriu na Parte 1.2
   - Exemplo: Se seu IP é `192.168.1.50`, use `http://192.168.1.50:8080`

### 3.3 Fazer Upload para ESP32

1. Conecte o ESP32 ao computador via USB
2. No Arduino IDE:
   - Tools → Board → ESP32 Arduino → **ESP32 Dev Module**
   - Tools → Port → Selecione a porta do ESP32
   - Tools → Upload Speed → **115200**
3. Clique em **Upload** (seta para a direita)
4. Aguarde a compilação e upload

### 3.4 Verificar Funcionamento

1. Abra o **Serial Monitor** (Tools → Serial Monitor)
2. Configure para **115200 baud**
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
   ```

## 📡 Parte 4: Configuração dos Beacons

### 4.1 Obter UUID dos Beacons

**Opção 1: Usando App no iPhone**
1. Instale "nRF Connect" ou "BLE Scanner"
2. Abra o app e inicie o scan
3. Procure seu beacon na lista
4. Copie o UUID (formato: `550e8400-e29b-41d4-a716-446655440000`)

**Opção 2: Usando ESP32**
1. Com o ESP32 rodando, abra Serial Monitor
2. Quando detectar um beacon, aparecerá:
   ```
   🔍 Beacon detectado: 550e8400-e29b-41d4-a716-446655440000
   ```
3. Copie o UUID

### 4.2 Cadastrar Beacon no App

1. No app iOS, vá em **Beacons**
2. Toque no botão **+** (Adicionar)
3. Preencha:
   - **ID do Beacon**: Cole o UUID completo
   - **Nome**: Nome descritivo (ex: "Beacon Aluno João")
   - **Ativo**: Deixe marcado
4. Toque em **Salvar**

### 4.3 Associar Beacon a Aluno

1. No app, vá em **Alunos**
2. Toque no botão **+** (Adicionar)
3. Preencha:
   - **Nome do Aluno**: Nome completo
   - **Email**: Email do responsável (opcional)
   - **Telefone**: Telefone do responsável (opcional)
   - **Beacon**: Selecione o beacon cadastrado
4. Toque em **Salvar**

## ✅ Parte 5: Testar o Sistema Completo

### 5.1 Fluxo de Teste

1. **Backend rodando**: `swift run` na pasta Backend
2. **ESP32 conectado**: Serial Monitor mostrando "Iniciando escaneamento"
3. **App iOS aberto**: Dashboard mostrando beacons ativos
4. **Beacon próximo ao ESP32**: Coloque o beacon a ~5 metros do ESP32

### 5.2 O Que Deve Acontecer

1. ESP32 detecta o beacon
2. Serial Monitor mostra:
   ```
   🔍 Beacon detectado: UUID_DO_BEACON
   📤 Enviando detecção para backend: UUID_DO_BEACON
   ✅ Resposta do servidor: 200
   ✅ Detecção processada com sucesso!
   ```

3. Backend processa e envia mensagem:
   ```
   📧 EMAIL -> email@exemplo.com: Presença registrada para João Silva às 08:15.
   📱 SMS -> +5511999999999: Presença registrada para João Silva às 08:15.
   ```

4. No app iOS, vá em **Histórico** para ver a detecção registrada

## 🐛 Troubleshooting

### Backend não inicia
- Verifique se a porta 8080 está livre
- Execute: `lsof -i :8080` (Mac) ou `netstat -ano | findstr :8080` (Windows)
- Se estiver em uso, mate o processo ou mude a porta

### App não conecta ao backend
- Verifique se o IP está correto nas Configurações
- Confirme que backend está rodando
- Verifique se dispositivo e computador estão na mesma rede WiFi
- Teste a URL no navegador: `http://SEU_IP:8080`

### ESP32 não conecta ao WiFi
- Verifique SSID e senha
- Confirme que o WiFi está 2.4GHz (ESP32 não suporta 5GHz)
- Verifique distância do roteador

### ESP32 não detecta beacons
- Verifique se o beacon está ligado e transmitindo
- Confirme que o beacon está próximo (máximo ~10 metros)
- Verifique se o UUID está correto
- Alguns beacons precisam ser "ativados" antes de transmitir

### Detecções não chegam ao backend
- Verifique URL do backend no código ESP32
- Confirme que backend está acessível na rede
- Teste: `curl http://SEU_IP:8080/api/beacons` (deve retornar JSON)

### Beacon detectado mas não processado
- Verifique se o beacon está cadastrado no app
- Confirme que o beacon está **Ativo**
- Verifique se há um aluno associado ao beacon
- Confirme que está dentro da janela de tempo configurada

## 📞 Suporte Adicional

Para mais informações:
- **Estrutura do Projeto**: `PI_Japao/ESTRUTURA_PROJETO.md`
- **Cadastro de Beacons**: `PI_Japao/GUIA_CADASTRO_BEACONS.md`
- **Backend**: `PI_Japao/Backend/README.md`
- **ESP32**: `PI_Japao/ESP32/README.md`

## 🎯 Checklist Final

- [ ] Backend rodando e acessível
- [ ] App iOS configurado com URL correta
- [ ] Permissões de localização adicionadas
- [ ] ESP32 conectado ao WiFi
- [ ] ESP32 configurado com IP do backend
- [ ] Beacons cadastrados no app
- [ ] Alunos associados aos beacons
- [ ] Horários configurados
- [ ] Teste completo realizado com sucesso

