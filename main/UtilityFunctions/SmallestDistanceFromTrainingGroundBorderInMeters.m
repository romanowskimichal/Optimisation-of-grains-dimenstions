function [smallest_distance] = SmallestDistanceFromTrainingGroundBorderInMeters(lat_launchpad, ...
    long_launchpad, lat_ellipse, long_ellipse, input_json_txtTrainingGround)
lat_launchpad = lat_launchpad*pi/180;
long_launchpad = long_launchpad*pi/180;
input_json_txtTrainingGround = input_json_txtTrainingGround*pi/180;

r_launchpad = lla2ecef([lat_launchpad*180/pi, long_launchpad*180/pi, 0])';
C_ecef2ned = [-sin(lat_launchpad)*cos(long_launchpad),-sin(long_launchpad),-cos(lat_launchpad)*cos(long_launchpad);
    -sin(lat_launchpad)*sin(long_launchpad),cos(long_launchpad),-cos(lat_launchpad)*sin(long_launchpad);
    cos(lat_launchpad),0,-sin(long_launchpad)]'; % <- transpose!!

% Training Ground borders
r_ecef_TG = lla2ecef([input_json_txtTrainingGround(:,1)*180/pi, ...
    input_json_txtTrainingGround(:,2)*180/pi, ...
    zeros(length(input_json_txtTrainingGround(:,2)),1)])';
r_rel_ned_TG = C_ecef2ned*(r_ecef_TG-r_launchpad);


% % LandingPoints – previous version for structure with points 
% % (RecalculatedPoints instead of lat_ellipse, long_ellipse)
% fieldnames_LP = fieldnames(RecalculatedPoints.Landing_Points);
% for i = 1:length(fieldnames_LP)
%     r_ecef_LP = lla2ecef([RecalculatedPoints.Landing_Points.(fieldnames_LP{i, 1}).lat'*180/pi, ...
%         RecalculatedPoints.Landing_Points.(fieldnames_LP{i, 1}).long'*180/pi, ...
%         0*RecalculatedPoints.Landing_Points.(fieldnames_LP{i, 1}).long'])';
%     r_rel_ned_LP = C_ecef2ned*(r_ecef_LP-r_launchpad);
%     % matrix with distances (dimentions as TG*LP')
%     distances = zeros(length(r_rel_ned_TG),length(r_rel_ned_LP));
%     for j = 1:length(r_rel_ned_TG)
%         for k = 1:length(r_rel_ned_LP)
%             distances(j,k) = sqrt((r_rel_ned_TG(1,j)-r_rel_ned_LP(1,k))^2 + ...
%                 (r_rel_ned_TG(2,j)-r_rel_ned_LP(2,k))^2 + ...
%                 (r_rel_ned_TG(3,j)-r_rel_ned_LP(3,k))^2);
%         end
%     end
%     if i == 1 || min(distances,[],"all")<smallest_distance
%         smallest_distance = min(distances,[],"all");
%     end
% end

% Ellipse
r_ecef_E = lla2ecef([lat_ellipse*180/pi, long_ellipse*180/pi, 0*long_ellipse])';
r_rel_ned_E = C_ecef2ned*(r_ecef_E-r_launchpad);
% matrix with distances (dimentions as TG*E')
distances = zeros(length(r_rel_ned_TG),length(r_rel_ned_E));
for j = 1:length(r_rel_ned_TG)
    for k = 1:length(r_rel_ned_E)
        distances(j,k) = sqrt((r_rel_ned_TG(1,j)-r_rel_ned_E(1,k))^2 + ...
            (r_rel_ned_TG(2,j)-r_rel_ned_E(2,k))^2 + ...
            (r_rel_ned_TG(3,j)-r_rel_ned_E(3,k))^2);
    end
end
smallest_distance = min(distances,[],"all");

end