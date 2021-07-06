// Replacement igniter shaft for Channel Products 1061 Twist/Turn Igniter
//
// This part fits into place by deforming the flange plastic.
// It does not use the OEM snap ring.

include <NopSCADlib/utils/rounded_cylinder.scad>

in_to_mm = 25.4;

knob_diameter = 14/64 * in_to_mm;
knob_height = 51/64 * in_to_mm;

knob_notch_width = 1/64 * in_to_mm;
knob_notch_height = 24/64 * in_to_mm;

knob_stopper_diameter = knob_diameter + 4/64 * in_to_mm;
knob_stopper_height = 3/64 * in_to_mm;
knob_stopper_z = knob_height - knob_stopper_height - 16/64 * in_to_mm;

fitted_piece_diameter = 20/64 * in_to_mm;
fitted_piece_height = 35 / 64 * in_to_mm;

flanges = 4;
flange_extent = fitted_piece_diameter / 2 + 1/64 * in_to_mm;
flange_width = 2/64 * in_to_mm;
flange_height = knob_stopper_z;

gear_height = 8/64 * in_to_mm;
gear_inner_radius = fitted_piece_diameter/2 + 17/64 * in_to_mm;
gear_outer_radius = fitted_piece_diameter/2 + 23/64 * in_to_mm;
teeth = 6;

$fn = 64;

module knob() {
    difference() {
        union() {
            rounded_cylinder(r=knob_diameter/2, r2=knob_diameter/8, h=knob_height);
            translate([0, 0, knob_stopper_z])
            cylinder(r=knob_stopper_diameter/2, h=knob_stopper_height);
        }
        translate([0, 0, knob_height - knob_notch_height / 2])
        cube([knob_stopper_diameter, knob_notch_width, knob_notch_height], center=true);
    }
    for(i = [0:flanges-1]) {
        rotate([0, 0, 45 + i * 360 / flanges])
        translate([0, -flange_width/2, 0])
        cube([flange_extent, flange_width,  flange_height]);
    }
}

module fitted() {
    linear_extrude(fitted_piece_height) {
        circle(d=fitted_piece_diameter);
    }
}

module gear() {
    linear_extrude(gear_height) {
        circle(r=gear_inner_radius);
        degrees = 360 / teeth;
        for(i = [0:teeth-1]) {
            rotate([0, 0, i * degrees])
            polygon([
                [0, 0],
                [0, gear_inner_radius],
                [cos(degrees) * gear_outer_radius, sin(degrees) * gear_outer_radius]
            ]);
            echo(i);
        }
    }
}
translate([0, 0, gear_height]) {
    translate([0, 0, fitted_piece_height])
    knob();
    fitted();
}
gear();
