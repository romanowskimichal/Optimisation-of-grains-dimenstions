function [furthest_point, opposite_point, side_point, ...
    furthest_point_factor, opposite_point_factor, side_point_factor] = ...
    ExtremePointsForWindEllipses(lat_launchpad, long_launchpad, Points, safety_factor_landingpoints)
lat_launchpad = lat_launchpad*pi/180;
long_launchpad = long_launchpad*pi/180;

% launchpad in ecef, convertion matrices
r_launchpad = lla2ecef([lat_launchpad*180/pi, long_launchpad*180/pi, 0])';
C_ecef2ned = [-sin(lat_launchpad)*cos(long_launchpad),-sin(long_launchpad),-cos(lat_launchpad)*cos(long_launchpad);
    -sin(lat_launchpad)*sin(long_launchpad),cos(long_launchpad),-cos(lat_launchpad)*sin(long_launchpad);
    cos(lat_launchpad),0,-sin(long_launchpad)]'; % <- transpose!!
C_ned2ecef = [-sin(lat_launchpad)*cos(long_launchpad),-sin(long_launchpad),-cos(lat_launchpad)*cos(long_launchpad);
    -sin(lat_launchpad)*sin(long_launchpad),cos(long_launchpad),-cos(lat_launchpad)*sin(long_launchpad);
    cos(lat_launchpad),0,-sin(long_launchpad)];

% searching points with extreme distances
% 1st step: max distance for frontwind and back wind (unstable objects need to be considered also)
max_distance_for_frontwind_backwind = 0;
fieldnames_LP = fieldnames(Points.Landing_Points);
% NOTE: it probably could be done without for
for i = 1:length(fieldnames_LP)
    r_LP = lla2ecef([Points.Landing_Points.(fieldnames_LP{i, 1}).lat'*180/pi, ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long'*180/pi, ...
        zeros(length(Points.Landing_Points.(fieldnames_LP{i, 1}).long),1)]);
    if norm(r_LP(2,:)'-r_launchpad) > max_distance_for_frontwind_backwind
        furthest_point = [Points.Landing_Points.(fieldnames_LP{i, 1}).lat(2), ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long(2)];
        max_distance_for_frontwind_backwind = norm(r_LP(2,:)'-r_launchpad);
    end
    if norm(r_LP(3,:)'-r_launchpad) > max_distance_for_frontwind_backwind
        furthest_point = [Points.Landing_Points.(fieldnames_LP{i, 1}).lat(3), ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long(3)];
        max_distance_for_frontwind_backwind = norm(r_LP(3,:)'-r_launchpad);
    end
end
r_furthest = lla2ecef([furthest_point(1)*180/pi, furthest_point(2)*180/pi, 0])';

% 2nd step: two other points are chosen by min parallel distance and max 
% perpendicular distance from (r_furthest'-r_launchpad)
min_parallel_distance_for_frontwind_backwind = max_distance_for_frontwind_backwind;
max_perpendicular_distance_for_sidewind = 0;
for i = 1:length(fieldnames_LP)
    r_LP = lla2ecef([Points.Landing_Points.(fieldnames_LP{i, 1}).lat'*180/pi, ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long'*180/pi, ...
        zeros(length(Points.Landing_Points.(fieldnames_LP{i, 1}).long),1)]);
    if norm(r_LP(2,:)'-r_launchpad) ...
            *dot(r_furthest-r_launchpad,r_LP(2,:)'-r_launchpad) ...
            /(norm(r_furthest-r_launchpad)*norm(r_LP(2,:)'-r_launchpad)) ...
            < min_parallel_distance_for_frontwind_backwind
        opposite_point = [Points.Landing_Points.(fieldnames_LP{i, 1}).lat(2), ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long(2)];
        min_parallel_distance_for_frontwind_backwind = norm(r_LP(2,:)'-r_launchpad) ...
            *dot(r_furthest-r_launchpad,r_LP(2,:)'-r_launchpad) ...
            /(norm(r_furthest-r_launchpad)*norm(r_LP(2,:)'-r_launchpad));
    end
    if norm(r_LP(3,:)'-r_launchpad) ...
            *dot(r_furthest-r_launchpad,r_LP(3,:)'-r_launchpad) ...
            /(norm(r_furthest-r_launchpad)*norm(r_LP(3,:)'-r_launchpad)) ...
            < min_parallel_distance_for_frontwind_backwind
        opposite_point = [Points.Landing_Points.(fieldnames_LP{i, 1}).lat(3), ...
            Points.Landing_Points.(fieldnames_LP{i, 1}).long(3)];
        min_parallel_distance_for_frontwind_backwind = norm(r_LP(3,:)'-r_launchpad) ...
            *dot(r_furthest-r_launchpad,r_LP(3,:)'-r_launchpad) ...
            /(norm(r_furthest-r_launchpad)*norm(r_LP(3,:)'-r_launchpad));
    end

    if abs(norm(r_LP(4,:)'-r_launchpad) ...
            *norm(cross(r_furthest-r_launchpad,r_LP(4,:)'-r_launchpad)) ...
            /(norm(r_furthest-r_launchpad)*norm(r_LP(4,:)'-r_launchpad))) ...
            > max_perpendicular_distance_for_sidewind
        side_point = [Points.Landing_Points.(fieldnames_LP{i, 1}).lat(4), ...
            Points.Landing_Points.(fieldnames_LP{i, 1}).long(4)];
        max_perpendicular_distance_for_sidewind = abs(norm(r_LP(4,:)'-r_launchpad) ...
            *norm(cross(r_furthest-r_launchpad,r_LP(4,:)'-r_launchpad)) ...
            /(norm(r_furthest-r_launchpad)*norm(r_LP(4,:)'-r_launchpad)));
    end
end

% searched points converted to NED and later recalculated by factor 
ned_front = C_ecef2ned*(r_furthest-r_launchpad);
r_opposite = lla2ecef([opposite_point(1)*180/pi, opposite_point(2)*180/pi, 0])';
ned_opposite = C_ecef2ned*(r_opposite-r_launchpad);
r_side = lla2ecef([side_point(1)*180/pi, side_point(2)*180/pi, 0])';
ned_side = C_ecef2ned*(r_side-r_launchpad);

r_furthest_factor = C_ned2ecef*ned_front*safety_factor_landingpoints + r_launchpad;
furthest_point_factor = ecef2lla(r_furthest_factor');
r_opposite_factor = C_ned2ecef*ned_opposite*safety_factor_landingpoints + r_launchpad;
opposite_point_factor = ecef2lla(r_opposite_factor');
r_side_factor = C_ned2ecef*ned_side*safety_factor_landingpoints + r_launchpad;
side_point_factor = ecef2lla(r_side_factor');

furthest_point_factor(3) = [];
opposite_point_factor(3) = [];
side_point_factor(3) = [];

furthest_point_factor = furthest_point_factor*pi/180;
opposite_point_factor = opposite_point_factor*pi/180;
side_point_factor = side_point_factor*pi/180;
end