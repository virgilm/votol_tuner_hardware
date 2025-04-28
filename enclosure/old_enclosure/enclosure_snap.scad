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

// Which one would you like to see?
part = "both"; // [box:Box only, top: Top cover only, both: Box and top cover]

// Size of your printer's nozzle in mm
nozzle_size = 0.4;

// Number of walls the print should have
number_of_walls = 3; // [1:5]

// Tolerance (use 0.2 for FDM)
tolerance = 0.4; // [0.1:0.1:0.4]

x_interior = 75; // [1:100]
y_interior = 44; // [1:100]
z_interior = 38; // [1:100]

// Outer x dimension in mm
x=x_interior+2*number_of_walls*nozzle_size+2*3*nozzle_size;
echo(x);

// Outer y dimension in mm
y=y_interior+2*number_of_walls*nozzle_size+2*3*nozzle_size;
echo(y);

// Outer z dimension in mm
z=z_interior+2*number_of_walls*nozzle_size+2*3*nozzle_size;
echo(z);

// Radius for rounded corners in mm
radius=4; // [1:20]

/* Hidden */
$fn=100;

wall_thickness=nozzle_size*number_of_walls;
hook_thickness = 3*nozzle_size;
male_connector_height = 10;
connector_edge = 5;

top_cover_wall_thickness = hook_thickness + wall_thickness;

module prism(l, w, h) {
  polyhedron(//pt 0        1        2        3        4        5
          points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
          faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
          );
}

module bottom_box () {
    difference(){
        // Solid box
        linear_extrude(z-wall_thickness){
            minkowski(){
                square([x-radius*2,y-radius*2], center=true);
                circle(radius, center=true);
            }
        }
        
        // Hollow out
        translate([0,0,wall_thickness]) linear_extrude(z){
            minkowski(){
                square([x-radius*2-wall_thickness*2+wall_thickness*2,y-radius*2-wall_thickness*2+wall_thickness*2], center=true);
                circle(radius-wall_thickness);
            }
        }
    }
    left_hook(); // left hook
    rotate([180,180,0]) left_hook(); // right hook
    front_hook(); // front hook
    rotate([180,180,0]) front_hook(); // back hook
    // TODO: hooks on the other two sides
    
           translate([x_interior/2 - male_connector_height,-y_interior/2 +1,(connector_edge/2)+z_interior - connector_edge/2 - 2 * wall_thickness - 1]) cube([male_connector_height,connector_edge,10],true);

           translate([x_interior/2  - (3/2) * male_connector_height,-y_interior/2 + connector_edge/2 +1,(connector_edge/2)+z_interior - male_connector_height - 1 + 0.2]) rotate([0,180,180]) prism(male_connector_height,connector_edge,10);

           translate([x_interior/2 - male_connector_height,y_interior/2 - 1,(connector_edge/2)+z_interior - connector_edge/2 - 2 * wall_thickness - 1]) cube([male_connector_height,connector_edge,10],true);

           translate([x_interior/2  - (1/2) * male_connector_height,y_interior/2 - connector_edge/2 - 1,(connector_edge/2)+z_interior - male_connector_height - 1 + 0.2]) rotate([180,0,180]) prism(male_connector_height,connector_edge,10);

}

module left_hook () {
    
    translate([(x-2*wall_thickness)/2,-y/2+radius*2,z-wall_thickness]) rotate([0,90,90]) {
        difference(){
            linear_extrude(y-2*radius*2){
    polygon(points=[[0,0],[2*hook_thickness,0],[hook_thickness,hook_thickness]], center=true);
        }
             translate([hook_thickness, hook_thickness, 0]) rotate([45,0,0]) cube(2*hook_thickness, center=true);
             translate([hook_thickness, hook_thickness, y-2*radius*2]) rotate([45,0,0]) cube(2*hook_thickness, center=true);        
        }
    }
}

module box_with_holes () {
    connector_height = 11;
    cutout_height = 3.5;
    cutout_length = 7.5;
    notch_height = 3;
    notch_length = 7;
        
    difference() {
        bottom_box();
        // connector hole
       translate([-x_interior/2,0,(connector_height/2)+wall_thickness]) cube([10,y_interior,connector_height],true);
        // notch
       translate([-x_interior/2,0,connector_height+wall_thickness+notch_height/2 - 0.1]) cube([10,notch_length,notch_height],true);
        // right fitting 
       translate([-x_interior/2 + 5,-y_interior/2-wall_thickness*2+1,(connector_height/2)+wall_thickness*2+cutout_height/2]) cube([cutout_length,wall_thickness*2,cutout_height],true);
        // left fitting
       translate([-x_interior/2 + 5,+y_interior/2+wall_thickness*2-1,(connector_height/2)+wall_thickness*2+cutout_height/2]) cube([cutout_length,wall_thickness*2,cutout_height],true);
    }
}

module cover_with_holes () {

    male_connector_len = 44;
    male_connector_height = 10;
    notch_height = 4;
    notch_length = 7;
    screw_hole_radius = 5;

    difference() {
        union() {
            top_cover();
       translate([-x_interior/2 + 22,0,0]) cylinder(9, screw_hole_radius + 3, screw_hole_radius + 3);
        }
        // hole 
       translate([x_interior/2 - male_connector_height,0,(male_connector_len/2)+-z_interior/2 + wall_thickness+1]) cube([male_connector_height,male_connector_len,10],true);
        // notch 2
       translate([x_interior/2 - male_connector_height*3/2 - notch_height/2+0.1,0,0]) cube([notch_height,notch_length, 10],true);
        // extra hole 
       translate([x_interior/2 - male_connector_height,0,2+wall_thickness]) cube([male_connector_height,male_connector_len,10],true);
        // extra hole 
       translate([x_interior/2 - male_connector_height,0,5+wall_thickness]) cube([male_connector_height+2,male_connector_len+3,10],true);
        // screw hole
        
       translate([-x_interior/2 + 22,0,-wall_thickness-1]) cylinder(9, screw_hole_radius, screw_hole_radius);
    }

    
}

module front_hook () {
    translate([(-x+4*radius)/2,-y/2+wall_thickness,z-wall_thickness]) rotate([90,90,90]) {
        difference(){
        linear_extrude(x-2*radius*2){
    polygon(points=[[0,0],[2*hook_thickness,0],[hook_thickness,hook_thickness]], center=true);
    }
             translate([hook_thickness, hook_thickness, 0]) rotate([45,0,0]) cube(2*hook_thickness, center=true);
             translate([hook_thickness, hook_thickness, x-2*radius*2]) rotate([45,0,0]) cube(2*hook_thickness, center=true);
        }
    }
}


module right_grove () {
    translate([-tolerance/2+(x-2*wall_thickness)/2,-y/2+radius,wall_thickness+hook_thickness*2]) rotate([0,90,90]) linear_extrude(y-2*radius){
    polygon(points=[[0,0],[2*hook_thickness,0],[hook_thickness,hook_thickness]], center=true);
    }
}


module front_grove () {
    translate([(-x+2*radius)/2,-y/2+wall_thickness+tolerance/2,wall_thickness+hook_thickness*2]) rotate([90,90,90]) linear_extrude(x-2*radius){
    polygon(points=[[0,0],[2*hook_thickness,0],[hook_thickness,hook_thickness]], center=true);
    }
}

module top_cover () {

    // Top face
    linear_extrude(wall_thickness){
        minkowski(){
            square([x-radius*2,y-radius*2], center=true);
            circle(radius, center=true);
        }
    }
    
    difference(){
        // Wall of top cover
        linear_extrude(wall_thickness+hook_thickness*2){
            minkowski(){
                square([x-radius*2-wall_thickness*2-tolerance+wall_thickness*2,y-radius*2-wall_thickness*2-tolerance+wall_thickness*2], center=true);
                circle(radius-wall_thickness, center=true);
            }
        }
        
        // Hollow out
        // TODO: If radius is very small, still hollow out

        translate([0,0,wall_thickness]) linear_extrude(z){
            minkowski(){
                square([x-radius*2-wall_thickness*2-2*top_cover_wall_thickness-tolerance+wall_thickness*2+top_cover_wall_thickness*2,y-radius*2-wall_thickness*2-2*top_cover_wall_thickness-tolerance+wall_thickness*2+top_cover_wall_thickness*2], center=true);
            circle(radius-wall_thickness-top_cover_wall_thickness);
            }
        }
    right_grove();
    rotate([180,180,0]) right_grove();
    front_grove();
    rotate([180,180,0])  front_grove();
    }
  

}

// left_hook();
print_part();

module print_part() {
	if (part == "box") {
        box_with_holes();
	} else if (part == "top") {
		cover_with_holes();
	} else if (part == "both") {
		both();
	} else {
		both();
	}
}

module both() {
	translate([0,-(y/2+wall_thickness),0]) box_with_holes();
    translate([0,+(y/2+wall_thickness),0]) cover_with_holes();
}