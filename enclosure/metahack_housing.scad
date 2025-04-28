//
// Votol Tuner Hardware Module
// (c) 2025 Virgil Mihailovici
//
// Licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
//
// You may share and adapt this file for non-commercial purposes,
// as long as you credit the author and license your new creations under the same terms.
// Full license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// If you find this project useful, you can support it here:
// https://www.buymeacoffee.com/metahack
//

create_whole                = false;
print_bottom                = true;
print_top                   = true;

$fn = 50;

tolerance                   =  0.2;

pcb_length                  = 93.0;
pcb_width                   = 29.5;

pcb_board_height            =  1.5;
pcb_bottomcomponents_height =  2;
pcb_topcomponents_height    =  4.5;
pcb_height                  =  pcb_board_height + pcb_topcomponents_height + pcb_bottomcomponents_height;
pcb_support_width           =  0;

usb_width                   = 11.9;
usb_height                  =  4.4;
usb_length                  = 15.0;
usb_plug_length             = 12.0;

micro_usb_width             = 8;
micro_usb_height            = 3;
micro_usb_length            = 10.0;

wall_thickness              =  2.0;
corner_radius               = wall_thickness;
lip_thickness               =  0.8;
lip_height                  =  1.0;

pins_diameter               = 2.9;
eps_pins_diameter           = 2.8;
esp_board_len               = 46.7;
esp_board_width             = 28.5;
esp_board_led_1_offset      = 10;
esp_board_led_2_offset      = 10;

dovel_radius_min            = 1;
dovel_radius_delta          = 0.1;
mount_radius_ext            = 2.5;

space_dimensions            = [ pcb_length + tolerance,
                                pcb_width  + tolerance,
                                pcb_height + tolerance];

space_dimensions_usb        = [ usb_length + tolerance,
                                usb_width  + tolerance,
                                usb_height + tolerance];

space_dimensions_micro_usb  = [ micro_usb_length + tolerance,
                                micro_usb_width  + tolerance,
                                micro_usb_height + tolerance];

outer_dimensions            = [ space_dimensions[0]+2*corner_radius,
                                space_dimensions[1]+2*corner_radius,
                                space_dimensions[2]+2*corner_radius,];


module logo() {
    linear_extrude(3)
    text( "MetaHack", font= "Futura", size= 7, halign = "center", valign = "center");
}

module rounded_cube(d,r) {
   minkowski() {
    cube(d);
    sphere(r=r);
   }
}


module pin_usb(r, h) {
    cylinder(h, r, r, false);
}

module pin(r, h) {
    cylinder(h, r, r-0.3, false);
}

module dowel() {
    cylinder(pcb_bottomcomponents_height + pcb_board_height + pcb_topcomponents_height - 0.2, dovel_radius_min+ dovel_radius_delta, dovel_radius_min - dovel_radius_delta, false);
}

module mount() {
    translate([0,0, pcb_topcomponents_height])
    difference() {
        cylinder(pcb_topcomponents_height, mount_radius_ext , mount_radius_ext, false);
        translate([0, 0, - 0.01])        cylinder(pcb_topcomponents_height + 0.01, dovel_radius_min + dovel_radius_delta + tolerance/2, dovel_radius_min + dovel_radius_delta, false);
    }
}

module usb_hole_orig() {
    translate([  0.01-space_dimensions_usb[0],
                 (space_dimensions[1]-space_dimensions_usb[1])/2,
                 pcb_bottomcomponents_height+pcb_board_height+(tolerance/2)
              ]) cube(space_dimensions_usb);
}

module usb_hole() {
    translate([  0.01-space_dimensions_usb[0],
                 (space_dimensions[1]-space_dimensions_usb[1])/2,
                 pcb_board_height+(tolerance/2)
              ]) cube(space_dimensions_usb);
}

module micro_usb_hole() {
    translate([  5-space_dimensions_micro_usb[0] + pcb_length,
                 (space_dimensions[1]-space_dimensions_micro_usb[1])/2,
                 pcb_bottomcomponents_height + 3 * tolerance
              ]) cube(space_dimensions_micro_usb);
}

module led_hole() {
    translate([  71, 0,
                 pcb_board_height+(tolerance/2)
              ]) cylinder(10, 1, true);
}

module housing() {
    difference() {
        union() {
            difference() {
                rounded_cube(space_dimensions, corner_radius);
                cube(space_dimensions);
            }
            cube([space_dimensions[0], pcb_support_width, pcb_bottomcomponents_height]);
            translate([0, space_dimensions[1]-pcb_support_width, 0])
            cube([space_dimensions[0], pcb_support_width, pcb_bottomcomponents_height]);
        }
        usb_hole();
        micro_usb_hole();
        translate([0, esp_board_led_1_offset, 0]) led_hole();
        translate([0, space_dimensions[1] - esp_board_led_2_offset,0]) led_hole();
    }
}

module lip(oversize) {
    difference() {
        translate([0, 0, pcb_bottomcomponents_height+pcb_board_height]) difference() {
            translate([-lip_thickness-(oversize/2), -lip_thickness-(oversize/2), 0])
            cube( [ space_dimensions[0]+2*lip_thickness+oversize,
                    space_dimensions[1]+2*lip_thickness+oversize, lip_height+oversize] );
            translate([(oversize/2), (oversize/2), -0.01]) cube([space_dimensions[0]-oversize, space_dimensions[1]-oversize, space_dimensions[2]]);
        }
        usb_hole();
        micro_usb_hole();
    }
}

if(create_whole) housing();

// bottom part
if((!create_whole) && (print_bottom)) translate([0, create_whole?outer_dimensions[1]:corner_radius + 5, 0]) {
    intersection() {
        housing();
        translate([-corner_radius, -corner_radius, -corner_radius])
            cube([outer_dimensions[0], outer_dimensions[1], corner_radius+pcb_bottomcomponents_height+pcb_board_height+tolerance]);
    }
    lip(0.0);
    
    // usb plug pins
    pin_heigth = pcb_bottomcomponents_height + pcb_board_height + pcb_topcomponents_height - 2;
    radius = pins_diameter/2;
    translate([ 9.5, pcb_width/2 - 4.85 ,0])    pin_usb(radius, pin_heigth);
    translate([ 9.5, pcb_width/2 + 4.85 ,0])    pin_usb(radius, pin_heigth);
    // esp32 pins
    esp_radius = eps_pins_diameter/2;
    translate([ pcb_length - 2.5, pcb_width/2 - esp_board_width/2 + 2.5 ,0]) pin(esp_radius, pin_heigth);
    translate([ pcb_length - 2.5, pcb_width/2 + esp_board_width/2 - 2.5 ,0]) pin(esp_radius, pin_heigth);
    translate([ pcb_length - 2.5 - esp_board_len, pcb_width/2 - esp_board_width/2 + 2.5 ,0]) pin(esp_radius, pin_heigth);
    translate([ pcb_length - 2.5 - esp_board_len, pcb_width/2 + esp_board_width/2 - 2.5 ,0]) pin(esp_radius, pin_heigth);
    
    // dowels
    translate([4, 4, 0]) dowel();
    translate([4, pcb_width - 4, 0]) dowel();
    translate([35, 4, 0]) dowel();
    translate([35, pcb_width - 4, 0]) dowel();
}

// top part
if((!create_whole) && (print_top)) translate([0, -2*corner_radius-5, space_dimensions[2]]) rotate([180, 0, 0]) {
    difference() {
        union() {
            difference() {
                intersection() {
                    housing();
                    translate([-corner_radius, -corner_radius, pcb_bottomcomponents_height+pcb_board_height+tolerance])
                        cube([outer_dimensions[0], outer_dimensions[1], pcb_topcomponents_height+corner_radius]);
                }
                translate([0, 0, 0.01]) lip(tolerance);
            }
            translate([4, 4, 0]) mount();
            translate([4, pcb_width - 4, 0]) mount();
            translate([35, 4, 0]) mount();
            translate([35, pcb_width - 4, 0]) mount();
        }
       translate([pcb_length/2, pcb_width/2, pcb_bottomcomponents_height + pcb_board_height + 6])logo();
    }
}
