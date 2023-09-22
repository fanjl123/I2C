#include "code_def.h"
#include <string.h>

void SetWaterLightMode(int mode)
{
	WaterLight -> Waterlight_MODE = mode;
}

void SetWaterLightSpeed(int speed)
{
	WaterLight -> Waterlight_SPEED = speed;
}

void Delay(int interval)
{
    int i = 0;
    while(1) 
		{
			i = i + 1;
			if(i == interval) break;
		}
}
 
char ReadUARTState()
{
    char state;
	state = UART -> UARTTX_STATE;
    return(state);
}

char ReadUART()
{
    char data;
	data = UART -> UARTRX_DATA;
    return(data);
}

void WriteUART(char data)
{
    while(ReadUARTState());
	UART -> UARTTX_DATA = data;
}

void UARTString(char *stri)
{
	int i;
	for(i=0;i<strlen(stri);i++)
	{
		WriteUART(stri[i]);
	}
}

void UARTHandle()
{
char data;
int mode;
	data = ReadUART();
  if     (data=='d') {mode=3;}
  else if(data=='l') {mode=1;}
  else if(data=='r') {mode=2;}
	else {UARTString("Comand is invalid"); 
	return;}
	SetWaterLightMode(mode);
	UARTString("Cortex-M0 led mode: ");
	WriteUART(data);
	WriteUART('\n');
	
}
