#include <EducationShield.h>

BLEuart uart=BLEuart();

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

  // Curie BLE setup
  // set advertised local name
  uart.setName("CutomControl");
  uart.begin();
}

void loop() {
  // put your main code here, to run repeatedly:
  if(uart.searchCentral()){
    Serial.println("Connected to central ");
    while(uart.connected()){

      //If data is sent through BLE to 101 board
      if(uart.dataReceived()){
        //Fetch all data from BLE
        uart.fetchData();

        //Read the 1 byte data received
        unsigned char data=uart.getValueAt(0);
        Serial.println(data);
      }
    }
    Serial.println(F("Disconnected from central "));

  }
}