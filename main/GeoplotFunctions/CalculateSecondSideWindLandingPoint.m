function [lat_second_side, long_second_side] = CalculateSecondSideWindLandingPoint(lat_launchpad, ...
        long_launchpad, lat_frontwind_LP, long_frontwind_LP, lat_sidewind_LP, long_sidewind_LP)
lat_launchpad = lat_launchpad*pi/180;
long_launchpad = long_launchpad*pi/180;

r_launchpad = lla2ecef([lat_launchpad*180/pi, long_launchpad*180/pi, 0])';
C_ecef2ned = [-sin(lat_launchpad)*cos(long_launchpad),-sin(long_launchpad),-cos(lat_launchpad)*cos(long_launchpad);
    -sin(lat_launchpad)*sin(long_launchpad),cos(long_launchpad),-cos(lat_launchpad)*sin(long_launchpad);
    cos(lat_launchpad),0,-sin(long_launchpad)]'; % <- transpose!!
C_ned2ecef = [-sin(lat_launchpad)*cos(long_launchpad),-sin(long_launchpad),-cos(lat_launchpad)*cos(long_launchpad);
    -sin(lat_launchpad)*sin(long_launchpad),cos(long_launchpad),-cos(lat_launchpad)*sin(long_launchpad);
    cos(lat_launchpad),0,-sin(long_launchpad)];
r_front = lla2ecef([lat_frontwind_LP*180/pi, long_frontwind_LP*180/pi, 0])';
ned_front = C_ecef2ned*(r_front-r_launchpad);
r_side = lla2ecef([lat_sidewind_LP*180/pi, long_sidewind_LP*180/pi, 0])';
ned_side = C_ecef2ned*(r_side-r_launchpad);

angle_n_front = atan2(ned_front(2),ned_front(1));
angle_n_side = atan2(ned_side(2),ned_side(1));
angle_n_second_side = angle_n_front+(angle_n_front-angle_n_side);
distance_side = sqrt((ned_side(2))^2+(ned_side(1))^2);
ned_second_side = [distance_side*cos(angle_n_second_side),distance_side*sin(angle_n_second_side),0]';
r_second_side = C_ned2ecef*ned_second_side + r_launchpad;
lla_second_side = ecef2lla(r_second_side');

lat_second_side = lla_second_side(1)*pi/180;
long_second_side = lla_second_side(2)*pi/180;
end