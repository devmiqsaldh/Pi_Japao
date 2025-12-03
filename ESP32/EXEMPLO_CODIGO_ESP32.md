# Exemplo Simplificado para ESP32

Se você quiser um código mais simples para começar, aqui está uma versão básica:

## Código Básico

```cpp
#include <BLEDevice.h>
#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "SEU_WIFI";
const char* password = "SUA_SENHA";
const char* backendURL = "http://192.168.1.100:8080/api/detections";

void setup() {
  Serial.begin(115200);
  
  // Conectar WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi conectado!");
  
  // Inicializar BLE
  BLEDevice::init("");
  BLEScan* pBLEScan = BLEDevice::getScan();
  pBLEScan->start(2, false);
}

void loop() {
  // Escanear beacons
  BLEScanResults devices = BLEDevice::getScan()->start(2, false);
  
  for (int i = 0; i < devices.getCount(); i++) {
    BLEAdvertisedDevice device = devices.get(i);
    
    // Verificar se tem UUID
    if (device.haveServiceUUID()) {
      String uuid = String(device.getServiceUUID().toString().c_str());
      
      // Enviar para backend
      HTTPClient http;
      http.begin(backendURL);
      http.addHeader("Content-Type", "application/json");
      
      String json = "{\"beaconID\":\"" + uuid + "\"}";
      http.POST(json);
      http.end();
    }
  }
  
  delay(5000); // Aguardar 5 segundos
}
```

## Configuração Rápida

1. **Edite as configurações** no início do código:
   - `ssid`: Nome da sua rede WiFi
   - `password`: Senha do WiFi
   - `backendURL`: IP do seu computador + porta 8080

2. **Descubra o IP do backend**:
   - Mac/Linux: `ifconfig | grep inet`
   - Windows: `ipconfig`
   - Procure por algo como `192.168.1.100`

3. **Carregue o código** no ESP32

4. **Abra o Serial Monitor** (115200 baud) para ver os logs

## Testando

1. Certifique-se que o backend está rodando
2. Cadastre um beacon no app iOS
3. Coloque o ESP32 próximo ao beacon
4. Veja os logs no Serial Monitor
5. Verifique os logs do backend

