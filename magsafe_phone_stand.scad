// Magsafe Phone Stand
//
// A simple, press-fit phone stand for the Apple MagSafe Charger
//
// Resources:
// https://developer.apple.com/accessories/Accessory-Design-Guidelines.pdf
//
include <NopSCADlib/utils/bezier.scad>;

$fn = 100;
epsilon = $preview ? 0.001 : 0;

// iPhone 15 Plus at the time of writing
max_iphone_length = 160.89;
case_allowance = 5;
magsafe_position = max_iphone_length  / 2 + case_allowance;

// MagSafe Charger Measurements
puck_diameter = 55.90;
puck_thickness = 5.40;
puck_pad_diameter_approx = puck_diameter - 2*3.37;
wire_sheath_diameter = 3.80;
wire_sheath_length = 10.22;
wire_diameter = 2.75;
wire_usbc_connector_width = 14;

// Model parameters
stand_angle = 60;
stand_holder_length = magsafe_position;
stand_depth = cos(stand_angle)*stand_holder_length;
stand_height = sin(stand_angle)*stand_holder_length;
stand_base_depth = 2*stand_depth;
stand_thickness = 1;
stand_width = puck_diameter + 1;

puck_holder_diameter = stand_width;
puck_holder_thickness = puck_thickness + stand_thickness;

module puck() {
    color("silver")
    cylinder(d=puck_diameter, h=puck_thickness);
    color("white")
    translate([0,0,epsilon])
    cylinder(d=puck_pad_diameter_approx, h=puck_thickness + 0.1);
    
    color("white")
    translate([0,-puck_diameter/2,puck_thickness/2]) rotate([90,0,0]) {
        cylinder(d=wire_sheath_diameter, h=wire_sheath_length, center = false);
        translate([0,0,wire_sheath_length]) cylinder(d=wire_diameter, h=20, center = false);
    }
}

// Just a straight line, this segment has to match the angle exactly
stand_magsafe_control_points = [
    [stand_depth, stand_height],
    [stand_depth,stand_height]*(1- puck_diameter/stand_holder_length)
];
stand_front_control_points = [
    [stand_depth,stand_height]*(1- puck_diameter/stand_holder_length),
    [0,0],
    [10,0]
];

stand_base_control_points = [
    [10,0],
    [stand_base_depth,0],
    [stand_base_depth,1]
];

module stand() {
    points = concat(
        bezier_path(stand_magsafe_control_points, steps=500),
        bezier_path(stand_front_control_points, steps=500),
        bezier_path(stand_base_control_points, steps=500)
    );
    difference() {
        translate([-stand_width/2,0]) rotate([90,0,90]) linear_extrude(stand_width, convexity=2) union() for (p = points) translate(p) circle(r=stand_thickness/2);
        rotate([stand_angle,0]) translate([0,magsafe_position,-puck_thickness+stand_thickness/2]) cylinder(d=puck_diameter, h=puck_thickness+epsilon);
    }
}

module puck_holder() {
    difference() {
        cylinder(d=puck_holder_diameter, h=puck_holder_thickness);
        translate([0,0,stand_thickness+epsilon]) cylinder(d=puck_diameter,h=puck_thickness);
        // Add a hole for removing the puck with a pen
        translate([0,0,-epsilon]) cylinder(d=5, h=puck_holder_thickness+epsilon);
        translate([0,-puck_diameter/2,(puck_holder_thickness)/2]) cube([wire_usbc_connector_width, 10, 29], center=true);
    }
}


if($preview) {
    rotate([stand_angle, 0])
    translate([0,magsafe_position,-puck_thickness]) {
        puck();
    }
}

rotate([stand_angle,0]) translate([0,magsafe_position,-puck_thickness-stand_thickness/2]) puck_holder();
stand();
