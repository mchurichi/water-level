#include <ArduinoJson.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <FS.h>
#include "Ultrasonic.h"

using namespace std;

#define TRIG_PIN    16
#define ECHO_PIN    05

Ultrasonic ultrasonic(16, 5, 24000);
char* ssid = "";
char* password = "";
char* serviceName = "water-level";
char* serviceProtocol = "tcp";
ESP8266WebServer webServer(80);

unsigned long lastStatus;
unsigned long statusInterval = 5000;

bool wifiStatus = false;
bool httpStatus = false;
bool mdnsStatus = false; 

void connectWifi(char*, char*);
void setupWebServer();
void setupMDNS();
void checkStatusInterval();
void logStatus();
void handleRoot();
void handleNotFound();
void handleGetDistance();

void setup() {
  Serial.begin(9600);
  connectWifi(ssid, password);
  setupWebServer();
  setupMDNS();
  lastStatus = millis();
}

void loop() {
  webServer.handleClient();
  checkStatusInterval();
}

void checkStatusInterval() {
  if (millis() > lastStatus + statusInterval) {
    logStatus();
    lastStatus = millis();
  }
}

void logStatus() {
  Serial.println("===== Status =====");
  Serial.print("Uptime: ");
  Serial.println(millis());
  Serial.print("Wifi: ");
  Serial.println(wifiStatus ? "ON" : "OFF");
  if (wifiStatus) {
    Serial.print("    SSID: ");
    Serial.println(ssid);
    Serial.print("    IP Address: ");
    Serial.println(WiFi.localIP());
  }
  Serial.print("HTTP: ");
  Serial.println(httpStatus ? "ON" :  "OFF");
  Serial.print("MDNS: ");
  Serial.println(mdnsStatus ? "ON" : "OFF");
  if (mdnsStatus) {
    Serial.print("    Registered as: _");
    Serial.print(serviceName);
    Serial.print("._");
    Serial.println(serviceProtocol);
  }
}

void setupMDNS() {
  if (!MDNS.begin("water-level", WiFi.localIP())) {
    Serial.println("Error setting up MDNS responder!");
  } else {
    Serial.println("MDNS Server added!");
    MDNS.addService(serviceName, serviceProtocol, 80);
    mdnsStatus = true;
  }
}

void setupWebServer() {
  webServer.on("/", handleRoot);
  webServer.on("/distance", handleGetDistance);
  webServer.onNotFound(handleNotFound);
  webServer.begin();

  Serial.println("HTTP server started");
  httpStatus = true;
}

void handleRoot() {
  webServer.send(200, "application/json", "{\"success\": true}");
}

void handleNotFound() {
  webServer.send(404, "application/json", "{\"success\": false, \"error\": \"Resource not found\"}");
}

void handleGetDistance() {
  long distanceInCm = ultrasonic.Ranging(CM);
  String distance = String(distanceInCm);

  webServer.send(200, "application/json", "{\"distance\": " + distance + "}");
}

void connectWifi(char* ssid, char* password) {
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");

  Serial.println(WiFi.localIP());
  wifiStatus = true;
}