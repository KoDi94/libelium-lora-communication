/*
 *  ------ [4-20mA_03] Several Sensor --------
 */

// Include this library for using current loop functions
#include <currentLoop.h>
#include <WaspLoRaWAN.h>
#include <WaspFrame.h>
#include <WaspUtils.h>
#include <stdlib.h> 

// Instantiate currentLoop object in channel 1.
#define TEMPERATURE CHANNEL1
#define MANOMETRO CHANNEL2
#define GAS CHANNEL3

using namespace std;

uint8_t socket = SOCKET0;
uint8_t error;
uint8_t PORT =3;

char* data;
char sensors[] = {TEMPERATURE, MANOMETRO, GAS};
char* libeliumPrefix = "ffff";
char* cutData = "";
int i;

float current = 13.583512746;

// Get the sensor value as a current in mA from SOCKETS
float current_socket;


void setup(){
  libeliumModuleInfo();
  lorawanSetUp();
}

void loop(){ 
  strcpy(cutData, "");
  strcpy(cutData, libeliumPrefix);
  for(i = 0; i <= sizeof(sensors)-1; i++){
    if (currentLoopBoard.isConnected(sensors[i])){
      current_socket = currentLoopBoard.readCurrent(sensors[i]);
      floatToHex(current_socket, cutData);
    }else{
      //add 0000 to payload
      USB.println("Sensor not connected...");
    }   
  }
//  strcpy(libeliumPrefix, "");
//  switchOn();
//  joinNetworkABP();
//  switchOff();
  USB.println("***************************************");
  USB.print("\n");
  // Delay after reading.
  delay(10000);
}

/*
 * ========================================
 * Convert mA to Hex
 * ========================================
 */
void floatToHex(float sensorSocket, char* cutData){
  char buffer[] = "0000";
  char extraZero[] = "0";
  char* hexValue;
  char* finalPayload;
  
  USB.print("Socket Sensor: ");
  USB.print(sensorSocket);
  USB.println(" mA");
  
  sensorSocket = round(sensorSocket * 100);

  if(sensorSocket <= 4095){
    USB.println("Value lower than 4095");
    utoa(sensorSocket, buffer, 16);
    hexValue = strcat(extraZero, buffer);
    USB.println("-------------HEX VALUE-------------");
    USB.println(hexValue);
//    finalPayload = strcat(libeliumPrefix, hexValue);
//    USB.println("FINAL PAYLOAD: ");
//    USB.println(finalPayload);
  }else{
    utoa(sensorSocket, buffer, 16);
    hexValue = buffer;
    USB.println("Value greater than 4095");
    USB.println(hexValue);
  }
  strcat(cutData, hexValue);
  USB.println(cutData);
}

/*
 * ========================================
 * Libelium Info module
 * ========================================
 */
void libeliumModuleInfo(){
  // Power on the USB for viewing data in the USB monitor
  USB.ON();
  delay(100);  

  error = LoRaWAN.ON(socket);

  // Check status
  if(error == 0){
    USB.println(F("Switch ON OK"));
  }else {
    USB.print(F("Switch ON error = ")); 
    USB.println(error, DEC);
  }

  if(LoRaWAN._version == RN2483_MODULE){
    USB.println("LoRaWAN VERSION: RN2483_MODULE");
    USB.println(F("========================================--------"));
    USB.println(F("    EU         433 MHz     IN         ASIA-PAC / LATAM"));
    USB.println(F("0:  N/A         10 dBm     20 dBm     20 dBm"));
    USB.println(F("1:  14 dBm       7 dBm     18 dBm     18 dBm"));
    USB.println(F("2:  11 dBm       4 dBm     16 dBm     16 dBm"));
    USB.println(F("3:   8 dBm       1 dBm     14 dBm     14 dBm"));
    USB.println(F("4:   5 dBm      -2 dBm     12 dBm     12 dBm"));
    USB.println(F("5:   2 dBm      -5 dBm     10 dBm     10 dBm"));
    USB.println(F("--------\n"));
  }else{
    USB.println("Something else...");
  }
  
  // Sets the 5V switch ON
  USB.println("Opening 5V for internal power supply...");
  currentLoopBoard.ON(SUPPLY5V);
  delay(3000);

  USB.println("Closing 12V power supply...");
  // Sets the 12V switch ON
  currentLoopBoard.OFF(SUPPLY12V); 
  delay(3000); 

  // Get the EUI address of the Libelium module
  LoRaWAN.getEUI();
  USB.println("------------------");
  USB.println("Libelium Module EUI");
  USB.println(LoRaWAN._eui);
  USB.println("------------------");
  USB.println("Seting Up LoraWAN module...");
  delay(3000);
}

/*
 * ------------------------------------
 * Set up LoRaWan
 * ------------------------------------
 */
void lorawanSetUp(){
//  uint8_t error;
  // Device parameters for Back-End registration
  char DEVICE_EUI[]  = "0004A30B00F9AAE8"; //SAME AS THE PRE-PROGRAMMABLE EUI
  char APP_EUI[] = "0102030405060708"; //FROM EXAMPLE
  char DEVICE_ADDR[] = "508CFB29"; //FROM EXAMPLE
  char APP_KEY[] = "000102030405060708090A0B0C0D0E0F"; //FROM EXAMPLE
  
  USB.println("LoRaWAN Module configuration");

  delay(2000);

  switchOn();

//  setPowerOn();

  enableAdaptiveDataRate();

  setDeviceEui(DEVICE_EUI);

  setApplicationEui(APP_EUI);

  getDeviceEui();

//  setDeviceAddress(DEVICE_ADDR);

//  getDeviceAddress();

  setApplicationKey(APP_KEY);

  setAutomaticReply();

  getAutomaticReply();

  joinNetworkOTAA();
  
  saveConfiguration();

  switchOff();
}

/*
 * -------------------------------
 * Socket switch ON
 * -------------------------------
 */
void switchOn(){
  error = LoRaWAN.ON(socket);
  // Check status
  if( error == 0 ){
    USB.println("Switch ON OK");
    delay(1000); 
  }else{
    USB.print("Switch ON error = "); 
    USB.println(error, DEC);
  }
}

/*
 * -------------------------------
 * Power on the Lora circuit
 * -------------------------------
 */
void setPowerOn(){
  // Set Power level
  error = LoRaWAN.setPower(5);

  // Check status
  if ( error == 0 ){
    USB.println("Power level set OK");
    delay(2000);
  }else{
    USB.print("Power level set error = ");
    USB.println(error, DEC);
  }
}

/*
 * -------------------------------
 * Enable adaptive data rate
 * -------------------------------
 */
void enableAdaptiveDataRate(){
  // Enable Adaptive Data Rate (ADR)

  error = LoRaWAN.setADR("on");

  // Check status
  if( error == 0 ){
    USB.print("Adaptive Data Rate enabled OK");    
    USB.println("ADR: ");
    USB.println(LoRaWAN._adr, DEC);
    delay(2000); 
  }else{
    USB.print("Enable data rate error = "); 
    USB.println(error, DEC);
  }
}


/*
 * -------------------------------
 * Set device EUI
 * -------------------------------
 */
void setDeviceEui(char DEVICE_EUI[]){
  // Set Device EUI
  error = LoRaWAN.setDeviceEUI(DEVICE_EUI);
  
  if(error == 0){
    USB.println("Set device EUI OK");
    delay(2000); 
  }else{
    USB.println("Set device EUI error = ");
    USB.println(error);
  }
}

void getDeviceEui(){
  error = LoRaWAN.getDeviceEUI();
  if( error == 0 ){
    USB.println("Get Device EUI OK");
    USB.println("Device EUI: ");
    USB.println(LoRaWAN._devEUI);
  }else{
    USB.print("Get Device EUI error = "); 
    USB.println(error, DEC);
  }
}

/*
 * -------------------------------
 * Set APP EUI
 * -------------------------------
 */
void setApplicationEui(char APP_EUI[]){
  // Set Application EUI
  
  error = LoRaWAN.setAppEUI(APP_EUI);

  // Check status
  if( error == 0 ){
    USB.println("Application EUI set OK");     
  }else{
    USB.println("Application EUI set error = "); 
    USB.println(error, DEC);
  }
}

/*
 * -------------------------------
 * Set device address(not neededd)
 * -------------------------------
 */
void setDeviceAddress(char DEVICE_ADDR[]){
  // Set Device Address
  error = LoRaWAN.setDeviceAddr(DEVICE_ADDR);

  // Check status
  if( error == 0 ){
    USB.println("Set Device address OK");     
    delay(2000); 
  }else{
    USB.println("Set Device address error = "); 
    USB.println(error, DEC);
  }
}

void getDeviceAddress(){
  // Get Device Address
  error = LoRaWAN.getDeviceAddr();

  // Check status
  if( error == 0 ){
    USB.print("Get Device address OK"); 
    USB.println("Device address: ");
    USB.println(LoRaWAN._devAddr);
  }else{
    USB.print("Get Device address error = "); 
    USB.println(error, DEC);
  }
}

/*
 * -------------------------------
 * Set APP KEY
 * -------------------------------
 */
void setApplicationKey(char APP_KEY[]){
  // Set application key

  error = LoRaWAN.setAppKey(APP_KEY);

  // Check status
  if( error == 0 ){
    USB.println("Application key set OK");   
    delay(2000);   
  }else{
    USB.println("Application key set error = "); 
    USB.println(error, DEC);
  }
}

/*
 * -------------------------------
 * Set Automatic reply to ON
 * -------------------------------
 */
void setAutomaticReply(){
  // Set Automatic Reply

  // set AR
  error = LoRaWAN.setAR("on");

  // Check status
  if( error == 0 ){
    USB.println("Set automatic reply status to on OK");   
    delay(2000);   
  }else{
    USB.print("Set automatic reply status to on error = "); 
    USB.println(error, DEC);
  }
}

void getAutomaticReply(){
  // Get AR
  error = LoRaWAN.getAR();

  // Check status
  if( error == 0 ){
    USB.println("Get automatic reply status OK "); 
    USB.println("Automatic reply status: ");
    if (LoRaWAN._ar == true){
      USB.println("on");      
    }else{
      USB.println("off");
    }
  }else {
    USB.print("Get automatic reply status error = "); 
    USB.println(error, DEC);
  }
}

/*
 * -------------------------------
 * Save Lora configurations
 * -------------------------------
 */
void saveConfiguration(){
  // Save configuration
  
  error = LoRaWAN.saveConfig();

  // Check status
  if( error == 0 ){
    USB.println("Save configuration OK");   
    delay(2000);   
  }else{
    USB.print("Save configuration error = "); 
    USB.println(error, DEC);
  }

  USB.println(F("------------------------------------"));
  USB.println(F("Now the LoRaWAN module is ready for"));
  USB.println(F("joining networks and send messages."));
  USB.println(F("Please check the next examples..."));
  USB.println(F("------------------------------------\n"));
}

/*
 * -------------------------------
 * Socket switch ON
 * -------------------------------
 */
void switchOff(){
  // Switch off
  error = LoRaWAN.OFF(socket);

  // Check status
  if( error == 0 ){
    USB.println("Switch OFF OK");     
  }else{
    USB.print("Switch OFF error = "); 
    USB.println(error, DEC);
  }
}

/*
 * -------------------------------
 * Join Network OTAA
 * -------------------------------
 */
void joinNetworkOTAA(){
  // Join network

  error = LoRaWAN.joinOTAA();

  // Check status
  if( error == 0 ){
    USB.println("Join network OK");         
  }else {
    USB.print("Join network error = "); 
    USB.println(error, DEC);
  }
}

/*
 * -----------------------------------------
 * Join Network ABP to send to Lora gateway
 * -----------------------------------------
 */
void joinNetworkABP(){
  error = LoRaWAN.joinABP();

  // Check status
  if( error == 0 ) 
  {
    USB.println("Join ABP network OK");     

    // 3. Send Confirmed packet 

    error = LoRaWAN.sendConfirmed( PORT, data);

    // Error messages:
    /*
     * '6' : Module hasn't joined a network
     * '5' : Sending error
     * '4' : Error with data length   
     * '2' : Module didn't response
     * '1' : Module communication error   
     */
    // Check status
    if( error == 0 ){
      USB.println("Send Confirmed packet OK");  
      if (LoRaWAN._dataReceived == true){ 
        USB.print("There's data on port number ");
        USB.print(LoRaWAN._port,DEC);
        USB.print(F(".\r\n   Data: "));
        USB.println(LoRaWAN._data);
      }   
    }else{
      USB.print("Send Confirmed packet error = "); 
      USB.println(error, DEC);
    } 
  }else{
    USB.print("Join network error = "); 
    USB.println(error, DEC);
  }
}


