core_h=8+15;
core_d=80;
core_l=80;

ring_d=/*52.25*/60;

wall=2;
gap=2;

$fn=90;

module torus(r1=1, r2=2, angle=360, endstops=0, $fn=50){
    if(angle < 360){
        intersection(){
            rotate_extrude(convexity=10, $fn=$fn)
            translate([r2, 0, 0])
            circle(r=r1, $fn=$fn);
            
            color("blue")
            wedge(h=r1*3, r=r2*2, a=angle);
        }
    }else{
        rotate_extrude(convexity=10, $fn=$fn)
        translate([r2, 0, 0])
        circle(r=r1, $fn=$fn);
    }
    
    if(endstops && angle < 360){
        rotate([0,0,angle/2])
        translate([0,r2,0])
        sphere(r=r1);
        
        rotate([0,0,-angle/2])
        translate([0,r2,0])
        sphere(r=r1);
    }
}

module rounded_cylinder(d=1, h=1, r=0.1, center=false, $fn=100){
    translate([0,0,(center==true)?-h/2:0]){
        union(){
            // bottom edge
            translate([0,0,r])torus(r1=r, r2=(d-r*2)/2, $fn=$fn);
            // top edge
            translate([0,0,h-r])torus(r1=r, r2=(d-r*2)/2, $fn=$fn);
            // main cylinder outer
            translate([0,0,r])cylinder(d=d, h=h-r*2, center=false, $fn=$fn);
            // main cylinder inner
            translate([0,0,0])cylinder(d=d-r*2, h=h, center=false, $fn=$fn);
        }
    }
}

difference() {
    hull() {
        // round
        rounded_cylinder(h=core_h+wall, d=core_d+2*wall, r=2);
        translate([core_l-core_d/2,0,0]) {
            rounded_cylinder(h=core_h+wall, d=core_d+2*wall, r=2);
        }
    }
    
    hull() {
        // round
        cylinder(core_h, d=core_d-gap);
        translate([core_l-core_d/2,0,0]) {
            cylinder(core_h, d=core_d-gap);
        }
    }
    
    hull() {
        // round
        cylinder(8, d=core_d);
        // plate
        translate([core_l-core_d/2,0,0]) {
            cylinder(8, d=core_d);
        }
    }
    
    cylinder(core_h+wall, d=ring_d);
    
    // hull screws
    translate([-0.5,core_d/2+wall,8/2]) {
        rotate([90,0,0]) {
            cylinder(8, d=3.5);
        }
    }
    translate([0.5,-core_d/2-wall,8/2]) {
        rotate([-90,0,0]) {
            cylinder(8, d=3.5);
        }
    }
    translate([core_l-core_d/2+1.5,core_d/2+wall,8/2]) {
        rotate([90,0,0]) {
            cylinder(8, d=3.5);
        }
    }
    translate([core_l-core_d/2+2.5,-core_d/2-wall,8/2]) {
        rotate([-90,0,0]) {
            cylinder(8, d=3.5);
        }
    }
    
    // usb recess
    translate([ring_d/2-1.5-10/2,-core_d/2,8]) {
        cube([20,gap,8]);
    }
    
    // usb hole
    translate([ring_d/2-2,-core_d/2-wall,6]) {
        cube([11,wall,7]);
    }
}