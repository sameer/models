// Air Purifier built using:
// * VortexAir True HEPA Filter ($30) https://www.homedepot.com/p/LEVOIT-VortexAir-True-HEPA-Replacement-Filter-HEACAFLVNUS0012/317963268
// * Noctua NF-A8 PWM ($20) https://noctua.at/en/nf-a8-pwm
// * 5V to 12V USB Boost Converter ($9) https://www.amazon.com/gp/product/B01AY3XLEY/
// * USB-A wall charger (free)
// * This adapter

include <NopSCADlib/utils/tube.scad>
include <NopSCADlib/utils/core/rounded_rectangle.scad>
include <NopSCADlib/vitamins/screws.scad>
include <NopSCADlib/vitamins/fan.scad>
include <NopSCADlib/vitamins/fans.scad>

inner_radius = 112 / 2;
inner_to_foam_width = 12;
foam_width = 13.2;
foam_to_outer_width = 15;
outer_radius = inner_radius + inner_to_foam_width + foam_width + foam_to_outer_width;
height=147;

module filter() {
    union() {
        color("snow")
        tube(or=outer_radius, ir=inner_radius, h=height, center=false);
        color("gray")
        tube(or=outer_radius - foam_to_outer_width, ir=inner_radius + inner_to_foam_width, h=height+1, center=false);
    }
}

hood_radius = inner_radius + inner_to_foam_width + foam_width;
hood_rim_radius = inner_radius - 4;
hood_rim_thickness = 1;
hood_lip_height = 15;
hood_lip_thickness = 1;
hood_height = 20;
module hood() {    
    union() {
        tube(ir=hood_rim_radius , or=hood_radius, h=hood_rim_thickness, center=false);
        translate([0,0,-hood_lip_height])
        tube(ir=hood_rim_radius, or=hood_rim_radius + hood_lip_thickness, h=hood_lip_height, center=false);
    }
}

fan_width = fan_width(fan80x25);
fan_depth = fan_depth(fan80x25);
fan_mount_thickness = 2;
fan_hole_pitch = fan_hole_pitch(fan80x25);
fan_corner_radius = fan_width / 2 - fan_hole_pitch;
fan_mount_height = hood_height + fan_width / 2;
module fan_mount() {
    difference() {
        cylinder(d=sqrt(2)*fan_width, h=fan_mount_thickness);
        fan_holes(fan80x25);
    }
}

shroud_thickness = 1;
shroud_height = fan_mount_height - fan_mount_thickness;
module shroud() {
    difference() {
        cylinder(r1=hood_radius, r2=sqrt(2)*fan_width/2,h=shroud_height);
        cylinder(r1=hood_radius-shroud_thickness, r2=sqrt(2)*fan_width/2-shroud_thickness,h=shroud_height);
    }
}

if ($preview) {
    filter();
}
translate([0,0,height + 1]) hood();
translate([0,0, height + fan_mount_height]) translate([0, 0, -fan_mount_thickness/2]) {
    fan_mount();
    
    if ($preview) {
        translate([0,0,fan_depth])
        fan_assembly(fan80x25, 25, include_fan = true, full_depth = false);
    }
}

translate([0,0,height+2])
shroud();
