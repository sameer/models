// Prusa Mini pen plotter mounting bracket
// All units are in mm
include <NopSCADlib/utils/quadrant.scad>
include <NopSCADlib/utils/round.scad>
include <NopSCADlib/utils/rounded_cylinder.scad>
include <NopSCADlib/utils/sector.scad>
include <NopSCADlib/utils/thread.scad>
include <NopSCADlib/vitamins/screws.scad>
include <NopSCADlib/vitamins/fans.scad>
include <NopSCADlib/vitamins/fan.scad>

$fn=100;


module heatsink_mount() {
    // The heatsink screw holes align exactly with the fan screw holes
    // https://www.delta-fan.com/Download/Spec/AFB0405VHA-A.pdf
    screw_radius = 4;
    screw_hole_diameter = 3.2;
    bottom_screw = [4, 4];
    min_m3_12_protrusion = 5;
    screw_protrusion = min_m3_12_protrusion + 3;
    fan_center = [20, 20];
    fan_bracket_width = 2;
    upper_screw = bottom_screw + [32, 32];
    // does not work right now
    use_upper_screw = true;

    // Show printer parts for reference
    if ($preview) {
        translate([-(fan_width + shroud_width + heatsink_width), 20, 20])
        rotate([90,0,-90]) {
            fan_assembly(fan40x11, 12, true);
            translate([0, 0, -fan_width])
            rotate([0, 180, 180])
            translate([-199,-147])
            color("RoyalBlue")
            import("stl/MINI-fan-spacer.stl");
            translate([0, 0, -(fan_width + shroud_width + heatsink_width)])
            translate(-fan_center)
            color("DarkSlateGray") linear_extrude(heatsink_width) quadrant(40, fan_center.x);
        }
    }
    // screw hole + attach to pen arm
    rotate([90,0,90])
    linear_extrude(screw_protrusion)
    difference() {
        union() {
            translate(bottom_screw - [fan_bracket_width, 0]) {
                rotate([0, 0, -90])
                translate([-fan_bracket_width,0])
                quadrant(screw_radius+fan_bracket_width, screw_radius);
                rotate([0, 0, 180])
                quadrant(screw_radius, screw_radius);
                
                translate([-screw_radius, 0]) square([2*screw_radius+fan_bracket_width, screw_radius]);
                translate([-screw_radius+fan_bracket_width,screw_radius]) right_triangle(2*screw_radius, holder_z - 2*screw_radius);
            }
            if (use_upper_screw) translate(upper_screw) {
                rotate([0, 0, -90])
                quadrant(screw_radius, screw_radius);
                translate([-fan_bracket_width,0])
                quadrant(screw_radius+fan_bracket_width, screw_radius);
                
                translate([0, screw_radius + fan_bracket_width]) rotate([0,0,180]) square([screw_radius, 2*screw_radius+fan_bracket_width]);
                
                translate([-screw_radius, screw_radius]) rotate([0,0,180]) right_triangle(holder_z - 2*screw_radius, 2*screw_radius);
            }
        }
        // ensure the heatsink finks are not blocked
        translate(fan_center) circle(fan_center.x);
        translate(bottom_screw) circle(d=screw_hole_diameter);
        if (use_upper_screw) translate(upper_screw) circle(d=screw_hole_diameter);
        
    }
    
    union() {
        // use heatsink for alignment
        translate([-heatsink_width,0,0])
        rotate([90,0,90])
        linear_extrude(heatsink_width + screw_protrusion)
        translate(fan_center) {
            difference() {
                sector(fan_center.x + fan_bracket_width, 90, 180);
                sector(fan_center.x, 90, 180);
            }
        }
        translate([-heatsink_width,0,0])
        rotate([90,0,90])
        linear_extrude(heatsink_width + screw_protrusion)
        translate([-fan_bracket_width,screw_radius]) {
            square([fan_bracket_width, fan_center.y - screw_radius]);
            translate([screw_radius,0])
            rotate([0,0,180])
            difference() {
                quadrant(screw_radius, screw_radius);
                square([screw_radius/2, screw_radius]);
            }
        }
        if(use_upper_screw) {
            rotate([90,0,90])
            linear_extrude(screw_protrusion)
            translate([-fan_bracket_width,screw_radius] + upper_screw) translate([0,screw_radius/2]) rotate([0,180,90]) {
                square([fan_bracket_width, fan_center.y - screw_radius]);
                translate([screw_radius,0])
                rotate([0,0,180])
                difference() {
                    quadrant(screw_radius, screw_radius);
                    square([screw_radius/2, screw_radius]);
                }
            }
        }
    }
}

module pen_holder() {
    height = 12;
    max_pen_size = 14;
    width = 3;
    outer = max_pen_size + width;
    outer_snub = 2;
    thumbscrew_diameter = 3;
    thumbscrew_insert_width = thumbscrew_diameter + 1;
    thread_length = width/sqrt(2) + max_pen_size * (sqrt(2)-1)/2;

    translate([0, -outer/sqrt(2), 0]) {
        // Show max size pen in pen holder
        if ($preview) {
            pen_depth = height/2 + 20;
            translate([0,0,-pen_depth + height/2])
            color("red", 0.8) cylinder(h=pen_depth, r1=1, r2=max_pen_size/2);
            translate([0,0,height/2])
            color("white", 0.8) cylinder(h=120, r=max_pen_size/2);
        }
        difference() {
            union() {
                linear_extrude(height) {
                    difference() {
                        rotate([0,0,45]) difference() {
                            difference() {
                                square(outer, center=true);
                                // don't snub the inner side
                                for (i = [90:90:270]) {
                                rotate([0,0,i]) translate([outer, outer]/2) rotate([0,0,45])
                                square(outer_snub, center=true);
                                }
                            }
                            square(max_pen_size, center=true);
                        }
                    }
                }
                translate([0, -max_pen_size/2, height/2]) rotate([90,0,0]) translate([-thumbscrew_insert_width/2, -thumbscrew_insert_width/2]) cube([thumbscrew_insert_width, thumbscrew_insert_width, thread_length]);
            }
            // screw thread tap
            translate([0, -max_pen_size/2, height/2]) rotate([90,0,0])
            male_metric_thread(thumbscrew_diameter, metric_coarse_pitch(thumbscrew_diameter), thread_length, top=-1, bot=-1, center=false);
        }
    }
}

module pen_arm() {
    linear_extrude(holder_height) {
        // extra + 1 is for CGAL to join the polygons and not get mad at me
        rotate([180, 0, 0])
        right_triangle(8, heatsink_width/2 + 1, center=false);
        translate([0,-heatsink_width])
        right_triangle(8, heatsink_width/2 + 1, center=false);
    }
    // make a clean join with the heatsink bracket
    translate([0,0,3*holder_height/4]) linear_extrude(holder_height/4) {
        rotate([0,0,180])
        square([2, heatsink_width]);
    }
}

holder_height = 12;
holder_z = 20;
fan_width = 11;
heatsink_width = 12;
shroud_width = 6;

heatsink_mount();
translate([0, 0, holder_z])
rotate([0,0,-90])
pen_arm();
translate([-heatsink_width/2, 0, holder_z])
pen_holder();

