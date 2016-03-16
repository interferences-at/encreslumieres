/**
 * Reads a force sensor and broadcasts its value via OSC on a Wifi network.
 * This code is for the ESP8266 wifi device.
 * @author Louis-Robert Bouchard
 * @date 2016-03-16
 */
#include <mem.h>
#include <ESP8266WiFi.h>
#include <WiFiUDP.h>
#include <OSCMessage.h>
#include <OSCBundle.h>
    
// WiFi parameters
long sendCount = 0;
const char* ssid = "Westside-FU124";
const char* password = "Betterave$pasFine122";
int valueSendi = 0;
int lastValue = 0;
boolean isUp = true;
IPAddress ip;

WiFiUDP Udp;
// const IPAddress outIp(192, 168, 0, 102);
const unsigned int outPort = 31340;
    
void setup(void)
{ 
    // Start Serial
    Serial.begin(115200);
    // Connect to WiFi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
    }
    Serial.println("");
    Serial.println("WiFi connected");
    // Print the IP address
    Serial.println(WiFi.localIP());
    // Broadcast IP is the same as our local IP,
    // but we replace the last number by 255
    // Example: 192.168.0.255
    ip = WiFi.localIP();
    ip[3] = 255;
}
   
void loop()
{
    valueSendi = analogRead(A0);
    if (lastValue != valueSendi)
    {
        OSCMessage msg("/force");
        msg.add(valueSendi);
        Udp.beginPacket(ip, outPort);
        msg.send(Udp);
        Udp.endPacket();
        msg.empty();
   }
   lastValue = valueSendi;
   delay(30);  
}
