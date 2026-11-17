use <rail-slot-key.scad>

src = "../../../Open-Task-Light/Open Task Light/Printed Parts/STL/Rail Ends/";

cap_t = 3.6;
counterbore_d = 9.5;
screw_seat_z = 2.0;
screw_seat_hole_d = 6.2;
bridge_layer_h = 0.2;
key_length = 6;
power_track_slot_angle = 270;

module slot_keys()
    for (angle = [0, 90, 180, 270]) if (angle != power_track_slot_angle) rotate([0, 0, angle]) slot_key(key_length);

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
