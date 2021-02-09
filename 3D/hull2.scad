core_d=80;
ring_d=52.25;
motor_d=40;

screw_d1=6;
screw_d2=3.2;

h=6.5;

wall=2;

$fn=90;

difference() {
    union() {
        hull() {
            cylinder(h+wall, d=core_d);
            translate([45,0,0]) {
                cylinder(h+wall, d=motor_d+2*wall);
            }
        }
        translate([30,20,0]) {
            cylinder(h+wall, d=screw_d1+2*wall);
        }
        translate([30,-20,0]) {
            cylinder(h+wall, d=screw_d1+2*wall);
        }
    }
    
    hull() {
        cylinder(h, d=core_d-2*wall);
        translate([45,0,0]) {
            cylinder(h, d=motor_d);
        } 
    }
    
    cylinder(h+wall, d=ring_d);
    
    translate([30,20,0]) {
        cylinder(h+wall, d=screw_d1);
    }
    translate([30,-20,0]) {
        cylinder(h+wall, d=screw_d1);
    }
}

difference() {
    union() {
        translate([30,20,0]) {
            cylinder(h, d=screw_d1+2*wall);
        }
        translate([30,-20,0]) {
            cylinder(h, d=screw_d1+2*wall);
        }
    }
    translate([30,20,0]) {
        cylinder(h, d=screw_d2);
    }
    translate([30,-20,0]) {
        cylinder(h, d=screw_d2);
    }
    
    translate([30,20,h-1.5]) {
        cylinder(1.5, d=screw_d1);
    }
    translate([30,-20,h-1.5]) {
        cylinder(1.5, d=screw_d1);
    }
}