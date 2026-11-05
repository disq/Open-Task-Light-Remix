src = "/Users/disq/Downloads/Open-Task-Light/Open Task Light/Printed Parts/STL/Electronics Housing/";

// the kit buttons are 14.46 square and 34.2-34.4 round, and upstream's pockets print about 0.15 mm under their drawn size;
// these print about 0.15 mm over the buttons, enough to press them in by hand
square_pocket = 14.75;
round_pocket_d = 34.65;

upstream_square_pocket = 14.2;
upstream_square_pocket_r = 2.05;
square_centres = [-33.25, -12.25];
round_centre = 22.75;
ledge_z = 1.6;

difference() {
    import(str(src, "electronics-housing-button-sockets_v1.0.stl"), convexity = 10);
    translate([0, 0, ledge_z]) linear_extrude(10) {
        for (x = square_centres)
            translate([x, 0])
                offset(r = upstream_square_pocket_r + (square_pocket - upstream_square_pocket) / 2)
                    square(upstream_square_pocket - 2 * upstream_square_pocket_r, center = true);
        translate([round_centre, 0]) circle(d = round_pocket_d, $fn = 360);
    }
}
