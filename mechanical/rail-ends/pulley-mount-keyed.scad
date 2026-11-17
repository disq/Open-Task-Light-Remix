use <rail-slot-key.scad>

src = "../../../Open-Task-Light/Open Task Light/Printed Parts/STL/Rail Ends/";

key_length = 6;
insert_pocket_depth = 3.5;
insert_pocket_profile = [[-2.839, 3.9], [-5.5, 6.561], [-5.5, 8.2], [5.5, 8.2], [5.5, 6.561], [2.839, 3.9]];

module filled_insert_pocket()
    translate([0, 0, -0.01]) linear_extrude(insert_pocket_depth + 0.03) offset(delta = 0.02) polygon(insert_pocket_profile);

module slot_keys() for (angle = [0, 180]) rotate([0, 0, angle]) slot_key(key_length);

module keyed_pulley_mount()
    union() {
        import(str(src, "pulley-mount_v1.0.stl"), convexity = 10);
        filled_insert_pocket();
        slot_keys();
    }

module print_orientation() translate([0, 0, key_length]) children();

print_orientation() keyed_pulley_mount();
