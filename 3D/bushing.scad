diam=5;
height=10;

$fn=90;

difference() {
    cylinder(h=2*height, d=diam);
    translate([0,0,2*height+1.5]) {
        rotate([0,120,0]) {
            cube([2*height,2*height,2*height], center=true);
        }
    }
}