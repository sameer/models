// Midea Duo drain pipe adapter for using an icemaker tube (5/16" OD 3/16" ID)
//
// This is modeled off of the OEM adapter which requires a slightly larger tube
include <NopSCADlib/utils/tube.scad>;

$fn = 100;

in_to_mm = 25.4;
epsilon = $preview ? 0.01 : 0;

// Measurements taken from the original adapter
midea_hose_adapter_od = 14.77 + 0.25;
midea_hose_adapter_taper_od = 13.4;
midea_hose_adapter_id = 10.4;
midea_hose_adapter_len = 24;

adapter_separator_length = 3;
adapter_separator_diameter = midea_hose_adapter_od + 3;

icemaker_hose_od = 5 / 16 * in_to_mm;
icemaker_hose_id = 3 / 16 * in_to_mm;

icemaker_hose_adapter_length = 11.76;
icemaker_hose_adapter_thickness = 1.5;
icemaker_hose_adapter_base_diameter = icemaker_hose_id + 0.8;
icemaker_hose_adapter_tip_diameter = icemaker_hose_id - 0.2;

module adapter() {
  difference() {
    union() {
      // Fillet
      cylinder(d = adapter_separator_diameter, h = adapter_separator_length);

      // Icemaker side

      translate([ 0, 0, adapter_separator_length ]) {
          cylinder(d1 = icemaker_hose_adapter_base_diameter,
                   d2 = icemaker_hose_id,
                   h = icemaker_hose_adapter_length * 3/4);
          translate([0,0, icemaker_hose_adapter_length * 3/4])
          cylinder(d1 = icemaker_hose_id,
                   d2 = icemaker_hose_adapter_tip_diameter,
                   h = icemaker_hose_adapter_length * 1/4);
      }

      // Midea side
      rotate([ 180, 0 ]) {
          cylinder(d1 = midea_hose_adapter_od, d2 = (midea_hose_adapter_od - midea_hose_adapter_taper_od) * 3/4 + midea_hose_adapter_taper_od,
                   h = midea_hose_adapter_len * 3/4);
          translate([0,0,midea_hose_adapter_len * 3/4])
          cylinder(d1 = (midea_hose_adapter_od - midea_hose_adapter_taper_od) * 3/4 + midea_hose_adapter_taper_od, d2 = midea_hose_adapter_taper_od,
                   h = midea_hose_adapter_len * 1/4);
      }
    }

    // Cut the icemaker side hole
    translate([ 0, 0, -epsilon ])
        cylinder(d1 = icemaker_hose_adapter_base_diameter -
                      icemaker_hose_adapter_thickness,
                 d2 = icemaker_hose_adapter_tip_diameter -
                      icemaker_hose_adapter_thickness,
                 h = adapter_separator_length + icemaker_hose_adapter_length +
                     2 * epsilon);

    // Cut the midea side hole
    translate([ 0, 0, epsilon ]) rotate([ 180, 0 ]) cylinder(
        d = midea_hose_adapter_id, h = midea_hose_adapter_len + 2 * epsilon);
  }
}

if ($preview) {
  adapter();

  translate([ 0, 0, 10 ]) color("silver", alpha = 0.3)
      tube(or = icemaker_hose_od / 2, ir = icemaker_hose_id / 2, center = false,
           h = 50);

  rotate([ 180, 0 ]) translate([ 0, 0, 10 ]) color("silver", alpha = 0.3)
      tube(or = midea_hose_adapter_od / 2 + 1, ir = midea_hose_adapter_od / 2,
           center = false, h = 50);
} else {
  adapter();
}