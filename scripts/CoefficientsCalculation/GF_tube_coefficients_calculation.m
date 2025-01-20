clear all; clc;
%% data
% 1) run post-processing script
run('C:\Users\Michal\Documents\GitHub\symulacja-lotu\ComputationalTools\Dispersion_analysis\Grot Dispersion\DispersionAnalysis_Grot3_tube_Drawsko_Pomorskie.m');
% plot from this script is demanded to add on it landing points from 3)

% 2) get coordinates of the biggest ellipse
% done in past (by saving data with usage of breakpoints in GetEllipses.m   % or DrawDispersionEllipses.m?
% function in Functions folder for post-processing script), saved as .mat
% file
load('GF_tube_ellipsecoo.mat');

% 3) get coordinates of rocket's flights' landing point (the furthest ones)
% and apogees (the highest ones) with specific wind profiles and add them
% on plot they have to be rewritten here
coord_front = [53.427244*pi/180, 15.796410*pi/180];
coord_back = [53.414379*pi/180, 15.771026*pi/180];
coord_side = [53.428670*pi/180, 15.774324*pi/180];
coord_no_wind = [53.421431*pi/180, 15.784655*pi/180];
apogee_front = 10098.094201;
apogee_back = 10219.226823;
apogee_side = 10157.077817;
apogee_no_wind = 10212.902922;

% adding folder with needed function to path
current_file_name = mfilename('fullpath');
[path_string, ~, ~] = fileparts(current_file_name);
addpath(fullfile(path_string, '..\..\main\GeoplotFunctions'));
[coord_side_2(1), coord_side_2(2)] = CalculateSecondSideWindLandingPoint(lat*180/pi, long*180/pi, ...
    coord_front(1), coord_front(2), coord_side(1), coord_side(2));

% plot RFS simulations points
geoscatter(coord_no_wind(1)*180/pi, coord_no_wind(2)*180/pi, "MarkerEdgeColor", "k", "Marker", "diamond", "DisplayName", "RFS stage3 no wind",'linewidth',3);
geoscatter(coord_front(1)*180/pi, coord_front(2)*180/pi, "MarkerEdgeColor", "k", "Marker", "v", "DisplayName", "RFS stage3 front wind",'linewidth',3);
geoscatter(coord_back(1)*180/pi, coord_back(2)*180/pi, "MarkerEdgeColor", "k", "Marker", "^", "DisplayName", "RFS stage3 back wind",'linewidth',3);
geoscatter(coord_side(1)*180/pi, coord_side(2)*180/pi, "MarkerEdgeColor", "k", "Marker", ">", "DisplayName", "RFS stage3 side wind",'linewidth',3);
geoscatter(coord_side_2(1)*180/pi, coord_side_2(2)*180/pi, "MarkerEdgeColor", "k", "Marker", "<", "DisplayName", "RFS stage3 counter-side wind",'linewidth',3);


%% coefficient calculation 
% 4) definitions
% factor_landing_points is the minimum value of divisions of the absolute 
% distance from launchpad to the biggest ellipse (probably 3rd ellipse of
% 3rd stage) in directions of azimuth, opposite to azimuth and
% perpendicular to azimuth by the absolute distances from launchpad to
% taken landing points
% factor_altitude is the value of division of (mean apogee + 3*standard
% deviation) by the highest apogee from 3)

% initial calculations for NED coordinate system - launchpad is (0,0,0)
r_launchpad = lla2ecef([lat*180/pi, long*180/pi, 0])';
C_ecef2ned = [-sin(lat)*cos(long),-sin(long),-cos(lat)*cos(long);
    -sin(lat)*sin(long),cos(long),-cos(lat)*sin(long);
    cos(lat),0,-sin(long)]'; % <- transpose!!
C_ned2ecef = [-sin(lat)*cos(long),-sin(long),-cos(lat)*cos(long);
    -sin(lat)*sin(long),cos(long),-cos(lat)*sin(long);
    cos(lat),0,-sin(long)];
r_ellipse = lla2ecef([Ellipse_Struct(3).lat, Ellipse_Struct(3).long, zeros(length(Ellipse_Struct(3).lat),1)])';
ned_ellipse = C_ecef2ned*(r_ellipse-r_launchpad); 
r_front = lla2ecef([coord_front(1)*180/pi, coord_front(2)*180/pi, 0])';
ned_front = C_ecef2ned*(r_front-r_launchpad);
r_back = lla2ecef([coord_back(1)*180/pi, coord_back(2)*180/pi, 0])';
ned_back = C_ecef2ned*(r_back-r_launchpad);
r_side = lla2ecef([coord_side(1)*180/pi, coord_side(2)*180/pi, 0])';
ned_side = C_ecef2ned*(r_side-r_launchpad);
r_side_2 = lla2ecef([coord_side_2(1)*180/pi, coord_side_2(2)*180/pi, 0])';
ned_side_2 = C_ecef2ned*(r_side_2-r_launchpad);
r_no_wind = lla2ecef([coord_no_wind(1)*180/pi, coord_no_wind(2)*180/pi, 0])';
ned_no_wind = C_ecef2ned*(r_no_wind-r_launchpad);

% azimuths are calculated in NED coordinate system
azimuths_ellipse = atan2(ned_ellipse(2,:),ned_ellipse(1,:));
azimuth_front = atan2(ned_front(2),ned_front(1));
azimuth_back = atan2(ned_back(2),ned_back(1));
azimuth_side = atan2(ned_side(2),ned_side(1));
azimuth_side_2 = atan2(ned_side_2(2),ned_side_2(1));
azimuth_no_wind = atan2(ned_no_wind(2),ned_no_wind(1));

% distances are calculated in NED coordinate system
distances_ellipse = sqrt(ned_ellipse(1,:).^2+ned_ellipse(2,:).^2+ned_ellipse(3,:).^2);
distance_front = sqrt(ned_front(1).^2+ned_front(2).^2+ned_front(3).^2);
distance_back = sqrt(ned_back(1).^2+ned_back(2).^2+ned_back(3).^2);
distance_side = sqrt(ned_side(1).^2+ned_side(2).^2+ned_side(3).^2);
distance_side_2 = sqrt(ned_side_2(1).^2+ned_side_2(2).^2+ned_side_2(3).^2);
distance_no_wind = sqrt(ned_no_wind(1).^2+ned_no_wind(2).^2+ned_no_wind(3).^2);

% distances interpolated on ellipse are needed in definition, so they are
% calculated here
azimuths_query = [azimuth_front, azimuth_back, azimuth_side, azimuth_side_2, azimuth_no_wind];
distances_interp = interp1(azimuths_ellipse(1:99),distances_ellipse(1:99),azimuths_query);
distances_to_all_LP = [distance_front, distance_back, distance_side, distance_side_2, distance_no_wind];

% factors calculation
factor_landing_points = max(distances_interp./distances_to_all_LP);

apogees_all = [apogee_front, apogee_back, apogee_side, apogee_no_wind];
factor_altitude = (average3 + 3*standard_deviation3)/min(apogees_all);