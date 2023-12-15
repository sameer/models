// Adapter for connecting a Midea Duo Air Conditioner to an apartment single
// hose AC port
//
// https://www.costco.com/midea-duo-smart-12k-btu-doesacc-4-in-1-inverter-portable-air-conditioner.product.100978219.html
//
// I do not recommend printing this in PLA. The exhaust air gets quite hot and
// melted my PLA print a little

include <NopSCADlib/utils/sector.scad>

$fn = 300;

in_to_mm = 25.4;
epsilon = $preview ? 0.1 : 0;

midea_od = 5.987 * in_to_mm;
midea_len = 0.495 * in_to_mm;
midea_thickness = 0.1 * in_to_mm;
midea_tab_width = 0.535 * in_to_mm;
midea_tab_angle = 360 * midea_tab_width / (PI * midea_od);
midea_tab_bump_height = 0.455 * in_to_mm - midea_thickness;
midea_tab_base_height = 0.316 * in_to_mm - midea_thickness;
midea_tab_deflection_height = 0.42 * in_to_mm - midea_thickness;
midea_tab_overall_len = 0.852 * in_to_mm;
midea_tab_bump_len = 0.083 * in_to_mm;
midea_tab_bump_dist = 0.232 * in_to_mm;

tube_od = 4.5 * in_to_mm;
tube_len = 3 * in_to_mm;
tube_thickness = 4;

adapter_thickness = 1;
adapter_od = tube_od + 1;
adapter_length = 10;

cone_length = 30;

bracket_od = midea_od + 1;
bracket_thickness = 2;
bracket_length = midea_len;
bracket_tab_angle = 360 * midea_tab_width / (PI * midea_od) + 1;
bracket_tab_thickness_angle = 2;

// Adapter
module wall_adapter() {
  linear_extrude(adapter_length) difference() {
    circle(d = adapter_od + 2 * adapter_thickness);
    circle(d = adapter_od);
  }
  if ($preview) {
    translate([ 0, 0, -tube_len + adapter_length ]) color("white")
        linear_extrude(tube_len) difference() {
      circle(d = tube_od);
      circle(d = tube_od - 2 * tube_thickness);
    }
  }
}

module cone() {
  difference() {
    cylinder(d1 = adapter_od + 2 * adapter_thickness,
             d2 = bracket_od + 2 * bracket_thickness, h = cone_length);
    translate([ 0, 0, -epsilon ]) cylinder(d1 = adapter_od, d2 = bracket_od,
                                           h = cone_length + 2 * epsilon);
  }
}

module bracket() {
  union() {
    linear_extrude(bracket_length) {
      union() {
        difference() {
          circle(d = bracket_od + 2 * bracket_thickness);
          circle(d = bracket_od);
          for (i = [0:2]) {
            sector(r = bracket_od,
                   start_angle = i * 360 / 3 - bracket_tab_angle / 2,
                   end_angle = i * 360 / 3 + bracket_tab_angle / 2);
          }
        }
      }
    }
    translate([ 0, 0, midea_len - midea_tab_bump_dist + 2 ])
        linear_extrude(midea_tab_bump_dist - 2) {
      for (i = [0:2]) {
        difference() {
          sector(r = midea_od / 2 + midea_tab_deflection_height + 4,
                 start_angle = i * 360 / 3 - bracket_tab_angle / 2,
                 end_angle = i * 360 / 3 + bracket_tab_angle / 2);
          sector(r = midea_od / 2 + midea_tab_deflection_height,
                 start_angle = i * 360 / 3 - bracket_tab_angle / 2 - 1,
                 end_angle = i * 360 / 3 + bracket_tab_angle / 2 + 1);
        }
      }
    }
    translate([ 0, 0, midea_len - midea_tab_bump_dist + 2 ])
        linear_extrude(midea_tab_bump_dist - 2) {
      for (v = [ [ 0, 1, -1 ], [ 1, 0, 1 ] ]) {
        for (i = [0:2]) {
          difference() {
            sector(r = bracket_od / 2 + midea_tab_deflection_height + 4 -
                       (bracket_od - midea_od) / 2,
                   start_angle = i * 360 / 3 - v[2] * bracket_tab_angle / 2 -
                                 v[0] * bracket_tab_thickness_angle,
                   end_angle = i * 360 / 3 - v[2] * bracket_tab_angle / 2 +
                               v[1] * bracket_tab_thickness_angle);
            sector(r = bracket_od / 2 + bracket_thickness,
                   start_angle = i * 360 / 3 - v[2] * bracket_tab_angle / 2 -
                                 v[0] * bracket_tab_thickness_angle - 1,
                   end_angle = i * 360 / 3 - v[2] * bracket_tab_angle / 2 +
                               v[1] * bracket_tab_thickness_angle + 1);
          }
        }
      }
    }
  }
  if ($preview) {
    color("white") union() {
      linear_extrude(100) {
        difference() {
          circle(d = midea_od);
          circle(d = midea_od - 2 * midea_thickness);
        }
      }
      linear_extrude(midea_len) {
        for (i = [0:2]) {
          difference() {
            sector(r = midea_od / 2 + midea_tab_base_height,
                   start_angle = i * 360 / 3 - midea_tab_angle / 2,
                   end_angle = i * 360 / 3 + midea_tab_angle / 2);
            sector(r = midea_od / 2,
                   start_angle = i * 360 / 3 - midea_tab_angle / 2 - 1,
                   end_angle = i * 360 / 3 + midea_tab_angle / 2 + 1);
          }
        }
      }
      linear_extrude(midea_len) {
        for (i = [0:2]) {
          difference() {
            sector(r = midea_od / 2 + midea_tab_base_height,
                   start_angle = i * 360 / 3 - midea_tab_angle / 2,
                   end_angle = i * 360 / 3 + midea_tab_angle / 2);
            sector(r = midea_od / 2,
                   start_angle = i * 360 / 3 - midea_tab_angle / 2 - 1,
                   end_angle = i * 360 / 3 + midea_tab_angle / 2 + 1);
          }
        }
      }
      translate([ 0, 0, midea_tab_bump_dist ])
          linear_extrude(midea_tab_bump_len) {
        for (i = [0:2]) {
          difference() {
            sector(r = midea_od / 2 + midea_tab_bump_height,
                   start_angle = i * 360 / 3 - midea_tab_angle / 2,
                   end_angle = i * 360 / 3 + midea_tab_angle / 2 - 1);
            sector(r = midea_od / 2,
                   start_angle = i * 360 / 3 - midea_tab_angle / 2,
                   end_angle = i * 360 / 3 + midea_tab_angle / 2 + 1);
          }
        }
      }
    }
  }
}

deg = $preview ? 90 : 0;

rotate([ 0, deg, 0 ]) {
  union() {
    wall_adapter();
    translate([ 0, 0, adapter_length ]) {
      cone();
      translate([ 0, 0, cone_length ]) { bracket(); }
    }
  }
}
// bracket();