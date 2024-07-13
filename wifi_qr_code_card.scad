// WiFi QR code card generator for use with
// https://www.printables.com/model/155573-wifi-qr-code-sign

include <scadqr/src/qr.scad>

sign_dims = [ 80, 105, 3 ];
qr_dims = [ 65, 65, 4 ];
translate([ 0, 0, sign_dims[2] / 2 ]) cube(sign_dims, center = true);

translate([
  0, sign_dims[1] / 2 - qr_dims[1] / 2 - (sign_dims[0] - qr_dims[0]) / 2, 0
]) color("black") {
  qr("WIFI:T:WPA;S:<ssid>;P:<password>;;", center = true, width = qr_dims[0],
     height = qr_dims[1], thickness = qr_dims[2]);
  translate([ 0, -qr_dims[1] / 2 - 12, 0 ]) linear_extrude(height = qr_dims[2])
      translate([ -12, -12 ]) import("svg/wifi.svg");
}