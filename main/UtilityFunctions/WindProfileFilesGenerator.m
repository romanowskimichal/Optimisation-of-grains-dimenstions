function [wind_full_filenames] = WindProfileFilesGenerator (original_file_path, launch_azimuth, ...
    saving_location, simulation_name)

if exist(original_file_path,'file')
    %% Loading thrust
    w = importdata(original_file_path,'\t',1);
    altitudes = w.data(:,1);
    speeds = w.data(:,2);
    wind_direction_meteo = w.data(:,3)*pi/180.;
    clear w;
else
    st = dbstack;
    error('WindProfileFilesGenerator:%s: File not found: %s', st(1).name, filename);
end

%no wind
directions = launch_azimuth*ones(length(altitudes),1);
mkdir(fullfile(saving_location));
addpath(fullfile(saving_location));
location_name_no_wind = strcat(saving_location,simulation_name,'_no_wind_OPT.RFSwind');
file_no_wind = fopen(location_name_no_wind,'w');
fprintf(file_no_wind, "h[m]\tv[m/s]\tfi[deg]\n");
for i = 1:length(altitudes)
    fprintf(file_no_wind, "%.1f\t%.1f\t%0.f\n",altitudes(i),0.,directions(i));
end
fclose(file_no_wind);

%front wind
directions = launch_azimuth*ones(length(altitudes),1);
location_name_front_wind = strcat(saving_location,simulation_name,'_front_wind_OPT.RFSwind');
file_front_wind = fopen(location_name_front_wind,'w');
fprintf(file_front_wind, "h[m]\tv[m/s]\tfi[deg]\n");
for i = 1:length(altitudes)
    fprintf(file_front_wind, "%.1f\t%.1f\t%0.f\n",altitudes(i),speeds(i),directions(i));
end
fclose(file_front_wind);

%back wind
if launch_azimuth<180
    directions = (launch_azimuth+180)*ones(length(altitudes),1);
else
    directions = (launch_azimuth-180)*ones(length(altitudes),1);
end
location_name_back_wind = strcat(saving_location,simulation_name,'_back_wind_OPT.RFSwind');
file_back_wind = fopen(location_name_back_wind,'w');
fprintf(file_back_wind, "h[m]\tv[m/s]\tfi[deg]\n");
for i = 1:length(altitudes)
    fprintf(file_back_wind, "%.1f\t%.1f\t%0.f\n",altitudes(i),speeds(i),directions(i));
end
fclose(file_back_wind);

%side wind
if launch_azimuth<90
    directions = (launch_azimuth+270)*ones(length(altitudes),1);
else
    directions = (launch_azimuth-90)*ones(length(altitudes),1);
end
location_name_side_wind = strcat(saving_location,simulation_name,'_side_wind_OPT.RFSwind');
file_side_wind = fopen(location_name_side_wind,'w');
fprintf(file_side_wind, "h[m]\tv[m/s]\tfi[deg]\n");
for i = 1:length(altitudes)
    fprintf(file_side_wind, "%.1f\t%.1f\t%0.f\n",altitudes(i),speeds(i),directions(i));
end
fclose(file_side_wind);

wind_full_filenames = {location_name_no_wind;
    location_name_front_wind;
    location_name_back_wind;
    location_name_side_wind};
end