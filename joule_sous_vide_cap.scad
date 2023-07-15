// Replacement cap for the Joule Sous Vide by ChefSteps
//
// This cap fits on top well but does not depress the button very well. I would recommend extending the "poker" a little

include <NopSCADlib/utils/rounded_cylinder.scad>
include <NopSCADlib/utils/sector.scad>

$fn = 200;

cap_height = 13.6;
cap_thickness = 1.2;
cap_increased_thickness = 1.75;
cap_increased_thickness_height = 2;
cap_outer_radius = 47 / 2;
cap_inner_radius = cap_outer_radius - cap_increased_thickness;
round_radius = 4;

touch_affordance_radius = 15.5 / 2;
touch_affordance_sphere_depth = cap_thickness * 7/8;
touch_affordance_sphere_radius = (touch_affordance_radius^2 + touch_affordance_sphere_depth^2) / (2*touch_affordance_sphere_depth);
touch_affordance_radial_pos = 8;

light_hole_radius = 2.9 / 2;
light_hole_depth = cap_thickness / 2;
light_hole_height = 4.6;

groove_width = 2;
groove_sector_start_angle = 30;
groove_sector_end_angle = 330;
groove_height = light_hole_height + groove_width / 2;
groove_outer_radius = cap_inner_radius + 1;

poker_height = groove_height + groove_width;
poker_diameter = 1;
poker_length = cap_height - cap_thickness - poker_height;

retainer_width = 5.3;
retainer_thickness = 0.93;
retainer_flap_width = 3;
retainer_flap_thickness = 2.7;
retainer_length = 5/64 * 25.4;
retainer_height = cap_height - cap_thickness - retainer_length;

retainer_radial_pos = [15.32, -7.76];


module cap() {
    difference() {
        rounded_cylinder(r=cap_outer_radius, h=cap_height, r2=4);
        translate([0,0,$preview ? -0.01 : 0])
        cylinder(r=cap_outer_radius - cap_thickness, h=cap_increased_thickness_height);
        translate([0,0,cap_increased_thickness_height + ($preview ? -0.02 : 0)])
        cylinder(r=cap_outer_radius - cap_increased_thickness, h=cap_height - cap_thickness - cap_increased_thickness_height);


        translate([touch_affordance_radial_pos ,0,cap_height + (touch_affordance_sphere_radius - touch_affordance_sphere_depth)])
        sphere(r=touch_affordance_sphere_radius);
        
        translate([cap_inner_radius  -0.1,0,light_hole_height])
        rotate([0,90,0])
        cylinder(r=light_hole_radius, h=cap_increased_thickness+0.1);
        
        translate([0,0,groove_height]) {
            linear_extrude(groove_width)
            difference() {
                sector(r=groove_outer_radius, start_angle=groove_sector_start_angle, end_angle=groove_sector_end_angle);
                sector(r=cap_inner_radius, start_angle=groove_sector_start_angle-1, end_angle=groove_sector_end_angle+1);
            }
        }
    }
}

module poker() {
    translate([touch_affordance_radial_pos,0,poker_height])
    cylinder(d1=poker_diameter, d2=2*poker_diameter, h=poker_length);
}

module retainers() {
    for (x = [[0,1], [1,-1]]) {
        translate([retainer_radial_pos[x[0]]+x[1]*retainer_thickness/2,0,retainer_height + retainer_length/2]) {
            cube([retainer_thickness, retainer_width, retainer_length], center=true);
            translate([x[1]*retainer_flap_width/2,0])
            cube([retainer_flap_width, retainer_flap_thickness, retainer_length], center=true);
        }
    }
}

cap();
poker();
retainers();

if ($preview) {
    color("white")
    cylinder(r=cap_outer_radius,h=200);
    translate([0,0,200]) {
        cap();
        poker();
        retainers();
    }
} else {
    cap();
    poker();
    retainers();
}