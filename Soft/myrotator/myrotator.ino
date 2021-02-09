
// pyxis rotator emulator

////////////////////////////////////////////////

#include "EEPROM.h"
#include <DigiCDC.h>

////////////////////////////////////////////////


// pins location
#define ENBL_PIN	0
#define DIR_PIN		2
#define STEP_PIN	1

// pyxis steps per rev = 5280 meens 728 micro steps/deg
#define STEP_DEG	728

// step number correction
// pyxis as 5280 step per rev
// 1 pyxis step meens about 50 micro steps
#define STEP_RATIO	50

// backlash (n micro steps, max 255)
#define BACKLASH	1456

// speed correction
// delay between steps = 1ms * speed
// SerialUSB.write takes about 1ms + 3ms per "step"
#define SPEED_ADJUST	4

////////////////////////////////////////////////

#define FORWARD		HIGH
#define BACKWARD	LOW

////////////////////////////////////////////////

// EEPROM @ mapping
#define	SENS_ADDR	0
#define POSITION_ADDR	SENS_ADDR+sizeof(bool)
#define SPEED_ADDR	POSITION_ADDR+sizeof(long)

////////////////////////////////////////////////

char buffer[5];

////////////////////////////////////////////////


//
// serial helpers
//
void ack() {
        SerialUSB.write('!');
}

void newLine() {
	SerialUSB.write('\r');
	SerialUSB.write('\n');
}

void sendNum(char* n) {
	SerialUSB.write(n[0]);
	SerialUSB.write(n[1]);
	SerialUSB.write(n[2]);
}


//
// motor control
//

class Motor {

	private:
		byte dir=FORWARD;
		bool half=false;
		int step_ratio=STEP_RATIO;
		unsigned long wait=8000/STEP_RATIO;

	public:

		void init() {
			pinMode(DIR_PIN, OUTPUT);
			pinMode(STEP_PIN, OUTPUT);
			pinMode(ENBL_PIN, OUTPUT);
			digitalWrite(DIR_PIN, LOW);
			digitalWrite(STEP_PIN, LOW);
			disable();
		}

		void enable() {
			digitalWrite(ENBL_PIN, LOW);
		}

		void disable() {
			digitalWrite(ENBL_PIN, HIGH);
		}

		void setDirection(byte d) {
			if(d!=dir) {
				dir=d;
				digitalWrite(DIR_PIN, dir);
				unsigned int i=BACKLASH;
				while(i--) {
					step();
				}
			}
		}

		byte getDirection() {
			return(dir);
		}

		void setMode(bool m) {
			if(m!=half) {
				if(m) {
					wait*=2;
					step_ratio=STEP_RATIO/2;
				} else {
					wait/=2;
					step_ratio=STEP_RATIO;
				}
				half=m;
			}
		}

		bool getMode() {
			return(half);
		}

		void setSpeed(byte s) {
			wait=(long)s*1000/step_ratio;
		}

		void step() {
                        digitalWrite(STEP_PIN, HIGH);
                        digitalWrite(STEP_PIN, LOW);
                        delayMicroseconds(wait);
                }

		void move(long n) {
			long i=n;
			while(i--) {
				step();
				if(i%step_ratio==0) {
					ack();
				}
			}
		}

		int getRatio() {
			return(step_ratio);
		}
} motor;


//
// rotator control
//

class Rotator {

	private:
		byte speed=8-SPEED_ADJUST;
		long position=0;
		bool invert=false;

	public:

		void init() {
			// read eeprom values
			EEPROM.get(SENS_ADDR,invert);
			EEPROM.get(POSITION_ADDR,position);
			EEPROM.get(SPEED_ADDR,speed);
			motor.setSpeed(speed);
		}

		void home() {
			moveTo(0);
		}

		void moveTo(int p) {
			// compute position
			long new_position=(long)p*STEP_DEG;
			long delta=new_position-position;
			// if no move
			if(delta==0)
				return;

			// sens
			if((delta<0) != invert) {
				// backward
				motor.setDirection(BACKWARD);
			} else {
				// forward
				motor.setDirection(FORWARD);
			}

			// number of steps
			delta=abs(delta);

			// move
			motor.enable();
			motor.move(delta);
			motor.disable();
			position=new_position;
			EEPROM.put(POSITION_ADDR,position);
		}

		int getPosition() {
			return(position/STEP_DEG);
		}

		void setSpeed(byte s) {
			if(s>SPEED_ADJUST) {
				speed=s-SPEED_ADJUST;
			} else {
				speed=0;
			}
			motor.setSpeed(speed);
			EEPROM.put(SPEED_ADDR,speed);
		}

		void setSens(int s) {
			invert=(s==1);
			EEPROM.put(SENS_ADDR,invert);
		}

                bool getSens() {
			return(invert);
		}

		void adjust(int s, bool d) {
			byte dir=motor.getDirection();
			int n=s*motor.getRatio();

			// sens
                        if(d) {
                                // backward
                                motor.setDirection(BACKWARD);
				position-=n;
                        } else {
                                // forward
                                motor.setDirection(FORWARD);
				position+=n;
                        }

	                motor.enable();
			while(n--) {
				motor.step();
			}
			motor.disable();

			// restore direction
			motor.setDirection(dir);
		}

		void stepMode(bool m) {
			motor.setMode(m);
		}

		void sync(int p) {
			position=(long)p*STEP_DEG;
			EEPROM.put(POSITION_ADDR,position);
		}

} rotator;


//
// core
//


void setup() {
	// init serial
	SerialUSB.begin();

	// EEPROM init
	EEPROM.begin();

	// motor init
	motor.init();

	// init wheel
	rotator.init();
}


void loop() {
	char incomingByte;
	// look for the next command
	if (SerialUSB.available()>=6) {
		if(SerialUSB.read()=='C') {
			for(int i=0; i<5; i++) {
				buffer[i]=SerialUSB.read();
			}
		}

		switch(buffer[0]) {
			// ping
			case 'C' :
				ack();
				newLine();
				break;
			// home
			case 'H' :
				rotator.home();
				SerialUSB.write('F');
				break;
			// set direction
			case 'D' :
				rotator.setSens(buffer[1]=='1');
				break;
			// get direction
			case 'M' :
				if(rotator.getSens()) {
					SerialUSB.write('1');
				} else {
					SerialUSB.write('0');
				}
				newLine();
				break;
			// get angle
			case 'G' :
				char tmp[3];
				int2str(tmp,rotator.getPosition(),3);
				sendNum(tmp);
				newLine();
				break;
			// set angle
			case 'P' :
				rotator.moveTo(str2int(buffer+2,3));
				SerialUSB.write('F');
				break;
			// sleep
			case 'S' :
				// ignore
				break;
			// wake
			case 'W' :
				ack();
				newLine();
				// ignore
				break;
			// adjust
			case 'X' :
				rotator.adjust(str2int(buffer+4,1),buffer[3]=='1');
				ack();
				break;
			// speed
			case 'T' :
				rotator.setSpeed(str2int(buffer+3,2));
				ack();
				break;
			// half step
			case 'Z' :
				rotator.stepMode(buffer[1]=='1');
				break;
			// version
			case 'V' :
				SerialUSB.write('2');
				newLine();
				break;
			// sync
                        case 'U' :
                                rotator.sync(str2int(buffer+2,3));
				ack();
				newLine();
                                break;

			default :
				// if unkown, send something to avoid locking
				ack();
				newLine();
		}
	}
}


//
// HELPERS
//


// power of ten (0 to 2)
int power10(byte n) {
	switch(n) {
		case 1 :
			return(10);
		case 2 :
			return(100);
		default :
			return(1);
	}
}


// s : string to read
// n : number of char to convert
int str2int(char* s, byte n) {
	int v=0;
	for(byte i=0; i<n; i++) {
		v+=(s[i]-'0')*power10(n-1-i);
	}
	return(v);
}

// s : string to write
// v : int to convert
// n : number of digits
void int2str(char* s, int v, int n) {
	int tmp=v;
	for(byte i=0; i<n; i++) {
		s[i]='0'+(tmp/power10(n-1-i));
		tmp-=(tmp/power10(n-1-i))*power10(n-1-i);
	}
}
