function GenerateGeoplot(lat_launchpad, long_launchpad, Points, TrainingGroundPoints, TrainingGroundName,...
    safety_factor_landingpoints, safety_factor_altitude, wind_speed, elevation, ...
    azimuth, iteration_number, ceil, saving_location_and_name_without_extension)

figure;
gx = geoaxes('Position', [0.15 0.3 0.8 0.6]);
lat_launchpad = lat_launchpad*pi/180;
long_launchpad = long_launchpad*pi/180;
TrainingGroundPoints = TrainingGroundPoints*pi/180;

geobasemap satellite;
hold on;
C = colororder("gem");
L = legend;
L.AutoUpdate = 'off';
geoplot(gx,TrainingGroundPoints([1:end,1],1)*180/pi,TrainingGroundPoints([1:end,1],2)*180/pi,'m-.','DisplayName',TrainingGroundName,'linewidth',2);


%% plotting points on geoplot
fieldnames_LP = fieldnames(Points.Landing_Points);
for i = 1:length(fieldnames_LP)
    geoscatter(Points.Landing_Points.(fieldnames_LP{i, 1}).lat(1)*180/pi, ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long(1)*180/pi,'Marker','diamond','MarkerEdgeColor',C(i,:));
    geoscatter(Points.Landing_Points.(fieldnames_LP{i, 1}).lat(2)*180/pi, ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long(2)*180/pi,'Marker','v','MarkerEdgeColor',C(i,:));
    geoscatter(Points.Landing_Points.(fieldnames_LP{i, 1}).lat(3)*180/pi, ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long(3)*180/pi,'Marker','^','MarkerEdgeColor',C(i,:));
    geoscatter(Points.Landing_Points.(fieldnames_LP{i, 1}).lat(4)*180/pi, ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long(4)*180/pi,'Marker','>','MarkerEdgeColor',C(i,:));
    % second side wind point calculation
    [Points.Landing_Points.(fieldnames_LP{i, 1}).lat(5), ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long(5)] = CalculateSecondSideWindLandingPoint(lat_launchpad*180/pi, ...
        long_launchpad*180/pi, Points.Landing_Points.(fieldnames_LP{i, 1}).lat(2), ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long(2), ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).lat(4), ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long(4));

    geoscatter(Points.Landing_Points.(fieldnames_LP{i, 1}).lat(5)*180/pi, ...
        Points.Landing_Points.(fieldnames_LP{i, 1}).long(5)*180/pi,'Marker','<','MarkerEdgeColor',C(i,:));
end


%% constant xlim and ylim 
% (calculated from: training ground boundaries, launchpad location, landing 
% points location), later xlim and ylim are described with 5% of space from 
% every side; NE point of geoplot is base for hidden points for legend (+1 deg 
% for lat and long)
lat_temp = [min(TrainingGroundPoints(:,1)),max(TrainingGroundPoints(:,1))]; % training ground boundaries
long_temp = [min(TrainingGroundPoints(:,2)),max(TrainingGroundPoints(:,2))];
if lat_launchpad > lat_temp(2) % launchpad location
    lat_temp(2) = lat_launchpad;
end
if long_launchpad > long_temp(2)
    long_temp(2) = long_launchpad;
end
if lat_launchpad < lat_temp(1)
    lat_temp(1) = lat_launchpad;
end
if long_launchpad < long_temp(1)
    long_temp(1) = long_launchpad;
end
for i = 1:length(fieldnames_LP) % landing points location
    if max(Points.Landing_Points.(fieldnames_LP{i, 1}).lat) > lat_temp(2)
        lat_temp(2) = max(Points.Landing_Points.(fieldnames_LP{i, 1}).lat);
    end
    if max(Points.Landing_Points.(fieldnames_LP{i, 1}).long) > long_temp(2)
        long_temp(2) = max(Points.Landing_Points.(fieldnames_LP{i, 1}).long);
    end
    if min(Points.Landing_Points.(fieldnames_LP{i, 1}).lat) < lat_temp(1)
        lat_temp(1) = min(Points.Landing_Points.(fieldnames_LP{i, 1}).lat);
    end
    if min(Points.Landing_Points.(fieldnames_LP{i, 1}).long) < long_temp(1)
        long_temp(1) = min(Points.Landing_Points.(fieldnames_LP{i, 1}).long);
    end

end
lat_temp = [lat_temp(1)-0.05*(lat_temp(2)-lat_temp(1)),lat_temp(2)+0.05*(lat_temp(2)-lat_temp(1))]; % 5% of space from every side
long_temp = [long_temp(1)-0.05*(long_temp(2)-long_temp(1)),long_temp(2)+0.05*(long_temp(2)-long_temp(1))];

geolimits(lat_temp*180/pi,long_temp*180/pi);

%% creative legend
% coloured squares are desribing stages, black triangles - wind directions
L.AutoUpdate = 'on';
geoscatter(lat_launchpad*180/pi, long_launchpad*180/pi, 'Marker','*','MarkerEdgeColor',C(length(fieldnames_LP)+1,:),'DisplayName','Launchpad');
geoscatter(lat_temp(2)*180/pi+1, long_temp(2)*180/pi+1, 'Marker','diamond', 'MarkerEdgeColor','k','DisplayName','no wind');
geoscatter(lat_temp(2)*180/pi+1, long_temp(2)*180/pi+1, 'Marker','v', 'MarkerEdgeColor','k','DisplayName','front wind');
geoscatter(lat_temp(2)*180/pi+1, long_temp(2)*180/pi+1, 'Marker','^', 'MarkerEdgeColor','k','DisplayName','back wind');
geoscatter(lat_temp(2)*180/pi+1, long_temp(2)*180/pi+1, 'Marker','>', 'MarkerEdgeColor','k','DisplayName','side wind');
geoscatter(lat_temp(2)*180/pi+1, long_temp(2)*180/pi+1, 'Marker','<', 'MarkerEdgeColor','k','DisplayName','counter-side wind');
for i = 1:length(fieldnames_LP)
    geoscatter(lat_temp(2)*180/pi+1, long_temp(2)*180/pi+1, 'Marker','square', 'MarkerEdgeColor',C(i,:),'MarkerFaceColor',C(i,:),'DisplayName',fieldnames_LP{i, 1});
end
L.AutoUpdate = 'off'; % or maybe after pseudoellipses?

%% pseudoellipses
[furthest_point, opposite_point, sidewind_point, ...
    furthest_point_factor, opposite_point_factor, sidewind_point_factor] = ...
    ExtremePointsForWindEllipses(lat_launchpad*180/pi, long_launchpad*180/pi, Points, safety_factor_landingpoints);
GeneratePseudoellipse(lat_launchpad*180/pi, long_launchpad*180/pi, furthest_point, ...
    opposite_point, sidewind_point, true);
GeneratePseudoellipse(lat_launchpad*180/pi, long_launchpad*180/pi, furthest_point_factor, ...
    opposite_point_factor, sidewind_point_factor, true);

%% textboxes and saving
% first textbox
if isa(wind_speed,'double')
    annotation_1_string = [strcat('Coefficient for landing points:', {' '}, num2str(safety_factor_landingpoints)), ...
        strcat('Wind speed:', {' '}, num2str(wind_speed), ' m/s'), ...
        strcat('Elevation:', {' '}, num2str(elevation), ' deg, Azimuth:', {' '}, num2str(azimuth), ' deg')];
else
    annotation_1_string = [strcat('Coefficient for landing points:', {' '}, num2str(safety_factor_landingpoints)), ...
        strcat('Wind speed:', {' '}, wind_speed), ...
        strcat('Elevation:', {' '}, num2str(elevation), ' deg, Azimuth:', {' '}, num2str(azimuth), ' deg')];
end
annotation('textbox', [0.05, 0.02, 0.4, 0.18], 'string', annotation_1_string, 'FitBoxToText', 'on');

% second textbox NOTE: list of all the highest altitudes could be added
max_altitude = zeros(length(fieldnames_LP),1);
for i = 1:length(fieldnames_LP)
    for j = 1:4
        if max_altitude(i) < Points.Apogee.(fieldnames_LP{i, 1}).alt(j)
            max_altitude(i) = Points.Apogee.(fieldnames_LP{i, 1}).alt(j);
        end
    end
end

annotation_2_string = [strcat('Max altitude:', {' '}, num2str(max(max_altitude)), ' m'), ...
    strcat('Coefficient for altitude:', {' '}, num2str(safety_factor_altitude)), ...
    strcat('Ceil for training ground:', {' '}, num2str(ceil), ' m'), ...
    strcat('Iteration number:', {' '}, num2str(iteration_number))];
annotation('textbox', [0.54, 0.02, 0.4, 0.18], 'string', annotation_2_string, 'FitBoxToText', 'on');

% save as .png
exportgraphics(gcf,strcat(saving_location_and_name_without_extension,'.png'),"Resolution",300);
saveas(gcf, saving_location_and_name_without_extension);

hold off; % close is unnecesary, figure will close with new figure for new geometry

end