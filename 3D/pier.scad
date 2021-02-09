s_d=3;
p_d=5;
p_h=3;

$fn=90;

difference() {
    cylinder(p_h, d=p_d);
    cylinder(p_h, d=s_d);
}