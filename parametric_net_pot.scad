// Net pot generator for Kratky hydroponics in jars

// Dimensions of your jar's lip
jar_index = 0;
jars = [
    [60.06, 66.17], // Mateo's salsa jar
    [60.25, 60.25 + 5], // Classico ATLAS mason jar
    [71.55], [77.5], // Milkadamia jar
    [59.69, 65.32], // Zoup bone broth jar
];

jar_lip_inner_diameter = jars[jar_index][0];
jar_lip_outer_diameter = jars[jar_index][1];

// Choose the height as a percentage of the diameter
net_pot_height_percentage = 0.9;

// A few mm smaller than the jar diameter, otherwise it may have
// too much overhang area
net_pot_lip_diameter = jar_lip_outer_diameter-3;

// How far from the side of the jar at the lip the net pot will be
clearance_from_side_of_jar = 1;
net_pot_thickness = 1;

// How much smaller the net pot becomes at the bottom
shrink = 0.7;

// Controls how many holes the net pot has
num_slit_rows = 4;
slits_per_row = 32;

// There is a little circle in the center at the bottom to ensure build plate adhesion
bottom_center_adhesion_percentage_of_diameter = 0.5;

$fn = max(8*slits_per_row, 210);


// Used to hide ugly intersections in preview
epsilon = $preview ? 0.001 : 0;
net_pot_outer_diameter_top = jar_lip_inner_diameter - 2*clearance_from_side_of_jar;
net_pot_outer_diameter_bottom = net_pot_outer_diameter_top * shrink;
net_pot_inner_diameter_top = net_pot_outer_diameter_top - 2*net_pot_thickness;
net_pot_inner_diameter_bottom = net_pot_outer_diameter_bottom - 2*net_pot_thickness;

net_pot_height = net_pot_outer_diameter_top * net_pot_height_percentage;

module pot_slits() {
    addtl_dividers_above = 2;
    dividers_below = 1;
    bottom_percentage = net_pot_thickness*dividers_below/net_pot_height;
    top_percentage = net_pot_thickness*addtl_dividers_above/net_pot_height;
    increment_percentage = (1 - top_percentage - bottom_percentage)/num_slit_rows;
    for(i = [0:(num_slit_rows-1)]) {
        min_percentage = i*increment_percentage + bottom_percentage;
        max_percentage = min_percentage + increment_percentage - net_pot_thickness/net_pot_height;
        for (j = [1:slits_per_row]) {
            points = [
                for (
                    percentage = [min_percentage, max_percentage], z = net_pot_height * percentage,
                    is_outer = [false, true],
                    actual_d = (shrink + percentage*(1-shrink))*net_pot_outer_diameter_top - (is_outer ? 0 : 1)*2*net_pot_thickness,
                    d = (is_outer ? sqrt(2) : 1) * (shrink + percentage*(1-shrink))*net_pot_outer_diameter_top - (is_outer ? 0 : 1)*2*net_pot_thickness,
                    r = d/2,
                    available_pct = 1 - slits_per_row*net_pot_thickness/(PI*actual_d),
                    offset_pct = 1/slits_per_row,
                    increment_pct = available_pct/slits_per_row,
                    base_pct = (1-available_pct)/slits_per_row/2,
                    angle = [for (k = [0, 1]) 360*(j*offset_pct+k*increment_pct+base_pct)], x = r*cos(angle), y = r*sin(angle)
                ) [x,y,z]
            ];
            // Convex hull
            hull()
            polyhedron(points, [[ each [0:len(points)-1] ]] );
        }
    }
}

module bottom_slits() {
    min_percentage = 0-epsilon;
    max_percentage = net_pot_thickness/net_pot_height+epsilon;

    points = [
        for (
            percentage = [min_percentage, max_percentage], y = net_pot_height * percentage,
            d = [ for (i = [bottom_center_adhesion_percentage_of_diameter,1]) i * ((shrink + percentage*(1-shrink)) * net_pot_outer_diameter_top - 2*net_pot_thickness)], x = d/2
        ) [max(x, net_pot_thickness), y]
    ];
    
    difference() {
        rotate_extrude()
        hull()
        polygon(points);
        angle = 360*(1 - net_pot_thickness/(PI * ((shrink + max_percentage*(1-shrink))*net_pot_outer_diameter_top - 2*net_pot_thickness)))/slits_per_row/2;
        rotate([0,0,angle])
        for (j = [1:slits_per_row]) {
            points = [
                for (
                    percentage = [min_percentage-epsilon, max_percentage+epsilon], z = net_pot_height * percentage,
                    is_outer = [false, true],
                    actual_d = (is_outer ? 1 : bottom_center_adhesion_percentage_of_diameter) * (shrink + percentage*(1-shrink))*net_pot_outer_diameter_top - (is_outer ? 1 : 0)*2*net_pot_thickness,
                    d = (is_outer ? sqrt(2) : bottom_center_adhesion_percentage_of_diameter) * (shrink + percentage*(1-shrink))*net_pot_outer_diameter_top - 2*net_pot_thickness,
                    r = d/2,
                    available_pct = slits_per_row*net_pot_thickness/(PI*actual_d),
                    offset_pct = 1/slits_per_row,
                    increment_pct = available_pct/slits_per_row,
                    base_pct = (1-available_pct)/slits_per_row/2,
                    angle = [for (k = [0,1]) 360*(j*offset_pct+k*increment_pct+base_pct)], x = r*cos(angle), y = r*sin(angle)
                ) [x,y,z]
            ];
            // Convex hull
            hull()
            polyhedron(points, [[ each [0:len(points)-1] ]] );
        }
    }
}

module pot() {
    union() {
        difference() {
            cylinder(d1=net_pot_outer_diameter_bottom, d2=net_pot_outer_diameter_top, h=net_pot_height);
            translate([0,0,-epsilon])
            cylinder(d1=net_pot_inner_diameter_bottom, d2=net_pot_inner_diameter_top, h=net_pot_height+2*epsilon);
            pot_slits();
        }
        difference() {
            cylinder(d1=net_pot_outer_diameter_bottom, d2=net_pot_outer_diameter_top * (shrink + (1-shrink)*net_pot_thickness/net_pot_height), h=net_pot_thickness+epsilon);
            bottom_slits();
        }
    }
}

module lip() {
    difference() {
        cylinder(d1=net_pot_outer_diameter_top, d2=net_pot_lip_diameter, h=net_pot_thickness, center=false);
        translate([0,0,-epsilon])
        cylinder(d1=net_pot_inner_diameter_top, d2=net_pot_outer_diameter_top, h=net_pot_thickness+2*epsilon, center=false);
    }
}

if ($preview) {
    color("silver") {
        pot();
        translate([0,0,net_pot_height-net_pot_thickness]) lip();
    }
    // "Soil"
    color("saddlebrown")
    translate([0,0,net_pot_thickness])
    cylinder(d1=net_pot_inner_diameter_bottom, d2=0.9*net_pot_inner_diameter_top, h=0.9*net_pot_height);
    // "Plants"
    color("limegreen") {
        radii = rands(2, net_pot_inner_diameter_bottom/2, 10, seed_value=789);
        angles = rands(0, 360, 10, seed_value=123);
        for(i = [0:9]) {
            translate([radii[i]*cos(angles[i]), radii[i]*sin(angles[i])])
            cylinder(d1=2, d2=0.5, h=1.5*net_pot_height);
        }
    }
    // Jar
    color("SlateGray", alpha = 0.3) {
        difference() {
            cylinder(d = jar_lip_outer_diameter+5, h = net_pot_height-2, center=false);
            translate([0,0,0-epsilon])
            cylinder(d = jar_lip_outer_diameter, h = net_pot_height-2+2*epsilon, center=false);
        }
    }
} else {
    pot();
    translate([0,0,net_pot_height-net_pot_thickness]) lip();
}