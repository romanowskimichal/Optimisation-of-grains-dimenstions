function GeneratePseudoellipse(lat_launchpad, long_launchpad, frontwind_point, backwind_point, sidewind_point)
% pseudo-ellipse as radial function:
% back + (front - back) ((1 + cos(x)) / 2)^log((1 + cos(π / 2)) / 2, (side - back) / abs(front - back))
% If (cos(x) > 0, side2 + (front2 - side2) (1 + cos(2x)) / 2, side2 + (back2 - side2) (1 + cos(2x)) / 2), etc.

% intersection of semiaxis
[lat_second_side, long_second_side] = CalculateSecondSideWindLandingPoint(lat_launchpad, ...
        long_launchpad, frontwind_point(1), frontwind_point(2), sidewind_point(1), sidewind_point(2));
A_1 = (frontwind_point(1)-lat_launchpad)/(frontwind_point(2)-long_launchpad);
B_1 = lat_launchpad-A_1*long_launchpad;
A_2 = (lat_second_side-sidewind_point(1))/(long_second_side-sidewind_point(2));
B_2 = sidewind_point(1)-A_2*sidewind_point(2);
long_intersect = (B_2-B_1)/(A_1-A_2);
lat_intersect = A_1*long_intersect+B_1;

% distances from intersection to landing points
r_intersect = lla2ecef([lat_intersect*180/pi, long_intersect*180/pi, 0])';
C_ecef2ned = [-sin(lat_intersect)*cos(long_intersect),-sin(long_intersect),-cos(lat_intersect)*cos(long_intersect);
    -sin(lat_intersect)*sin(long_intersect),cos(long_intersect),-cos(lat_intersect)*sin(long_intersect);
    cos(lat_intersect),0,-sin(long_intersect)]'; % <- transpose!!
C_ned2ecef = [-sin(lat_intersect)*cos(long_intersect),-sin(long_intersect),-cos(lat_intersect)*cos(long_intersect);
    -sin(lat_intersect)*sin(long_intersect),cos(long_intersect),-cos(lat_intersect)*sin(long_intersect);
    cos(lat_intersect),0,-sin(long_intersect)];

r_front = lla2ecef([frontwind_point(1)*180/pi, frontwind_point(2)*180/pi, 0])';
r_back = lla2ecef([backwind_point(1)*180/pi, backwind_point(2)*180/pi, 0])';
r_side = lla2ecef([sidewind_point(1)*180/pi, sidewind_point(2)*180/pi, 0])';

ned_front = C_ecef2ned*(r_front-r_intersect);
ned_back = C_ecef2ned*(r_back-r_intersect);
ned_side = C_ecef2ned*(r_side-r_intersect);

front_dist = norm(ned_front);
back_dist = norm(ned_back);
side_dist = norm(ned_side);
front_azimuth = atan2(ned_front(1),ned_front(2));
% calculating points for 100 lines for ellipse
theta = linspace(0,2*pi,100)';
if front_dist > side_dist && side_dist > back_dist % f>s>b, b>s>f
    ellipse_dist = back_dist+(front_dist-back_dist)*((1+cos(theta))/2).^ ...
        (log((side_dist-back_dist)/abs(front_dist - back_dist)) / log((1+cos(pi/2))/2));
else % f>b>s, b>f>s, s>f>b, s>b>f
    ellipse_dist = [side_dist + (front_dist-side_dist) * (1+cos(2*theta(1:25)))/2; ...
        side_dist + (back_dist-side_dist) * (1+cos(2*theta(26:75)))/2; ...
        side_dist + (front_dist-side_dist) * (1+cos(2*theta(76:100)))/2];
end
ellipse_n = ellipse_dist.*cos(theta+front_azimuth);
ellipse_e = ellipse_dist.*sin(theta+front_azimuth);

r_ellipse = C_ned2ecef*([ellipse_n,ellipse_e, zeros(length(ellipse_n),1)])' + r_intersect;
lla_ellipse = ecef2lla(r_ellipse');
lat_ellipse = lla_ellipse (:,1);
long_ellipse = lla_ellipse (:,2);
% drawing ellipse by 100 lines
geoplot (lat_ellipse, long_ellipse, 'y-');

end