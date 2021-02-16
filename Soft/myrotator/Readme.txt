You have to customise 

arduino15/packages/digistump/hardware/avr/1.6.7/libraries/DigisparkCDC/usbconfig.h

with :

#define USB_CFG_MAX_BUS_POWER           300

#define USB_CFG_DEVICE_NAME     'm','y','r','o','t','a','t','o','r'
#define USB_CFG_DEVICE_NAME_LEN 9

