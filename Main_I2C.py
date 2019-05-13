#!/bin/bash
import time
import subprocess
import sys
import serial
import I2C_LCD_driver
import RPi.GPIO as GPIO
lcd = I2C_LCD_driver.lcd()

GPIO.setmode(GPIO.BOARD)
GPIO.setup(40,GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(32,GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(38,GPIO.OUT)
GPIO.setup(16, GPIO.OUT)
GPIO.output(16,False)

def main():
    n=0
    lcd.lcd_display_string("  Scoot Always  ",1)
    lcd.lcd_display_string("      2019      ",2)
    time.sleep(4)
    lcd.lcd_clear()
    lcd.lcd_display_string("Sensor ready",1)
    time.sleep(1)
    lcd.lcd_clear()
    lcd.lcd_display_string("Waiting",1)
    while True:
        if(GPIO.input(40)==0):
            while(GPIO.input(40)==0):
                time.sleep(0.1)
            n=n+1
            print(n) 
            Usart_Receive(n)
            lcd.lcd_clear()
            lcd.lcd_display_string("Waiting",1)
        if(GPIO.input(32)==0):
            while(GPIO.input(32)==0):
                time.sleep(0.1)
            return
        GPIO.output(38,True)
        time.sleep(0.25)
        GPIO.output(38,False)
        time.sleep(0.25)

def Usart_Receive(n):
    m=0
    i=0
    print("USART : OK")
    path="/home/pi/Public/Speed_Data/Speed"+str(n)+".csv"
    f = open(path,"w")
    ser = serial.Serial("/dev/ttyAMA0",baudrate = 115200)
    run=True
    GPIO.output(38,True)
    f.write("Time: %s\n" %time.strftime("%H:%M:%S"))
    f.write("Date: %s\n" %time.strftime("%m/%d/%Y"))
    f.write("Speed(km/h);Time(s)\n")
    GPIO.output(16,True)
    while(run):
        m=m+0.25
        i+=1
        x=ser.read(4)
        print(x.decode("ISO-8859-1"))
        if(i==4):
            lcd.lcd_clear()
            lcd.lcd_display_string("Speed: " + x.decode("ISO-8859-1")+" km/h",1)
            lcd.lcd_display_string("Mesure "+str(n),2) 
            i=0
        f.write(x.decode("ISO-8859-1")+';'+str(m)+';\n') 
        if (GPIO.input(40)==0):
            run=False
    GPIO.output(16,False)
    f.write("Time: %s\n" %time.strftime("%H:%M:%S"))
    f.write("Date: %s\n" %time.strftime("%m/%d/%Y"))
    f.close
    ser.close()
    while (GPIO.input(40)==0):
        time.sleep(0.1)
    return

main()
lcd.lcd_clear()
GPIO.cleanup()

