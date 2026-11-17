src = "../../../Open-Task-Light/Open Task Light/Printed Parts/STL/Rail Ends/";

cap_t = 3.6;
counterbore_d = 9.5;
screw_seat_z = 2.0;
screw_seat_hole_d = 6.2;
bridge_layer_h = 0.2;

key_length = 6;
key_lead_in = 0.5;
key_lead_in_inset = 0.3;

slot_key_profile = [
    [-2.798, 4.0], [2.798, 4.0], [5.4, 6.602], [5.4, 8.1], [3.025, 8.1], [3.025, 8.586], [4.439, 10.0],
    [-4.439, 10.0], [-3.025, 8.586], [-3.025, 8.1], [-5.4, 8.1], [-5.4, 6.602]];

module slot_key()
    union() {
        translate([0, 0, -(key_length - key_lead_in)]) linear_extrude(key_length - key_lead_in) polygon(slot_key_profile);
        translate([0, 0, -key_length]) linear_extrude(key_lead_in + 0.01) offset(delta = -key_lead_in_inset) polygon(slot_key_profile);
    }

module slot_keys() for (angle = [0, 90, 180, 270]) rotate([0, 0, angle]) slot_key();

module stepped_bridge_holes() {
    intersection() {
        translate([0, 0, screw_seat_z - bridge_layer_h]) cylinder(d = counterbore_d, h = bridge_layer_h + 0.01, $fn = 96);
        translate([-counterbore_d / 2, -screw_seat_hole_d / 2, 0]) cube([counterbore_d, screw_seat_hole_d, cap_t]);
    }
    translate([-screw_seat_hole_d / 2, -screw_seat_hole_d / 2, screw_seat_z - 2 * bridge_layer_h])
        cube([screw_seat_hole_d, screw_seat_hole_d, bridge_layer_h + 0.01]);
}

module keyed_cap()
    difference() {
        union() {
            import(str(src, "rail-end-cap_v1.0.stl"), convexity = 10);
            slot_keys();
        }
        stepped_bridge_holes();
    }

module print_orientation() translate([0, 0, cap_t]) rotate([180, 0, 0]) children();

print_orientation() keyed_cap();
