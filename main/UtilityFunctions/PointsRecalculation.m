function RecalculatedPoints = PointsRecalculation(lat_launchpad, long_launchpad, Points, ...
    safety_factor_landingpoints, safety_factor_altitude)
lat_launchpad = lat_launchpad*pi/180;
long_launchpad = long_launchpad*pi/180;

r_launchpad = lla2ecef([lat_launchpad*180/pi, long_launchpad*180/pi, 0])';
C_ecef2ned = [-sin(lat_launchpad)*cos(long_launchpad),-sin(long_launchpad),-cos(lat_launchpad)*cos(long_launchpad);
    -sin(lat_launchpad)*sin(long_launchpad),cos(long_launchpad),-cos(lat_launchpad)*sin(long_launchpad);
    cos(lat_launchpad),0,-sin(long_launchpad)]'; % <- transpose!!
C_ned2ecef = [-sin(lat_launchpad)*cos(long_launchpad),-sin(long_launchpad),-cos(lat_launchpad)*cos(long_launchpad);
    -sin(lat_launchpad)*sin(long_launchpad),cos(long_launchpad),-cos(lat_launchpad)*sin(long_launchpad);
    cos(lat_launchpad),0,-sin(long_launchpad)];

% LandingPoints
fieldnames_LP = fieldnames(Points.Landing_Points);
for i = 1:length(fieldnames_LP)
    r_ecef = lla2ecef([Points.Landing_Points.(fieldnames_LP{i, 1}).lat'*180/pi, ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long'*180/pi, ...
        0*Points.Landing_Points.(fieldnames_LP{i, 1}).long'])';
    r_rel_ned = C_ecef2ned*(r_ecef-r_launchpad);
    r_rel_ned_new = r_rel_ned*safety_factor_landingpoints;
    r_ecef_new = C_ned2ecef*r_rel_ned_new + r_launchpad;
    temp_recalculated_points = ecef2lla(r_ecef_new');
    RecalculatedPoints.Landing_Points.(fieldnames_LP{i, 1}).lat = (temp_recalculated_points(:,1))'*pi/180;
    RecalculatedPoints.Landing_Points.(fieldnames_LP{i, 1}).long = (temp_recalculated_points(:,2))'*pi/180;
end

% Apogee
fieldnames_A = fieldnames(Points.Apogee);
for i = 1:length(fieldnames_A)
    r_ecef = lla2ecef([Points.Apogee.(fieldnames_A{i, 1}).lat'*180/pi, ...
        Points.Apogee.(fieldnames_A{i, 1}).long'*180/pi, ...
        0*Points.Apogee.(fieldnames_A{i, 1}).long'])';
    r_rel_ned = C_ecef2ned*(r_ecef-r_launchpad);
    r_rel_ned_new = r_rel_ned*safety_factor_landingpoints;
    r_ecef_new = C_ned2ecef*r_rel_ned_new + r_launchpad;
    temp_recalculated_points = ecef2lla(r_ecef_new');
    RecalculatedPoints.Apogee.(fieldnames_A{i, 1}).lat = (temp_recalculated_points(:,1))'*pi/180;
    RecalculatedPoints.Apogee.(fieldnames_A{i, 1}).long = (temp_recalculated_points(:,2))'*pi/180;
    RecalculatedPoints.Apogee.(fieldnames_A{i, 1}).alt = Points.Apogee.(fieldnames_A{i, 1}).alt*safety_factor_altitude;
    RecalculatedPoints.Apogee.(fieldnames_A{i, 1}).alt_rel = Points.Apogee.(fieldnames_A{i, 1}).alt_rel*safety_factor_altitude;
end

end
