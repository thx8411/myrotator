#BOARD = arduino:avr:diecimila:cpu=atmega328
#BOARD = arduino:avr:nano:cpu=atmega328old
BOARD = digistump:avr:digispark-tiny

#PORT = "/dev/ttyUSB0"
PORT = /dev/ttyACM0

SKETCH = myrotator.ino
LIBS =

compile : $(SKETCH) $(LIBS)
	arduino --verify --board $(BOARD) $(SKETCH)

upload : $(SKETCH) $(LIBS)
	arduino --upload $(SKETCH) --board $(BOARD) --port $(PORT)
