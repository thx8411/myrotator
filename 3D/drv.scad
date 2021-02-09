
$fn=90;

module stp_drv_pos() {
    drv_l=20.6;
    drv_w=15.5;
    drv_h=1.6;
    s_d=2.8;
    s_h=4;
    gap=1;
    
    difference() {
        union() {
            translate([0,0,drv_h/2+gap]) {
                cube([drv_l+2*gap,drv_w/2,drv_h+2*gap], center=true);
            }
            translate([-5,0,-drv_h-2*gap]) {
                cylinder(s_h, d=s_d);
            }
            translate([5,0,-drv_h-2*gap]) {
                cylinder(s_h, d=s_d);
            }
        }
        translate([0,0,drv_h/2+gap]) {
            cube([drv_l,drv_w,drv_h], center=true);
        }
        translate([0,0,drv_h+gap]) {
            cube([drv_l-1.2,drv_w,2*gap], center=true);
        }
    }
}

stp_drv_pos();