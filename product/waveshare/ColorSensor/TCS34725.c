/*****************************************************************************
* | File      	:   TCS34725.c
* | Author      :   CQROBOT
* | Function    :   TCS34725 driver
* | Info        :
*                Tcs34725 initialization, reading data, writing data 
                 and data processing
*----------------
* |	This version:   V1.0
* | Date        :   2019-01-16
* | Info        :

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documnetation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to  whom the Software is
# furished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS OR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
******************************************************************************/
#include "TCS34725.h"

TCS34725IntegrationTime_t IntegrationTime_t = TCS34725_INTEGRATIONTIME_700MS;
TCS34725Gain_t  Gain_t = TCS34725_GAIN_60X;

/******************************************************************************
function:   Write a byte to TCS34725
parameter	:
        add : Register address
        data: Written data
******************************************************************************/
static void TCS34725_WriteByte(UBYTE add, UBYTE data)
{
    uint8_t buf[2] = {add | TCS34725_CMD_BIT, data};
    i2c_write_blocking(i2c_default, TCS34725_ADDRESS, buf, 2, true);
}

/******************************************************************************
function:   Read a byte to TCS34725
parameter	:
        add : Register address
******************************************************************************/
static UBYTE TCS34725_ReadByte(UBYTE add)
{
    uint8_t reg = add | TCS34725_CMD_BIT;
    uint8_t value[1];
    i2c_write_blocking(i2c_default,TCS34725_ADDRESS, &reg, 1, true);
    i2c_read_blocking(i2c_default,TCS34725_ADDRESS, value, 1, false);
    return value[0];
}

/******************************************************************************
function:   Read a word to TCS34725
parameter	:
        add : Register address
        data: Written data
******************************************************************************/
static UWORD TCS34725_ReadWord(UBYTE add)
{
    uint8_t buf[2];
    uint8_t reg = add | TCS34725_CMD_BIT;
    i2c_write_blocking(i2c_default,TCS34725_ADDRESS, &reg, 1, true);
    i2c_read_blocking(i2c_default,TCS34725_ADDRESS, buf, 2, false);
    UWORD result = ( buf[1] << 8) | buf[0];

      printf("reading from reg %X, !\r\n", reg);
      printf(" got value %X buf 0 %X !\r\n", buf[1], buf[0]);

    // uint8_t lsb;
    // uint8_t msb;
    // add = add | TCS34725_CMD_BIT;

    // i2c_write_blocking(i2c_default, add, &reg, 1, true);
    // i2c_read_blocking(i2c_default, add, &lsb, 1, false);

    // reg |= 0x01;
    // i2c_write_blocking(i2c_default, add, &reg, 1, true);
    // i2c_read_blocking(i2c_default, add, &msb, 1, false);

    // UWORD result = (msb << 8) | lsb;

    return result;
}

/******************************************************************************
function:   
        TCS34725 wake up
******************************************************************************/
static void TCS34725_Enable(void)
{
    TCS34725_WriteByte(TCS34725_ENABLE, TCS34725_ENABLE_PON);
    DEV_Delay_ms(3);
    TCS34725_WriteByte(TCS34725_ENABLE, TCS34725_ENABLE_PON | TCS34725_ENABLE_AEN);
    DEV_Delay_ms(3);  
}

/******************************************************************************
function:   
        TCS34725 Sleep
******************************************************************************/
void TCS34725_Disable(void)
{
    /* Turn the device off to save power */
    UBYTE reg = 0;
    reg = TCS34725_ReadByte(TCS34725_ENABLE);
    TCS34725_WriteByte(TCS34725_ENABLE, reg & ~(TCS34725_ENABLE_PON | TCS34725_ENABLE_AEN));
}

/******************************************************************************
function:   TCS34725 Set Integration Time
parameter	:
        time: Integration Time Reference "TCS34725.h" Enumeration Type
******************************************************************************/
void TCS34725_Set_Integration_Time(TCS34725IntegrationTime_t time)
{
    /* Update the timing register */
    TCS34725_WriteByte(TCS34725_ATIME, time);
    IntegrationTime_t = time;
}

/******************************************************************************
function:   TCS34725 Set gain
parameter	:
        gain: gain Reference "TCS34725.h" Enumeration Type
******************************************************************************/
void TCS34725_Set_Gain(TCS34725Gain_t gain)
{
	TCS34725_WriteByte(TCS34725_CONTROL, gain); 
    Gain_t = gain;
}

/******************************************************************************
function:   Interrupt Enable
******************************************************************************/
static void TCS34725_Interrupt_Enable()
{
    UBYTE data = 0;
    data = TCS34725_ReadByte(TCS34725_ENABLE);
    TCS34725_WriteByte(TCS34725_ENABLE, data | TCS34725_ENABLE_AIEN);
}

/******************************************************************************
function:   Interrupt Disable
******************************************************************************/
void TCS34725_Interrupt_Disable()
{
    UBYTE data = 0;
    data = TCS34725_ReadByte(TCS34725_ENABLE);
    TCS34725_WriteByte(TCS34725_ENABLE, data & (~TCS34725_ENABLE_AIEN));
}

/******************************************************************************
function:   Set Interrupt Persistence register, Interrupts need to be maintained 
            for several cycles
parameter	:
    TCS34725_PER : reference "TCS34725.h"
******************************************************************************/
static void TCS34725_Set_Interrupt_Persistence_Reg(UBYTE TCS34725_PER)
{
    if(TCS34725_PER < 0x10)
        TCS34725_WriteByte(TCS34725_PERS, TCS34725_PER);
    else 
        TCS34725_WriteByte(TCS34725_PERS, TCS34725_PERS_60_CYCLE);
}

/******************************************************************************
function:   Set Interrupt Threshold
parameter	:
    Threshold_H,Threshold_L: 
    Two 16-bit interrupt threshold registers allow the user to set limits 
    below and above a desired light level. An interrupt can be generated 
    when the Clear data (CDATA) is less than the Clear interrupt low 
    threshold (AILTx) or is greater than the Clear interrupt high 
    threshold (AIHTx)(Clear is the Clear ADC Channel Data Registers)
******************************************************************************/
static void TCS34725_Set_Interrupt_Threshold(UWORD Threshold_H, UWORD Threshold_L)
{
    TCS34725_WriteByte(TCS34725_AILTL, Threshold_L & 0xff);
    TCS34725_WriteByte(TCS34725_AILTH, Threshold_L >> 8);
    TCS34725_WriteByte(TCS34725_AIHTL, Threshold_H & 0xff);
    TCS34725_WriteByte(TCS34725_AIHTH, Threshold_H >> 8);
}

/******************************************************************************
function:   Clear interrupt flag
******************************************************************************/
static void TCS34725_Clear_Interrupt_Flag()
{
    TCS34725_WriteByte(TCS34725_CMD_Clear_INT, 0x00);
}

/******************************************************************************
function:   TCS34725 initialization
parameter	:
        gain: gain Reference "TCS34725.h" Enumeration Type
        it  : Integration Time Reference "TCS34725.h" Enumeration Type
******************************************************************************/
UBYTE  TCS34725_Init(void)
{
	// UBYTE ID = 0;
    // //DEV_Set_I2CAddress(TCS34725_ADDRESS);
	// ID = TCS34725_ReadByte(TCS34725_ID);
    // if(ID != 0x44 && ID != 0x4D){
    //     return 1;
    // }
    // //Set the integration time and gain
	 //TCS34725_Set_Integration_Time(TCS34725_INTEGRATIONTIME_154MS);	
    // TCS34725_Set_Gain(TCS34725_GAIN_60X);
    
    // IntegrationTime_t = TCS34725_INTEGRATIONTIME_154MS;
    // Gain_t = TCS34725_GAIN_60X;
    // //Set Interrupt
    // TCS34725_Set_Interrupt_Threshold(0xff00, 0x00ff);//Interrupt upper and lower threshold
    // TCS34725_Set_Interrupt_Persistence_Reg(TCS34725_PERS_2_CYCLE);
    // TCS34725_Enable();
    // TCS34725_Interrupt_Enable();
    // //Set the LCD brightness
    // TCS34725_SetLight(40);

    // This example will use I2C0 on the default SDA and SCL pins (GP4, GP5 on a Pico)
    i2c_init(i2c_default, 100 * 1000);
    gpio_set_function(PICO_DEFAULT_I2C_SDA_PIN, GPIO_FUNC_I2C);
    gpio_set_function(PICO_DEFAULT_I2C_SCL_PIN, GPIO_FUNC_I2C);
    gpio_pull_up(PICO_DEFAULT_I2C_SDA_PIN);
    gpio_pull_up(PICO_DEFAULT_I2C_SCL_PIN);
    // // Make the I2C pins available to picotool
    // bi_decl(bi_2pins_with_func(PICO_DEFAULT_I2C_SDA_PIN, PICO_DEFAULT_I2C_SCL_PIN, GPIO_FUNC_I2C));

    TCS34725_Enable();
    UBYTE ID = TCS34725_ReadByte(TCS34725_ID);
    if(ID != 0x44 && ID != 0x4D){
        printf("Incorrect setup, got device id: %x", ID);
        return -1;
    }
	
	return 0;
}

bool reserved_addr(uint8_t addr) {
    return (addr & 0x78) == 0 || (addr & 0x78) == 0x78;
}

/******************************************************************************
function:   TCS34725 Read RGBC data
parameter	:
     R,G,B,C: RGBC Numerical value,Is a pointer
******************************************************************************/
RGB TCS34725_Get_RGBData()
{
    UBYTE ID = 0;
    printf("hi! %x", ID);
    //DEV_Set_I2CAddress(TCS34725_ADDRESS);

    RGB temp;
    temp.C = TCS34725_ReadWord(TCS34725_CDATAL | TCS34725_CMD_Read_Word);
    temp.R = TCS34725_ReadWord(TCS34725_RDATAL | TCS34725_CMD_Read_Word);
    temp.G = TCS34725_ReadWord(TCS34725_GDATAL | TCS34725_CMD_Read_Word);
    temp.B = TCS34725_ReadWord(TCS34725_BDATAL | TCS34725_CMD_Read_Word);
    switch (IntegrationTime_t){
        case TCS34725_INTEGRATIONTIME_2_4MS:
              DEV_Delay_ms(3);
              break;
        case TCS34725_INTEGRATIONTIME_24MS:
              DEV_Delay_ms(24);
              break;
        case TCS34725_INTEGRATIONTIME_50MS:
              DEV_Delay_ms(50);
              break;
        case TCS34725_INTEGRATIONTIME_101MS:
              DEV_Delay_ms(101);
              break;
        case TCS34725_INTEGRATIONTIME_154MS:
              DEV_Delay_ms(154);
              break;
        case TCS34725_INTEGRATIONTIME_700MS:
              DEV_Delay_ms(700);
              break;
    }
    return temp;
}

/******************************************************************************
function:   Converts the raw R/G/B values to color temperature in degrees
            Kelvin
parameter	:
     rgb    : RGBC Numerical value
******************************************************************************/
UBYTE TCS34725_GetLux_Interrupt(UWORD Threshold_H, UWORD Threshold_L)
{
    TCS34725_Set_Interrupt_Threshold(Threshold_H, Threshold_L);
    if(DEV_Digital_Read(INT_PIN) == 0){
        TCS34725_Clear_Interrupt_Flag();
        TCS34725_Set_Interrupt_Persistence_Reg(TCS34725_PERS_2_CYCLE);
        return 1;
    }
    return 0;
}
/******************************************************************************
function:   Converts the raw R/G/B values to color temperature in degrees
            Kelvin
parameter	:
     rgb    : RGBC Numerical value
******************************************************************************/
UWORD TCS34725_Get_ColorTemp(RGB rgb)
{
    float cct;
    UWORD r_comp,b_comp,ir;
    ir = (rgb.R + rgb.G + rgb.B > rgb.C) ? (rgb.R + rgb.G + rgb.B - rgb.C) / 2 : 0;
    r_comp = rgb.R - ir;
    b_comp = rgb.B - ir;
    cct=TCS34725_CT_Coef * (float)(b_comp) / (float)(r_comp) + TCS34725_CT_Offset;
    
    return (uint16_t)cct;
}

/******************************************************************************
function:   Converts the raw R/G/B values to lux
parameter	:
     rgb    : RGBC Numerical value
******************************************************************************/
UWORD TCS34725_Get_Lux(RGB rgb)
{
    float lux,cpl,atime_ms,Gain_temp=1;
    UWORD ir=1;
    UWORD r_comp,g_comp,b_comp;
    
    atime_ms = ((256 - IntegrationTime_t) * 2.4);
    ir = (rgb.R + rgb.G + rgb.B > rgb.C) ? (rgb.R + rgb.G + rgb.B - rgb.C) / 2 : 0;
    r_comp = rgb.R - ir;
    g_comp = rgb.G - ir;
    b_comp = rgb.B - ir;
    
    switch (Gain_t)
    {
        case TCS34725_GAIN_1X:
              Gain_temp = 1;
              break;
        case TCS34725_GAIN_4X:
              Gain_temp = 4;
              break;
        case TCS34725_GAIN_16X:
              Gain_temp = 16;
              break;
        case TCS34725_GAIN_60X:
              Gain_temp = 60;
              break;
    } 
    cpl = (atime_ms * Gain_temp) / (TCS34725_GA * TCS34725_DF);

    lux = (TCS34725_R_Coef * (float)(r_comp) + TCS34725_G_Coef * \
            (float)(g_comp) +  TCS34725_B_Coef * (float)(b_comp)) / cpl;
    return (UWORD)lux;
}

/******************************************************************************
function:   Convert raw RGB values to RGB888 format
parameter	:
     rgb    : RGBC Numerical value
******************************************************************************/
UDOUBLE TCS34725_GetRGB888(RGB rgb)
{
    float i=1;
    //Limit data range
    if(rgb.R >= rgb.G && rgb.R >= rgb.B){ 
        i = rgb.R / 255 + 1;
    }
    else if(rgb.G >= rgb.R && rgb.G >= rgb.B){ 
        i = rgb.G / 255 + 1;
    }
    else if(rgb.B >=  rgb.G && rgb.B >= rgb.R){ 
        i = rgb.B / 255 + 1;  
    }
    if(i!=0)
    {
        rgb.R = (rgb.R) / i;
        rgb.G = (rgb.G) / i;
        rgb.B = (rgb.B) / i;
    }
    //Amplify data differences
    /*Please don't try to make the data negative, 
        unless you don't change the data type*/
    if(rgb.R > 30)
        rgb.R = rgb.R - 30;
    if(rgb.G > 30)
        rgb.G = rgb.G - 30;
    if(rgb.B > 30)
        rgb.B = rgb.B - 30;
    rgb.R = rgb.R * 255 / 225;
    rgb.G = rgb.G * 255 / 225;
    rgb.B = rgb.B * 255 / 225;
    
    if(rgb.R>255)
           rgb.R = 255; 
    if(rgb.G>255)
           rgb.G = 255; 
    if(rgb.B>255)
           rgb.B = 255; 
    return (rgb.R << 16) | (rgb.G << 8) | (rgb.B);
}

/******************************************************************************
function:   Convert raw RGB values to RGB565 format
parameter	:
     rgb    : RGBC Numerical value
******************************************************************************/
UWORD TCS34725_GetRGB565(RGB rgb)
{
    float i=1;
    //Limit data range
    if(rgb.R >= rgb.G && rgb.R >= rgb.B){ 
        i = rgb.R / 255 + 1;
    }
    else if(rgb.G >= rgb.R && rgb.G >= rgb.B){ 
        i = rgb.G / 255 + 1;
    }
    else if(rgb.B >=  rgb.G && rgb.B >= rgb.R){ 
        i = rgb.B / 255 + 1;  
    }
    if(i!=0){
        rgb.R = (rgb.R) / i;
        rgb.G = (rgb.G) / i;
        rgb.B = (rgb.B) / i;
    }
    if(rgb.R > 30)
        rgb.R = rgb.R - 30;
    if(rgb.G > 30)
        rgb.G = rgb.G - 30;
    if(rgb.B > 30)
        rgb.B = rgb.B - 30;
    rgb.R = rgb.R * 255 / 225;
    rgb.G = rgb.G * 255 / 225;
    rgb.B = rgb.B * 255 / 225;
    
    if(rgb.R>255)
           rgb.R = 255; 
    if(rgb.G>255)
           rgb.G = 255; 
    if(rgb.B>255)
           rgb.B = 255; 
    return ((rgb.R>>3) << 11) | ((rgb.G>>2) << 5) | ((rgb.B>>3));
}

/******************************************************************************
function:   Set the onboard LED brightness
parameter	:
     value : 0 - 100
******************************************************************************/
// void TCS34725_SetLight(UWORD value)
// {
//     if(value<=100){
//         value =value*DEV_PWM_value/100;
//         DEV_Set_PWM(value);
//     } 
// }



