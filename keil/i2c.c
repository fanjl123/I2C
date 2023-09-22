#include "i2c.h"
#include <string.h>
#include "code_def.h"

#define fifofull  0x00000004
#define fifoempty 0x00000008
char ReadI2C_BytefinishFLAG()
{
    char state;
	state = I2C -> I2C_FLAG;
    return(state & 0X00000020);
}
char ReadI2C_NackFLAG()
{
    char state;
	state = I2C -> I2C_FLAG;
	I2C -> I2C_FLAG &= state & 0Xffffffef;
    return(state & 0X00000010);
}

char ReadI2C_StopFLAG()
{
    char state;
	state = I2C -> I2C_FLAG;
    return(state & 0X00000002);
}


char ReadI2CFIFOState()
{
    char state;
	state = I2C -> I2C_FLAG;
    return(state & 0X0000000c);
}


char ReadI2CBUFERState()
{
    char state;
	state = I2C -> I2C_FLAG;
    return(state & 0X00000001);
}


void WriteI2Cbuf(int data)
{
	
  while(ReadI2CFIFOState()==fifofull);
	I2C -> I2C_BUF = data;
}

void AUTO_WriteI2C(int *stri, int length)
{	int i;
	I2C -> I2C_ADR = 0X0000faa0;
	I2C -> I2C_CONTRAL = 0X000000c4;
	for(i=0;i<length;i++)
	{
		WriteI2Cbuf(stri[i]);
	}
	while(ReadI2CFIFOState()!=fifoempty);
	while(ReadI2C_StopFLAG()==0x00000000);
}


void AUTO_ReadI2C(int length )
{	int i;
	I2C -> I2C_ADR = 0X0000faa1;
	I2C -> I2C_CONTRAL = 0X000000c4;
	for(i=0;i<length;i++)
	{
		WriteI2Cbuf(i);
	}
	while(ReadI2CFIFOState()!=fifoempty);
	while(ReadI2C_StopFLAG()==0x00000000);
}
void I2C_Readbuf()
{	
	I2C -> I2C_FLAG &= 0Xfffffffe;
}


void Manop_WriteI2C(int *stri, int length)
{	int i;
	I2C -> I2C_ADR = 0X0000faa0;
	I2C -> I2C_CONTRAL = 0X00000081;

	for(i=0;i<length;i++)
	{
		WriteI2Cbuf(stri[i]);
	}
	  while(ReadI2CFIFOState() != fifoempty);
	I2C -> I2C_CONTRAL = 0X00000082; 	
	while(ReadI2C_StopFLAG()==0x00000000);
}


void Manop_ReadI2C(int length)
{	int i;
	I2C -> I2C_ADR = 0X0000faa1;
	I2C -> I2C_CONTRAL = 0X00000081;

	for(i=0;i<length;i++)
	{
		WriteI2Cbuf(i);
  while(ReadI2CBUFERState()!= 0x00000001);
	I2C -> I2C_FLAG = 0X00000000; 	
	}
	
	I2C -> I2C_CONTRAL = 0X00000082; 	
	while(ReadI2C_StopFLAG()==0x00000000);
}


void Manop_RestartReadI2C(int addr,int length)
{	int i;
	I2C -> I2C_ADR = 0X0000faa0;
	I2C -> I2C_CONTRAL = 0X00000081;
  Delay(1000);//for display HOLD
	while(1)
	{
	while (ReadI2C_BytefinishFLAG()!=0x00000020){};
		if(ReadI2C_NackFLAG()==0x00000010)
		{
		 I2C -> I2C_CONTRAL = 0X00000081;
		}
		else
		{
		 break;
		}
	while (ReadI2C_BytefinishFLAG()==0x00000020){};
	}
	WriteI2Cbuf(addr);
	while(ReadI2CFIFOState() != fifoempty);
	I2C -> I2C_ADR = 0X0000faa1;
	I2C -> I2C_CONTRAL = 0X00000081;
  Delay(2);
		for(i=0;i<length;i++)
	{
	WriteI2Cbuf(i); 	
	}
	
	  while(ReadI2CFIFOState() != fifoempty);
	I2C -> I2C_CONTRAL = 0X00000082; 
	while(ReadI2C_StopFLAG()==0x00000000);	
}

void I2C_Slv_init(char *stri)
{
		int i;
	I2C -> I2C_ADR = 0X0000fa78;
	I2C -> I2C_CONTRAL = 0X000000a0; 

	for(i=0;i<strlen(stri);i++)
	{
		WriteI2Cbuf(stri[i]);
	}
}

