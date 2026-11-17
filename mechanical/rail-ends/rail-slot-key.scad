function slot_key_profile() = [
    [-2.798, 4.0], [2.798, 4.0], [5.4, 6.602], [5.4, 8.1], [3.025, 8.1], [3.025, 8.586], [4.439, 10.0],
    [-4.439, 10.0], [-3.025, 8.586], [-3.025, 8.1], [-5.4, 8.1], [-5.4, 6.602]];

module slot_key(length, lead_in = 0.5, lead_in_inset = 0.3)
    union() {
        translate([0, 0, -(length - lead_in)]) linear_extrude(length - lead_in) polygon(slot_key_profile());
        translate([0, 0, -length]) linear_extrude(lead_in + 0.01) offset(delta = -lead_in_inset) polygon(slot_key_profile());
    }
