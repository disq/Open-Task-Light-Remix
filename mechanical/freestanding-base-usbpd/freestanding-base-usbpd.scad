part = "shell"; // shell | shell_split | collar | lid | bottom | cover | jack_plate | cable_cap | bracket_cover | assembly

src = "../../../Open-Task-Light/Open Task Light/Printed Parts/STL/Freestanding Base/";
board_stl = "OTL-Base-PD.stl";

$fn = 96;

pocket_angle = -45;
pocket_half_w = 19.5;
barrier_t = 2;

chamber_r_in = 61.91;
pocket_r_out = 85.0;
lid_top_z = 4.2;
pocket_cut_top_z = 21.6;

board_t = 1.6;
usb_body_h = 3.25;
// components face the ceiling, so the USB-C shell, the tallest part, sets the board height
board_z = pocket_cut_top_z - 0.5 - usb_body_h - board_t;
board_face_z = board_z + board_t;
usb_z = board_face_z + usb_body_h / 2;

holes = [[79.5, -15.5], [79.5, 15.5], [63.3, -15.5], [63.3, 15.5]];
boss_d = 5.5;
pilot_d = 1.7;
pilot_depth = 5.6;

usb_hole = [9.8, 4.2];
// keeps the PCB edge out of sight under the socket
usb_hole_floor_z = board_face_z - 0.2;
usb_recess = [12.8, 7.2, 2.5];
usb_recess_r = 85.85;
// the USB-C nose (R85.8) rides up this groove with the board held about 0.55 mm in, then steps out into its hole;
// stopping 0.5 mm short of the plug recess closes the wall under the socket without holding the plug off
usb_channel_r = 85.35;
usb_channel_z0 = 3.6;

shell_top_z = 28.4;
led_pos = [81.6, -7.3];
led_h = 1.1;
led_hole_d = 1.8;
led_hole_sleeve_d = 3.4;
led_hole_z0 = board_face_z + led_h + 0.5;

lid_notch_half_w = 4;
lid_notch_r = 70;

// split print: the shell and the collar both go top face down, and the collar is glued on
collar_out_r = 44;
collar_h = 10;
collar_bore_r = 33.2;
// the bracket plate turns about 0.4 mm under the shell's top wall, so the spigot stops at the wall's underside;
// it only lines the collar up, and the glued face holds it
top_plate_under_z = 27;
spigot_r = 36;
spigot_gap = 0.15;
spigot_chamfer = 0.4;
neck_r = [66.49, 79.49];
lip_top_z = 7;

// bottom shell frame (its z 0 is the desk face), along the pocket centreline
cable_pass = [59, 70.5, 4]; // r from, r to, half width
channel_half_w = 2.45;
cover_r0 = 58.5;
cover_half_w = 7;
cover_depth = 1.5;
cover_gap = 0.15;
cover_tongue_r0 = 50;
cover_tongue_h = 1;
// the slot's top edge is rounded off above this
key_top_z = 4.1;
crush_rib_r = 0.3;
// the front-mount jack's 9.7 mm head can't enter upstream's 8.94 mm neck and would hang only 0.65 mm above its ledge;
// this lets it drop as far as the jack plate's dome can before touching the collar (about 2.4 mm)
jack_head_bore_d = 11.5;
jack_head_bore_z0 = 9.6;

// jack plate print frame: z 0 is the face against the bracket plate, the dome faces the bottom shell
// front-mount jack with a double-D threaded body: in from the dome side, nut from the back
jack_face_z = 8.45;
// the head sits this far up in a recess, which lifts the plug hanging from the jack about 0.7 mm clear of the desk
jack_lift = 1.25;
jack_head_d = 9.7;
jack_head_gap = 0.25;
jack_wall = 3;
jack_body_d = 7.6;
jack_flats = 6.8;
jack_nut_h = 1.7;
jack_nut_af = 10.6;
nut_well_d = 19;
bridge_step = 0.4;
bracket_plate_t = 6.35;
// replaces the upstream 0.6 mm marker line; fits the 2 x 1 mm flat lead
lead_channel = [2.4, 1.2];
cap_d = 11;
cap_head_d = 15;
cap_cavity_d = 9;
cap_end_t = 0.4;
cap_top_gap = 0.3;
cap_socket_gap = 0.15;
// stops short of the jack plate's wall, so the socket pushes on the nut, not on the plate
cap_socket_h = jack_nut_h - 0.2;
molex_plug_thickness = 3.9;

module pocket_frame() rotate([0, 0, pocket_angle]) children();

module annulus(r0, r1, z0, z1)
    translate([0, 0, z0]) difference() {
        cylinder(r = r1, h = z1 - z0, $fn = 360);
        translate([0, 0, -1]) cylinder(r = r0, h = z1 - z0 + 2, $fn = 360);
    }

module pocket_void()
    intersection() {
        // the bottom edge follows the outside 45° chamfer so 2 mm of skin remains
        rotate_extrude($fn = 360) polygon([
            [chamber_r_in, -1], [81.49, -1], [pocket_r_out, pocket_r_out - 82.49],
            [pocket_r_out, pocket_cut_top_z], [chamber_r_in, pocket_cut_top_z]]);
        pocket_frame() translate([0, -pocket_half_w, -2]) cube([100, 2 * pocket_half_w, 30]);
    }

module shot_barriers()
    intersection() {
        annulus(61, 86, lid_top_z, 26);
        pocket_frame() for (s = [-1, 1])
            translate([50, s > 0 ? pocket_half_w : -pocket_half_w - barrier_t, 0]) cube([40, barrier_t, 30]);
    }

module bosses() pocket_frame() for (h = holes)
    translate([h[0], h[1], board_face_z]) cylinder(d = boss_d, h = 26 - board_face_z, $fn = 48);

module pilot_holes() pocket_frame() for (h = holes)
    translate([h[0], h[1], board_z - 1]) cylinder(d = pilot_d, h = pilot_depth + board_t + 1, $fn = 24);

// an open hole from just above D2 to the top face, so the power-good LED shows
module led_hole_sleeve() pocket_frame()
    translate([led_pos[0], led_pos[1], led_hole_z0]) cylinder(d = led_hole_sleeve_d, h = 26 - led_hole_z0, $fn = 32);

module led_hole() pocket_frame()
    translate([led_pos[0], led_pos[1], led_hole_z0 - 1]) cylinder(d = led_hole_d, h = shell_top_z - led_hole_z0 + 2, $fn = 24);

module rounded_x(w, h, r, x0, x1)
    hull() for (y = [-w / 2 + r, w / 2 - r], z = [-h / 2 + r, h / 2 - r])
        translate([x0, y, z]) rotate([0, 90, 0]) cylinder(r = r, h = x1 - x0, $fn = 32);

module usb_cutout() pocket_frame() {
    intersection() {
        translate([0, 0, usb_z]) rounded_x(usb_hole[0], usb_hole[1], usb_hole[1] / 2, 84, usb_recess_r + 0.5);
        translate([80, -10, usb_hole_floor_z]) cube([10, 20, 10]);
    }
    translate([0, 0, usb_z]) rounded_x(usb_recess[0], usb_recess[1], usb_recess[2], usb_recess_r, 90);
    translate([84, -usb_hole[0] / 2, usb_channel_z0]) cube([usb_channel_r - 84, usb_hole[0], usb_z - usb_channel_z0]);
}

module shell()
    difference() {
        union() {
            difference() {
                import(str(src, "freestanding-base-outer-shell_v1.1.stl"), convexity = 10);
                pocket_void();
            }
            shot_barriers();
            bosses();
            led_hole_sleeve();
        }
        pilot_holes();
        usb_cutout();
        led_hole();
    }

// with the shell upside down the neck lips would overhang the chamber by 2.5-3 mm, so slope them at 45°
module lip_fills()
    rotate_extrude($fn = 360) {
        polygon([[61, lip_top_z], [neck_r[0], lip_top_z], [61, lip_top_z + neck_r[0] - 61]]);
        polygon([[neck_r[1], lip_top_z], [85, lip_top_z], [85, lip_top_z + 85 - neck_r[1]]]);
    }

module above_top(lift = 0) translate([0, 0, shell_top_z + lift]) cylinder(r = collar_out_r + 1, h = collar_h + 2);

module shell_split()
    difference() {
        union() {
            shell();
            difference() { lip_fills(); pocket_void(); }
        }
        above_top();
        translate([0, 0, top_plate_under_z - 1]) cylinder(r = spigot_r + spigot_gap, h = shell_top_z - top_plate_under_z + 2, $fn = 360);
        // this edge prints on the bed, where first-layer squish would otherwise close the hole up
        translate([0, 0, shell_top_z - 0.6]) cylinder(r1 = spigot_r + spigot_gap, r2 = spigot_r + spigot_gap + 0.61, h = 0.61, $fn = 360);
    }

spigot_bottom_z = top_plate_under_z + 0.1;

module collar()
    difference() {
        union() {
            intersection() {
                import(str(src, "freestanding-base-outer-shell_v1.1.stl"), convexity = 10);
                // clear of the shell's top face, which would otherwise leave a zero-thickness skin round the collar
                above_top(0.02);
            }
            rotate_extrude($fn = 360) polygon([
                [collar_bore_r - 1, spigot_bottom_z], [spigot_r - spigot_chamfer, spigot_bottom_z],
                [spigot_r, spigot_bottom_z + spigot_chamfer], [spigot_r, shell_top_z + 0.1], [collar_bore_r - 1, shell_top_z + 0.1]]);
        }
        // a touch wider than upstream, so the spigot's fit clearance can't add up to a rub on the bracket cover
        cylinder(r = collar_bore_r, h = 50, $fn = 360);
    }

module top_face_down(top_z) translate([0, 0, top_z]) rotate([180, 0, 0]) children();

// lid print frame <-> shell frame (lid flipped, arc centre at x = 41.25 in its STL)
module lid_to_shell() translate([41.25, 0, lid_top_z]) rotate([0, 180, 0]) children();

module lid_notch() pocket_frame() hull() {
    translate([55, -lid_notch_half_w, -10]) cube([1, 2 * lid_notch_half_w, 20]);
    translate([lid_notch_r - lid_notch_half_w, 0, -10]) cylinder(r = lid_notch_half_w, h = 20, $fn = 48);
}

module lid()
    difference() {
        import(str(src, "freestanding-base-outer-shell-lid_v1.1.stl"), convexity = 10);
        lid_to_shell() lid_notch();
    }

module along_x(x0, len) translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(len) children();

module rim_envelope() rotate_extrude($fn = 360) polygon([[0, -1], [79.49, -1], [82.49, 2], [82.49, 5], [0, 5]]);

module cable_pass_cut() pocket_frame() {
    hull() for (x = [cable_pass[0] + cable_pass[2], cable_pass[1] - cable_pass[2]])
        translate([x, 0, -1]) cylinder(r = cable_pass[2], h = 6, $fn = 48);
    // the lead bends round this edge on its way up into the pocket
    translate([0, cable_pass[2], 0]) rotate([90, 0, 0]) linear_extrude(2 * cable_pass[2])
        polygon([[61.5, 4], [61.5, 8], [57.5, 4]]);
}

module cover_recess() pocket_frame() along_x(cover_r0, 30) polygon([
    [-cover_half_w, -1], [cover_half_w, -1], [cover_half_w, 0],
    [cover_half_w + cover_depth, cover_depth], [-cover_half_w - cover_depth, cover_depth], [-cover_half_w, 0]]);

// the old slot stays open to the rim so the lead can slide in from the edge; the cover's key closes it afterwards
module bottom()
    difference() {
        import(str(src, "freestanding-base-bottom-shell_v1.1.stl"), convexity = 10);
        cable_pass_cut();
        cover_recess();
        translate([0, 0, jack_head_bore_z0]) cylinder(d = jack_head_bore_d, h = 10);
    }

module cover() {
    w0 = cover_half_w - cover_gap * sqrt(2);
    top = cover_depth - cover_gap;
    kw = channel_half_w - cover_gap;
    pocket_frame() difference() {
        union() {
            intersection() {
                union() {
                    along_x(cover_r0 + cover_gap, 30) polygon([[-w0, 0], [w0, 0], [w0 + top, top], [-w0 - top, top]]);
                    translate([cable_pass[1] + cover_gap, -kw, 0]) cube([20, 2 * kw, key_top_z]);
                    // the only grip that holds the cover in: they crush slightly as the key slides home
                    for (s = [-1, 1]) translate([cable_pass[1] + 2, s * kw, 3]) rotate([0, 90, 0]) cylinder(r = crush_rib_r, h = 20, $fn = 12);
                }
                rim_envelope();
            }
            translate([cover_tongue_r0, -kw, 0]) cube([cover_r0 + cover_gap - cover_tongue_r0 + 0.01, 2 * kw, cover_tongue_h]);
        }
        translate([79.4, -3, -1]) cube([4, 6, 1.6]);
    }
}

module double_d(d, flats, h)
    intersection() {
        cylinder(d = d, h = h, $fn = 64);
        translate([-flats / 2, -d / 2, 0]) cube([flats, d, h]);
    }

jack_seat_z = jack_face_z - jack_lift;
jack_nut_z = jack_seat_z - jack_wall;

module jack_plate()
    difference() {
        union() {
            import(str(src, "freestanding-base-power-jack-plate_v1.0.stl"), convexity = 10);
            translate([0, 0, jack_nut_z - 1]) cylinder(r = 6, h = jack_wall + 1);
        }
        translate([0, 0, -1]) cylinder(d = nut_well_d, h = jack_nut_z + 1);
        // flats across the lead channel, which puts the jack's pins side by side across it, so both wires are the same length
        rotate([0, 0, 90]) {
            // two stepped bridge layers let the double-D hole print over the open well without support
            intersection() {
                translate([-jack_flats / 2, -nut_well_d / 2, jack_nut_z - 0.01]) cube([jack_flats, nut_well_d, bridge_step + 0.01]);
                cylinder(d = nut_well_d, h = 20);
            }
            translate([-jack_flats / 2, -jack_body_d / 2, jack_nut_z]) cube([jack_flats, jack_body_d, 2 * bridge_step]);
            translate([0, 0, jack_nut_z]) double_d(jack_body_d, jack_flats, jack_wall + 1);
        }
        translate([-lead_channel[0] / 2, 0, -1]) cube([lead_channel[0], 20, lead_channel[1] + 1]);
        translate([0, 0, jack_seat_z]) cylinder(d = jack_head_d + 2 * jack_head_gap, h = 10, $fn = 96);
    }

// cap frame: z 0 is the end just short of the rail end, which sits on the bracket plate right above the pins
cap_back_face_z = bracket_plate_t - cap_top_gap;
cap_l = cap_back_face_z + jack_nut_z - jack_nut_h + cap_socket_h;
// the head widens 0.2 mm below the bracket plate, so it can't back far enough off the nut to let go
cap_head_z = cap_back_face_z + 0.2;
cap_slot_w = molex_plug_thickness + 1.6;
cap_slot_top_z = cap_back_face_z + lead_channel[1] + 0.3;
cap_slot_start_y = sqrt(pow(cap_cavity_d / 2, 2) - pow(cap_slot_w / 2, 2)) - 0.1;

// a hex socket on the nut: turning the cap tightens the nut, and the cap stays on it
module cable_cap()
    difference() {
        rotate_extrude($fn = 96) polygon([
            [0, 0], [cap_d / 2, 0], [cap_d / 2, cap_head_z],
            [cap_head_d / 2, cap_head_z + (cap_head_d - cap_d) / 2], [cap_head_d / 2, cap_l], [0, cap_l]]);
        translate([0, 0, cap_end_t]) cylinder(d = cap_cavity_d, h = cap_l);
        translate([0, 0, cap_l - cap_socket_h]) cylinder(d = (jack_nut_af + 2 * cap_socket_gap) / cos(30), h = cap_l, $fn = 6);
        translate([-cap_slot_w / 2, cap_slot_start_y, -1]) cube([cap_slot_w, cap_head_d, cap_slot_top_z + 1]);
    }

// bracket cover frame (upstream STL): z 0 is the open face that sits on the bracket plate
// the L brackets jam in upstream's 9.6 mm channel through the middle, so it's widened; the third, one-sided arm is left as is
bracket_channel_half_w = 5.3;
bracket_channel_end = 31.5;
bracket_channel_h = 6;

module bracket_cover()
    difference() {
        import(str(src, "freestanding-base-bracket-cover_v1.1.stl"), convexity = 10);
        // keeps upstream's 1 mm chamfer along the open edge, which prints on the bed
        along_x(-bracket_channel_end, 2 * bracket_channel_end) polygon([
            [-bracket_channel_half_w - 2, -1], [bracket_channel_half_w + 2, -1], [bracket_channel_half_w, 1],
            [bracket_channel_half_w, bracket_channel_h], [-bracket_channel_half_w, bracket_channel_h], [-bracket_channel_half_w, 1]]);
    }

module board_in_place()
    pocket_frame() rotate([0, 0, -90]) translate([0, 0, board_z]) import(board_stl, convexity = 10);

if (part == "shell") shell();
else if (part == "shell_split") top_face_down(shell_top_z) shell_split();
else if (part == "collar") top_face_down(shell_top_z + collar_h) collar();
else if (part == "lid") lid();
else if (part == "bottom") bottom();
else if (part == "cover") cover();
else if (part == "jack_plate") jack_plate();
else if (part == "cable_cap") cable_cap();
else if (part == "bracket_cover") bracket_cover();
else if (part == "assembly") {
    color("lightgray") shell();
    color("tan") lid_to_shell() lid();
    color("silver") translate([0, 0, -4.7]) bottom();
    color("steelblue") translate([0, 0, -4.7]) cover();
    color("green") board_in_place();
}
