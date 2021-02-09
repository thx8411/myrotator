core_h=8;
core_d=80;
core_l=80;

ring1_d=60;
ring1_h=5;

ring2_d=53.25;
ring2_h=3;

ring3_d=52.25;
ring3_h=5;

screw_d1=3;
screw_h1=5;

screw_d2=6;
screw_h2=15;
screw_pos=2.2;

wall=2;

$fn=90;

module stp_drv_pos() {
    drv_l=20.6;
    drv_w=15.5;
    drv_h=1.6;
    s_d=2.8;
    s_h=7;
    gap=1;
    
    difference() {
        translate([0,0,drv_h/2+gap]) {
            cube([drv_l+2*gap,drv_w/2,drv_h+2*gap], center=true);
        }
        translate([0,0,drv_h/2+gap]) {
            cube([drv_l,drv_w,drv_h], center=true);
        }
        translate([0,0,drv_h+gap]) {
            cube([drv_l-1.2,drv_w,2*gap], center=true);
        }
        //cylinder(s_h, d=s_d);
    }
}

module stp_drv_neg() {
    s_d=3;
    s_h=5;
    
    translate([-5,0,-s_h+7]) {
        cylinder(s_h, d=s_d);
    }
    translate([5,0,-s_h+7]) {
        cylinder(s_h, d=s_d);
    }
}

module spark_pos() {
    s_s=13.5;
    s_h=3;
    s_d=2.8;
    pier_d=5;
    pier_h=s_h;
    
    translate([0,s_s/2,0]) {
        difference() {
            cylinder(pier_h, d=pier_d);
            cylinder(s_h, d=s_d);
        }
    }
    translate([0,-s_s/2,0]) {
        difference() {
            cylinder(pier_h, d=pier_d);
            cylinder(s_h, d=s_d);
        }
    }
    
    /*
    // tmp
    translate([-2.5,-18.5/2,pier_h]) {
        cube([24.5,17.5,1.6]);
    }
    */
}

module spark_neg() {
    s_s=13.5;
    s_h=4;
    s_d=2.8;
    pier_d=5;
    pier_h=s_h;
    
    translate([0,s_s/2,-s_h]) {
        cylinder(s_h, d=s_d);
    }
    translate([0,-s_s/2,-s_h]) {
        cylinder(s_h, d=s_d);
    }    
}

module byj() {
    byj_d=29;
    byj_h=20;
    s_h=8;
    s_d=2.8;
    s_s=35;
    shaft_d=10.5;
    shaft_h=10;
    
    // core
    cylinder(byj_h, d=byj_d);
    
    // shaft
    translate([-8,0,-shaft_h]) {
        cylinder(shaft_h, d=shaft_d);
    }
    
    // screw
    translate([0,s_s/2,-s_h]) {
        cylinder(s_h, d=s_d);
    }
    translate([0,-s_s/2,-s_h]) {
        cylinder(s_h, d=s_d);
    }
    
    // screws plate
    translate([-8/2,-35/2,0]) {
        cube([8,35,byj_h]);
    }
    translate([0,35/2,0]) {
        cylinder(byj_h, d=8);
    }
    translate([0,-35/2,0]) {
        cylinder(byj_h, d=8);
    }
    
    // cable plate
    translate([byj_d/2-3,-18/2,0]) {
        cube([10,18,byj_h]);
    }
}


module screw() {
    translate([-ring1_d/2-screw_h2-screw_h1,0,0]) {
        rotate([0,90,0]) {
            translate([-screw_pos,0,0]) {
                cylinder(screw_h2, d=screw_d2);
                translate([0,0,screw_h2]) {
                    cylinder(2*screw_h1, d=screw_d1);
                }
            }
        }
    }
}


////
difference() {
    // base
    union() {
        // round
        cylinder(core_h, d=core_d);
        // plate
        translate([0,-core_d/2,0]) {
            cube([core_l-core_d/2,core_d,core_h]);
            translate([core_l-core_d/2,core_d/2,0]) {
                cylinder(core_h, d=core_d);
            }
        }
        /*
        // hull
        translate([0,0,-ring3_h]) {
            difference() {
                cylinder(ring3_h, d=core_d);
                cylinder(ring3_h, d=core_d-2*wall);
                translate([core_d/2.5,-ring1_d/2/2,0]) {
                    cube([ring1_d/2, ring1_d/2, ring3_h]);
                }
            }
        }
        */
        
        // spark holder
        translate([ring1_d/2+1.5,-core_d/2+3.7,ring1_h+ring2_h]) {
            rotate([0,0,-90]) {
                //spark_pos();
            }
        }
        
        // DRV holder
        translate([core_d/2.5,core_d/2.8,ring1_h+ring2_h]) {
            //stp_drv_pos();
        }
    }
    
    // spark holder
    translate([ring1_d/2+1.5,-core_d/2+3.7,ring1_h+ring2_h]) {
            rotate([0,0,-90]) {
                spark_neg();
            }
    }
    
    // rotator hole
    cylinder(ring2_h+ring1_h, d=ring2_d);
    cylinder(ring1_h, d=ring1_d);
    
    // screw holes
    screw();
    rotate([0,0,120]) {
        screw();
    }
    rotate([0,0,-120]) {
        screw();
    }
    
    // motor hole
    translate([ring1_d/2+wall+14,0,ring2_h]) {
        byj();
    }
    
    // hull screws
    translate([0,core_d/2,(ring1_h+ring2_h)/2]) {
        rotate([90,0,0]) {
            cylinder(10, d=2.8);
        }
    }
    translate([0,-core_d/2,(ring1_h+ring2_h)/2]) {
        rotate([-90,0,0]) {
            cylinder(10, d=2.8);
        }
    }
    translate([core_l-core_d/2+2,core_d/2,(ring1_h+ring2_h)/2]) {
        rotate([90,0,0]) {
            cylinder(10, d=2.8);
        }
    }
    translate([core_l-core_d/2+2,-core_d/2,(ring1_h+ring2_h)/2]) {
        rotate([-90,0,0]) {
            cylinder(10, d=2.8);
        }
    }
    
    // drv neg
    translate([core_d/2.5,core_d/2.8,1]) {
        stp_drv_neg();
    }
    
    // hull screw holes
    translate([ring1_d/2,ring1_d/3,0]) {
        cylinder(8, d=2.8);    
    }
    translate([ring1_d/2,-ring1_d/3,0]) {
        cylinder(8, d=2.8);    
    }
}
