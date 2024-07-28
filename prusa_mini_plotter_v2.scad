// Prusa Mini pen plotter mounting bracket compatible with Bic crystal pens

// All units are in mm
include <NopSCADlib/utils/quadrant.scad>
include <NopSCADlib/utils/round.scad>
include <NopSCADlib/utils/rounded_cylinder.scad>
include <NopSCADlib/utils/sector.scad>
include <NopSCADlib/utils/thread.scad>
include <NopSCADlib/vitamins/screws.scad>

include <NopSCADlib/vitamins/fan.scad>
include <NopSCADlib/vitamins/fans.scad>

$fn = 100;

// The heatsink screw holes align exactly with the fan screw holes
// https://www.delta-fan.com/Download/Spec/AFB0405VHA-A.pdf
screw_radius = 4;
screw_hole_diameter = 3.2;
bottom_screw = [ 4, 4 ];
upper_screw = bottom_screw + [ 32, 32 ];
shroud_protrusion = 2;
fan_center = [ 20, 20 ];
fan_dims = [ 40, 40, 11 ];
fan_spacer_dims = [ 42.5, 49, 6 ];
heatsink_dims = [ 46, 55, 12 ];
// How far out the mount sticks from the print head
mount_protrusion = 4;

// holder_height = 12;
// fan_width = 11;
heatsink_width = heatsink_dims[2];

// Measurements from a Bic crystal
pen_diameter = 9;
pen_radius = pen_diameter / 2;
pen_length = 145;
pen_narrowing_len = 15;
pen_tip_diameter = 1;

// tighten the fit so the pen won't slide easily
pen_holder_inner_diameter = pen_diameter - 0.4;
pen_holder_outer_diameter = pen_diameter + 1;
pen_holder_length = 10;
pen_holder_y = 10;
// Angle from the vertical for a human "holding a pen"
pen_holder_angle = 35;

module heatsink() {
  translate([ 0, 0, -heatsink_dims[2] ]) {
    translate(heatsink_dims / 2) color("Silver")
        import("stl/MINI-heatsink.stl");
    translate([ 0, 0, -fan_spacer_dims[2] ]) {
      translate(fan_spacer_dims / 2) color("RoyalBlue")
          import("stl/MINI-fan-spacer.stl");
      translate([ fan_dims[0] / 2, fan_dims[1] / 2 ]) rotate([ 180, 0, 0 ])
          translate([ 0, 0, fan_dims[2] ]) fan_assembly(fan40x11, 12, true);
    }
  }
}

// Mount model onto printer heatsink
module heatsink_mount() {
  // screw hole areas
  linear_extrude(shroud_protrusion) difference() {
    union() {
      for (movement = [[bottom_screw - [mount_protrusion, 0], [0, 0]],
                       [upper_screw + [0, mount_protrusion], [180, 0, -90]]]) {
        t = movement[0];
        r = movement[1];

        translate(t) rotate(r) {
          difference() {
            union() {
              rotate([ 0, 0, -90 ]) translate([ -mount_protrusion, 0 ])
                  quadrant(screw_radius + mount_protrusion, screw_radius);
              rotate([ 0, 0, 180 ]) quadrant(screw_radius, screw_radius);

              translate([ -screw_radius, 0 ])
                  square([ 2 * screw_radius + mount_protrusion, screw_radius ]);
              translate([ -screw_radius + mount_protrusion, screw_radius ])
                  right_triangle(2 * screw_radius,
                                 fan_center[0] - 2 * screw_radius);
            }
          }
        }
      }
    }
    // ensure the heatsink fins are not blocked
    translate(fan_center) circle(fan_center.x);
    // cut screw holes
    for (t = [ bottom_screw, upper_screw ])
      translate(t) circle(d = screw_hole_diameter);
  }

  // rest of the mount that wraps around the heatsink
  union() {
    // align with curvature of heatsink
    translate([ 0, 0, -heatsink_width ])
        linear_extrude(heatsink_width + shroud_protrusion)
            translate(fan_center) {
      difference() {
        sector(fan_center.x + mount_protrusion, 90, 180);
        sector(fan_center.x, 90, 180);
      }
    }
    // extend the screw hole areas out and around the out
    for (params = [
           [ [ 0, 0 ], [ 0, 0, 0 ], true ],
           [ 2 * fan_center, [ 180, 0, -90 ], false ]
         ]) {
      t = params[0];
      r = params[1];
      full = params[2];
      h = full ? heatsink_width + shroud_protrusion : shroud_protrusion;
      z = full ? -heatsink_width : 0;
      translate([ 0, 0, z ]) linear_extrude(h) translate(t) rotate(r)
          translate([ -mount_protrusion, screw_radius ]) {
        square([ mount_protrusion, fan_center.y - screw_radius ]);
      }
    }
  }
}

module bic_crystal() {
  rotate([ 180, 0, 0 ]) {
    color("silver") linear_extrude(height = pen_length, center = true) {
      polygon([for (i = [1:6])[pen_radius * cos(i * 360 / 6),
                               pen_radius * sin(i * 360 / 6)]]);
    }
    translate([ 0, 0, -pen_length / 2 - pen_narrowing_len / 2 ]) color("tan")
        rotate([ 180, 0, 0 ])
            linear_extrude(height = pen_narrowing_len, center = true,
                           scale = pen_tip_diameter / pen_narrowing_len) {
      polygon([for (i = [1:6])[pen_radius * cos(i * 360 / 6),
                               pen_radius * sin(i * 360 / 6)]]);
    }
  }
}

module pen_attachment() {
  pen_holder_x_angle_offset =
      (pen_holder_outer_diameter / 2) / sin(90 - pen_holder_angle);
  pen_holder_y_shift_offset =
      pen_holder_y * sin(pen_holder_angle) / sin(90 - pen_holder_angle);

  pen_holder_default_x = -mount_protrusion - pen_holder_outer_diameter / 2;
  pen_holder_x =
      -pen_holder_x_angle_offset - pen_holder_y_shift_offset - mount_protrusion;

  // attaches pen holder to the mount
  difference() {
    hull() {
      // cube at the side of the mount
      translate([ pen_holder_default_x, pen_holder_y, -heatsink_width / 2 ])
          rotate([ 90, 90, 0 ]) {
        linear_extrude(pen_holder_length, center = true)
            square(pen_holder_outer_diameter, center = true);
      }
      // actual plotter arm position
      translate([ pen_holder_x, pen_holder_y, -heatsink_width / 2 ])
          rotate([ 90, 90, pen_holder_angle ]) {
        linear_extrude(pen_holder_length, center = true)
            circle(d = pen_holder_outer_diameter);
      }
    }

    translate([ pen_holder_x, pen_holder_y, -heatsink_width / 2 ])
        rotate([ 90, 90, pen_holder_angle ]) {
      linear_extrude(2 * pen_holder_length, center = true) {
        side_angle = 360 / 6;
        hexagon_angles = [for (i = [0:5]) i * side_angle];
        polygon(
            [for (a = hexagon_angles)[pen_holder_inner_diameter / 2 * cos(a),
                                      pen_holder_inner_diameter / 2 * sin(a)]]);
        // Cutout for flex
        sector(r = pen_holder_outer_diameter,
               start_angle = hexagon_angles[4] - side_angle / 3,
               end_angle = hexagon_angles[5] + side_angle / 3);
      }
    }
  }
  if ($preview)
    translate([ pen_holder_x, pen_holder_y, -heatsink_width / 2 ])
        rotate([ 90, 90, pen_holder_angle ]) bic_crystal();
}

if ($preview)
  heatsink();
heatsink_mount();

pen_attachment();

// module pen_holder() {
//   height = 12;
//   max_pen_size = 14;
//   width = 3;
//   outer = max_pen_size + width;
//   outer_snub = 2;
//   thumbscrew_diameter = 3;
//   thumbscrew_insert_width = thumbscrew_diameter + 1;
//   thread_length = width / sqrt(2) + max_pen_size * (sqrt(2) - 1) / 2;

//   translate([ 0, -outer / sqrt(2), 0 ]) {
//     // Show max size pen in pen holder
//     if ($preview) {
//       pen_depth = height / 2 + 20;
//       translate([ 0, 0, -pen_depth + height / 2 ]) color("red", 0.8)
//           cylinder(h = pen_depth, r1 = 1, r2 = max_pen_size / 2);
//       translate([ 0, 0, height / 2 ]) color("white", 0.8)
//           cylinder(h = 120, r = max_pen_size / 2);
//     }
//     difference() {
//       union() {
//         linear_extrude(height) {
//           difference() {
//             rotate([ 0, 0, 45 ]) difference() {
//               difference() {
//                 square(outer, center = true);
//                 // don't snub the inner side
//                 for (i = [90:90:270]) {
//                   rotate([ 0, 0, i ]) translate([ outer, outer ] / 2)
//                       rotate([ 0, 0, 45 ]) square(outer_snub, center = true);
//                 }
//               }
//               square(max_pen_size, center = true);
//             }
//           }
//         }
//         translate([ 0, -max_pen_size / 2, height / 2 ]) rotate([ 90, 0, 0 ])
//             translate(
//                 [ -thumbscrew_insert_width / 2, -thumbscrew_insert_width / 2
//                 ]) cube([
//                   thumbscrew_insert_width, thumbscrew_insert_width,
//                   thread_length
//                 ]);
//       }
//       // screw thread tap
//       translate([ 0, -max_pen_size / 2, height / 2 ]) rotate([ 90, 0, 0 ])
//           male_metric_thread(thumbscrew_diameter,
//                              metric_coarse_pitch(thumbscrew_diameter),
//                              thread_length, top = -1, bot = -1, center =
//                              false);
//     }
//   }
// }

// module pen_arm() {
//   linear_extrude(holder_height) {
//     // extra + 1 is for CGAL to join the polygons and not get mad at me
//     rotate([ 180, 0, 0 ])
//         right_triangle(8, heatsink_width / 2 + 1, center = false);
//     translate([ 0, -heatsink_width ])
//         right_triangle(8, heatsink_width / 2 + 1, center = false);
//   }
//   // make a clean join with the heatsink bracket
//   translate([ 0, 0, 3 * holder_height / 4 ]) linear_extrude(holder_height /
//   4) {
//     rotate([ 0, 0, 180 ]) square([ 2, heatsink_width ]);
//   }
// }
// translate([ 0, 0, holder_z ]) rotate([ 0, 0, -90 ]) pen_arm();
// translate([ -heatsink_width / 2, 0, holder_z ]) pen_holder();