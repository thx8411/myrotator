include <threads.scad>

$fn = 100;

mountHeight = 4;
mountInnerDiameter=40;
mountOuterDiameter=43;

threadHeight = 1.5;
mountThreadOuterDiameter=45;
threadLength=14.72;

mountSpacerHeight=1.25;
mountSpacerOuterDiameter= 46.5;

mountTipDiameter=2.5;
mountTipSpacing=mountSpacerOuterDiameter+2.5;
mountTipHigh=1.5;

///////////

M48_out_d1=52;
M48_out_d2=51;
M48_in_d=44;
M48_h=6-mountSpacerHeight;
M48_thread_h=5;

/////////////////////
module M48() {
	translate([0, 0, mountHeight + mountSpacerHeight ]) {
        difference() {
            union() {
                cylinder(M48_h, d1=M48_out_d1, d2=M48_out_d2);
                translate([0,0,M48_h]) {
                    metric_thread (diameter=48, pitch=0.75, length=M48_thread_h);
                }
            }
            cylinder(M48_h+M48_thread_h, d2=M48_in_d, d1=mountInnerDiameter);
            
            // mount tip
            rotate([0,0,0-2]) {
                translate([0,mountTipSpacing/2+0.5,0]) {
                    cylinder(mountTipHigh, d=mountTipDiameter);
                }
            }
        }
	}
}

/////////////////////

module EOSm_M48() {	
	// flip model so outer cover body becomes base
	rotate([0, 180, 0]) {
		mountRing();
		M48();	
	}
}

module ringThread(rot) {
	intersection() {
		difference() {
			cylinder(h=threadHeight, r=mountThreadOuterDiameter * 0.5);
			cylinder(h=threadHeight, r=mountInnerDiameter * 0.5);
		}
		
		rotate([0, 0, rot]) {
			translate([threadLength, 0 - threadLength * 0.5, 0]) {
				cube(size=threadLength);
			}	
		}
	}

	translate([0, 0, threadHeight]) {
		intersection() {
			difference() {	
				cylinder(h=threadHeight, r=mountThreadOuterDiameter * 0.5);
				cylinder(h=threadHeight, r=mountInnerDiameter * 0.5);
			}

			rotate([0, 0, rot]) {
				translate([mountThreadOuterDiameter * 0.5 - threadHeight * 1.25, threadLength * 0.5 - threadHeight, 0]) {
					cube(size=threadHeight);
				}
			}	
		}
	}
}

module mountRing() {
    
	difference() {
		cylinder(h=mountHeight, r=mountOuterDiameter * 0.5);
		cylinder(h=mountHeight, r=mountInnerDiameter * 0.5);
	}

	for (rot = [45 : 120 : 285]) {
		ringThread(rot);
	}

	translate([0, 0, mountHeight]) {
		difference() {
			cylinder(h=mountSpacerHeight, r=mountSpacerOuterDiameter * 0.5);
			cylinder(h=mountSpacerHeight, r=mountInnerDiameter * 0.5);
		}
    }
}

EOSm_M48();
