// Replacement for the upstream counterweight-lid-lead_v1.0, same frame: inner face on z = 0, tongue towards +y.

$fn = 64;

width = 11.7;
corner_r = 2.0;
thickness = 2.8;
screw_end_y = -12.8;
top_end_y = 11.6;

// the slot behind the lip is 1.5 deep; a thinner tongue lets the lid tilt in past the lip
tongue_w = 7.6;
tongue_t = 1.0;
tongue_tip_y = 13.2;
tongue_tip_chamfer = 0.5;

top_chamfer = 0.6;
screw_end_chamfer = 1.5;
foot_chamfer = 0.3;

hole_y = -9.2;
hole_d = 2.2;
csk_d = 4.1;
csk_z0 = 1.46;
csk_z1 = 2.5;

module plan(inset = 0)
    offset(r = corner_r - inset) offset(delta = -corner_r)
        translate([-width / 2, screw_end_y]) square([width, top_end_y - screw_end_y]);

module chamfer_cut(y0, z0, dy, dz)
    translate([-width, 0, 0]) rotate([90, 0, 90]) linear_extrude(2 * width)
        polygon([[y0, z0], [y0 + dy, z0], [y0, z0 + dz]]);

module body() difference() {
    hull() {
        linear_extrude(0.01) plan(foot_chamfer);
        translate([0, 0, foot_chamfer]) linear_extrude(thickness - foot_chamfer) plan();
    }
    chamfer_cut(top_end_y + 0.01, thickness + 0.01, -top_chamfer - 0.01, -top_chamfer - 0.01);
    chamfer_cut(screw_end_y - 0.01, -0.01, screw_end_chamfer + 0.01, screw_end_chamfer + 0.01);
}

module tongue() difference() {
    translate([-tongue_w / 2, top_end_y - 1, 0]) cube([tongue_w, tongue_tip_y - top_end_y + 1, tongue_t]);
    chamfer_cut(tongue_tip_y + 0.01, tongue_t + 0.01, -tongue_tip_chamfer - 0.01, -tongue_tip_chamfer - 0.01);
    chamfer_cut(tongue_tip_y + 0.01, -0.01, -foot_chamfer - 0.01, foot_chamfer + 0.01);
}

difference() {
    union() {
        body();
        tongue();
    }
    translate([0, hole_y, -1]) cylinder(d = hole_d, h = thickness + 2);
    translate([0, hole_y, csk_z0]) cylinder(d1 = hole_d, d2 = csk_d, h = csk_z1 - csk_z0);
    translate([0, hole_y, csk_z1]) cylinder(d = csk_d, h = 1);
}
