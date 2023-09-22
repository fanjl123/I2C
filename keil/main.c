#include "code_def.h"
#include "i2c.h"
#include <string.h>
#include <stdint.h>

#define WaterLight_SPEED_VALUE 0xffffff
#define WaterLight_INTERVAL_VALUE 0xf5e100

int main()
{ 
	//WATERLIGHT
	int waterlight_mode = 1;
	
	
	
	  int i;
    int array[9];
		int* array_ptr = array;
		for (i = 0; i < sizeof(array)/sizeof(array[0]); i++) {
		
      if(i<=1)			
      array[i] = 0;
			else
      array[i] = i-1;	
   }
	//interrupt initial
	NVIC_CTRL_ADDR = 0x00000002;

	//EEPROM   write     auto_mode
	AUTO_WriteI2C(array_ptr ,sizeof(array)/sizeof(array[0]));//
	//EEPROM   read     auto_mode
//  AUTO_WriteI2C(array_ptr ,1);
//	AUTO_ReadI2C(8);	
	//EEPROM   read     manop_mode	 
  Manop_RestartReadI2C(0,8);



	 
	//UART display
//	UARTString("Cortex-M0 Start up!\n");	 
	 
//	Manop_RestartReadI2C(0,8);
//	AUTO_WriteI2C(array_ptr ,1);//
//	 Delay(1000);
//	AUTO_WriteI2C(array_ptr ,4);// 
//	AUTO_ReadI2C(10);
//	Manop_WriteI2C("up");
//	Manop_ReadI2C(2);
//	Manop_RestartReadI2C(15,2);
//	
//	  I2C_Slv_init("up");
//	SetWaterLightSpeed(WaterLight_SPEED_VALUE);
//	UARTString("WaterLight speed setting to default!\n");
	while(1)
	{
//	 	ReadUART();
//		Delay(WaterLight_INTERVAL_VALUE);
	}
/*	while(1)
	{
		SetWaterLightMode(waterlight_mode);
		if(waterlight_mode == 1) UARTString("WaterLight mode setting to left mode!\n");
		else if (waterlight_mode == 2) UARTString("WaterLight mode setting to right mode!\n");
		else if (waterlight_mode == 3) UARTString("WaterLight mode setting to flash mode!\n");
		else UARTString("WaterLight mode setting to die!\n");
		Delay(WaterLight_INTERVAL_VALUE);
		if(waterlight_mode == 3) waterlight_mode = 1;
		else waterlight_mode = waterlight_mode+1;
	}
*/
}

