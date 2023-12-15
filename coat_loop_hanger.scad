// A simple hanger designed for suspending a jacket by its coat loop

include <NopSCADlib/utils/sector.scad>;

// Derived from a random plastic coat hanger
rod_diameter = 7;
rack_hook_od = 58;
rack_hook_id = 44;
linear_segment_len = 40;

module rack_hook() {
  rotate_extrude(angle = 180) translate([ rack_hook_id / 2, 0, 0 ])
      circle(d = rod_diameter);

  translate([ -rack_hook_id / 2, 0 ]) sphere(rod_diameter / 2);
}

module linear_segment() {
  rotate([ 90, 0, 0 ]) cylinder(h = linear_segment_len, d = rod_diameter);
}

module bottom_centering_curve() {
  rotate([ 180, 0, 0 ]) rotate_extrude(angle = 90)
      translate([ rack_hook_id / 2, 0 ]) circle(d = rod_diameter);

  translate([ 0, -rack_hook_id / 2 ]) sphere(rod_diameter / 2);
}

module bottom_hook() {
  rotate([ 180, -90, 0 ]) {
    rotate_extrude(angle = 90) translate([ rack_hook_id / 2, 0 ])
        circle(d = rod_diameter);
    translate([ rack_hook_id / 2, 0 ]) sphere(rod_diameter / 2);
  }
}

union() {
  rack_hook();
  translate([ rack_hook_id / 2, 0 ]) linear_segment();
  translate([ 0, -linear_segment_len ]) bottom_centering_curve();
  translate([ 0, -linear_segment_len ]) bottom_hook();
}