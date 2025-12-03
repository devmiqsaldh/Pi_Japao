/*
 * ESP32 Beacon Scanner
 * Sistema de Presença Escolar
 * 
 * Este código escaneia beacons BLE e envia detecções para o backend
 */

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// ============================================
// CONFIGURAÇÕES - EDITE AQUI
// ============================================

// WiFi
const char* ssid = "SEU_WIFI_SSID";
const char* password = "SUA_SENHA_WIFI";

// Backend API
const char* backendURL = "http://192.168.1.100:8080/api/detections";
// Nota: Use o IP local da máquina onde o backend está rodando
// Para descobrir: no Mac/Linux: ifconfig | grep inet
//                 no Windows: ipconfig

// Intervalo de escaneamento (em segundos)
const int scanInterval = 5;

// Duração do escaneamento (em segundos)
const int scanDuration = 2;

// ============================================
// VARIÁVEIS GLOBAIS
// ============================================

BLEScan* pBLEScan;
HTTPClient http;
WiFiClient client;

// Lista de beacons já detectados (para evitar spam)
// Em produção, use um sistema mais robusto (ex: EEPROM)
String lastDetectedBeacons[10];
int lastDetectedIndex = 0;
unsigned long lastDetectionTime[10];
const unsigned long DETECTION_COOLDOWN = 30000; // 30 segundos entre detecções do mesmo beacon

// ============================================
// CALLBACK DE DISPOSITIVOS DETECTADOS
// ============================================

class MyAdvertisedDeviceCallbacks: public BLEAdvertisedDeviceCallbacks {
    void onResult(BLEAdvertisedDevice advertisedDevice) {
        // Verificar se é um iBeacon
        if (advertisedDevice.haveManufacturerData()) {
            std::string manufacturerData = advertisedDevice.getManufacturerData();
            
            // iBeacon tem manufacturer data de 25 bytes
            // Bytes 0-1: Company ID (0x004C para Apple)
            // Bytes 2-3: iBeacon type (0x0215)
            // Bytes 4-19: UUID (16 bytes)
            // Bytes 20-21: Major
            // Bytes 22-23: Minor
            // Byte 24: TX Power
            
            if (manufacturerData.length() >= 25) {
                uint8_t* data = (uint8_t*)manufacturerData.data();
                
                // Verificar se é iBeacon (Apple Company ID + iBeacon type)
                if (data[0] == 0x4C && data[1] == 0x00 && 
                    data[2] == 0x02 && data[3] == 0x15) {
                    
                    // Extrair UUID
                    char uuid[37];
                    sprintf(uuid, "%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
                        data[4], data[5], data[6], data[7],
                        data[8], data[9], data[10], data[11],
                        data[12], data[13], data[14], data[15],
                        data[16], data[17], data[18], data[19]);
                    
                    // Converter para minúsculas
                    for (int i = 0; i < 36; i++) {
                        if (uuid[i] >= 'A' && uuid[i] <= 'F') {
                            uuid[i] = uuid[i] + 32;
                        }
                    }
                    
                    String beaconUUID = String(uuid);
                    int rssi = advertisedDevice.getRSSI();
                    
                    Serial.print("🔍 Beacon detectado: ");
                    Serial.print(beaconUUID);
                    Serial.print(" (RSSI: ");
                    Serial.print(rssi);
                    Serial.println(" dBm)");
                    
                    // Verificar se já detectamos recentemente (cooldown)
                    bool shouldReport = true;
                    unsigned long now = millis();
                    
                    for (int i = 0; i < 10; i++) {
                        if (lastDetectedBeacons[i] == beaconUUID) {
                            if (now - lastDetectionTime[i] < DETECTION_COOLDOWN) {
                                shouldReport = false;
                                Serial.println("⏳ Beacon detectado recentemente, aguardando cooldown...");
                            } else {
                                lastDetectionTime[i] = now;
                            }
                            break;
                        }
                    }
                    
                    if (shouldReport) {
                        // Adicionar à lista de detectados
                        lastDetectedBeacons[lastDetectedIndex] = beaconUUID;
                        lastDetectionTime[lastDetectedIndex] = now;
                        lastDetectedIndex = (lastDetectedIndex + 1) % 10;
                        
                        // Enviar para o backend
                        sendDetectionToBackend(beaconUUID, rssi);
                    }
                }
            }
        }
        
        // Também verificar se tem UUID no nome do serviço (Eddystone)
        if (advertisedDevice.haveServiceUUID()) {
            BLEUUID serviceUUID = advertisedDevice.getServiceUUID();
            String uuidString = String(serviceUUID.toString().c_str());
            
            // Se o UUID parece válido (formato UUID), enviar
            if (uuidString.length() == 36 && uuidString.indexOf('-') > 0) {
                Serial.print("🔍 Beacon Eddystone detectado: ");
                Serial.println(uuidString);
                
                // Verificar cooldown
                bool shouldReport = true;
                unsigned long now = millis();
                
                for (int i = 0; i < 10; i++) {
                    if (lastDetectedBeacons[i] == uuidString) {
                        if (now - lastDetectionTime[i] < DETECTION_COOLDOWN) {
                            shouldReport = false;
                        } else {
                            lastDetectionTime[i] = now;
                        }
                        break;
                    }
                }
                
                if (shouldReport) {
                    lastDetectedBeacons[lastDetectedIndex] = uuidString;
                    lastDetectionTime[lastDetectedIndex] = now;
                    lastDetectedIndex = (lastDetectedIndex + 1) % 10;
                    
                    sendDetectionToBackend(uuidString, advertisedDevice.getRSSI());
                }
            }
        }
    }
};

// ============================================
// FUNÇÃO PARA ENVIAR DETECÇÃO AO BACKEND
// ============================================

void sendDetectionToBackend(String beaconID, int rssi) {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("❌ WiFi não conectado!");
        return;
    }
    
    Serial.print("📤 Enviando detecção para backend: ");
    Serial.println(beaconID);
    
    http.begin(client, backendURL);
    http.addHeader("Content-Type", "application/json");
    
    // Criar JSON
    StaticJsonDocument<200> doc;
    doc["beaconID"] = beaconID;
    
    // Adicionar timestamp ISO 8601
    // Nota: ESP32 não tem RTC, então usamos timestamp relativo
    // O backend pode ajustar se necessário
    char timestamp[30];
    snprintf(timestamp, sizeof(timestamp), "2025-01-01T00:00:00Z");
    doc["timestamp"] = timestamp;
    
    String jsonPayload;
    serializeJson(doc, jsonPayload);
    
    Serial.print("📦 Payload: ");
    Serial.println(jsonPayload);
    
    int httpResponseCode = http.POST(jsonPayload);
    
    if (httpResponseCode > 0) {
        Serial.print("✅ Resposta do servidor: ");
        Serial.println(httpResponseCode);
        
        String response = http.getString();
        Serial.print("📥 Resposta: ");
        Serial.println(response);
        
        if (httpResponseCode == 200) {
            Serial.println("✅ Detecção processada com sucesso!");
        } else {
            Serial.print("⚠️ Erro no servidor: ");
            Serial.println(httpResponseCode);
        }
    } else {
        Serial.print("❌ Erro ao enviar requisição: ");
        Serial.println(httpResponseCode);
        Serial.print("Erro: ");
        Serial.println(http.errorToString(httpResponseCode));
    }
    
    http.end();
}

// ============================================
// SETUP
// ============================================

void setup() {
    Serial.begin(115200);
    delay(1000);
    
    Serial.println("\n\n");
    Serial.println("========================================");
    Serial.println("  ESP32 Beacon Scanner");
    Serial.println("  Sistema de Presença Escolar");
    Serial.println("========================================\n");
    
    // Conectar WiFi
    Serial.print("📶 Conectando ao WiFi: ");
    Serial.println(ssid);
    
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);
    
    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 20) {
        delay(500);
        Serial.print(".");
        attempts++;
    }
    
    if (WiFi.status() == WL_CONNECTED) {
        Serial.println("\n✅ WiFi conectado!");
        Serial.print("📡 IP: ");
        Serial.println(WiFi.localIP());
    } else {
        Serial.println("\n❌ Falha ao conectar WiFi!");
        Serial.println("Verifique suas credenciais e tente novamente.");
        return;
    }
    
    // Inicializar BLE
    Serial.println("\n🔵 Inicializando BLE...");
    BLEDevice::init("");
    
    // Criar scanner
    pBLEScan = BLEDevice::getScan();
    pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
    pBLEScan->setActiveScan(true); // Usar scan ativo para melhor detecção
    pBLEScan->setInterval(100);
    pBLEScan->setWindow(99);
    
    Serial.println("✅ BLE inicializado!");
    Serial.println("\n🔍 Iniciando escaneamento de beacons...\n");
}

// ============================================
// LOOP PRINCIPAL
// ============================================

void loop() {
    // Verificar conexão WiFi
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("⚠️ WiFi desconectado, tentando reconectar...");
        WiFi.reconnect();
        delay(5000);
        return;
    }
    
    // Escanear beacons
    BLEScanResults foundDevices = pBLEScan->start(scanDuration, false);
    
    Serial.print("📊 Dispositivos encontrados: ");
    Serial.println(foundDevices.getCount());
    
    // Limpar resultados
    pBLEScan->clearResults();
    
    // Aguardar antes do próximo scan
    delay(scanInterval * 1000);
}

