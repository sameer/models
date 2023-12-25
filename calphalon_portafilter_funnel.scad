// Portafilter funnel for the Calphalon Compact Espresso Machine. Makes it a little easier to pour grounds in without making a mess.
//
// https://www.calphalon.com/kitchen-appliances/appliances-by-product-type/coffee-makers/compact-espresso-machine-home-espresso-machine-with-milk-frother-stainless-steel/SAP_2170554.html

include <NopSCADlib/utils/tube.scad>;

$fn = 500;
epsilon = $preview ? 0.001 : 0;

ridge_od = 56.46;
ridge_width = 1.82;
ridge_id = ridge_od - ridge_width;
ridge_height = 1.3;

rim_od = 59.5;
rim_height = 0.6;

// Guesstimate
basket_height = 15;

funnel_height = 20;
funnel_expansion_factor = 1.75;
// Save filament by thinning out the top of the funnel
funnel_top_thinning_factor = 0.96;

module lip() {
  union() {
    tube(or = ridge_od / 2, ir = ridge_id / 2, h = ridge_height,
         center = false);
    tube(or = rim_od / 2, ir = ridge_id / 2, h = rim_height, center = false);
  }
}

module funnel() {
  difference() {
    cylinder(h = funnel_height, d1 = (rim_od + ridge_od) / 2,
             d2 = funnel_expansion_factor * (rim_od + ridge_od) / 2 *
                  funnel_top_thinning_factor);
    translate([ 0, 0, -epsilon + ridge_height ])
        cylinder(h = funnel_height - ridge_height + 2 * epsilon, d1 = ridge_id,
                 d2 = funnel_expansion_factor * ridge_id);

    // Cut out the ridge line
    translate([ 0, 0, -rim_height + epsilon ]) lip();

    // Cut a hole through the center
    translate([ 0, 0, -epsilon ])
        cylinder(d = ridge_id + epsilon, h = funnel_height + 2 * epsilon);
  }
}

module basket() {
  rotate([ 180, 0, 0 ]) difference() {
    cylinder(h = basket_height, d = ridge_od);
    translate([ 0, 0, -epsilon ])
        cylinder(h = basket_height - rim_height + epsilon, d = ridge_id);
  }
}

if ($preview) {
  color("silver", alpha = 0.5) lip();
  color("gray", alpha = 0.5) basket();
  translate([ 0, 0, 5 ]) funnel();
} else {
  funnel();
}