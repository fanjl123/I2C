#include <stdint.h>
//I2C DEF
typedef struct{
    volatile uint32_t I2C_ADR;
    volatile uint32_t I2C_CONTRAL;
    volatile uint32_t I2C_FLAG;
    volatile uint32_t I2C_BUF;
}I2CType;

#define I2C_BASE 0x40000020
#define I2C ((I2CType *)I2C_BASE)



void WriteI2Cbuf(int data);
void AUTO_ReadI2C(int length);
char  ReadI2CFIFOState ();
char  ReadI2CBUFERState ();
char  ReadI2C_StopFLAG ();
char  ReadI2C_NackFLAG ();
void  I2C_Readbuf ();
char  ReadI2C_BytefinishFLAG ();
void AUTO_WriteI2C(int *stri, int length);

void Manop_WriteI2C(int *stri, int length);
void Manop_ReadI2C (int length);

void Manop_RestartReadI2C (int addr, int length);
void I2C_Slv_init();