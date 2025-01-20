clear all; clc;

% MODIFY HERE remind where data could be changed before next calculations

%% chosen month number and other variables that have to be changed
% 0     - to make plots for every month
% 1-12  - to make plot only for specific month (which bases on data from 3
% years and five stations)
chosen_month_number = 9;                                    % MODIFY HERE
boolean_general_plots_for_meteo_stations = false;           % MODIFY HERE
boolean_plot_and_files_for_training_ground = true;          % MODIFY HERE
folder_with_files_containing_wind_data = 'radiosondes';     % MODIFY HERE

%% reading the files list and options settings
files_list = dir(folder_with_files_containing_wind_data);
% opts = detectImportOptions(filename1);
% below are listed all changes done in command window to detected import options for one of files:
    % opts.VariableOptions(1,3:11) = opts.VariableOptions(1,2);
    % opts.VariableTypes{1, 1} = 'double';
    % opts.VariableOptions(1, 1).Name = 'PRES_hPa';
    % opts.VariableOptions(1, 2).Name = 'HGHT_m';
    % opts.VariableOptions(1, 3).Name = 'TEMP_C';
    % opts.VariableOptions(1, 4).Name = 'DWPT_C';
    % opts.VariableOptions(1, 5).Name = 'RELH_%';
    % opts.VariableOptions(1, 6).Name = 'MIXR_g/kg';
    % opts.VariableOptions(1, 7).Name = 'DRCT_deg';
    % opts.VariableOptions(1, 8).Name = 'SKNT_knot';
    % opts.VariableOptions(1, 9).Name = 'THTA_K';
    % opts.VariableOptions(1, 10).Name = 'THTE_K';
    % opts.VariableOptions(1, 11).Name = 'THTV_K';
    % opts.VariableNamingRule = 'preserve';
    % opts.Delimiter = ' ';
    % opts.ConsecutiveDelimitersRule = 'join';
    % opts.LeadingDelimitersRule = 'ignore';
    % opts.TrailingDelimitersRule = 'ignore';
    % opts.ExtraColumnsRule = 'ignore';
    % opts.DataLines = [1	Inf];
load('delimitedTextImportOptions.mat');
opts2 = opts;
for i = 1:11
    opts2.VariableTypes{1,i} = 'char';
end

%% reading data
for filename_number = 1:length(files_list)
    if length(files_list(filename_number).name) > 2 && ~strcmp(files_list(filename_number).name,'zrodlo.txt')
        % filename has to be changed every iteration
        filename1 = fullfile(folder_with_files_containing_wind_data, files_list(filename_number).name); 
        %przykład powyższej lokalizacji: 'C:\Users\Michal\Desktop\studia\sem7\Inżynierka\radiosondy\10393Lindenberg202301.txt';
        % reading data
        T_doubles = readtable(filename1,opts);
        T_chars = readtable(filename1,opts2);
        % station's elevation and number has to be changed every iteration
        station_elevation = T_doubles.TEMP_C(find(strcmp(T_chars.HGHT_m,'elevation:'),1));
        station_number = T_doubles.PRES_hPa(find(strcmp(T_chars.TEMP_C,'Observations'),1));
        boolean_two_word_in_station_name = false;
        if isempty(station_number)
            station_number = T_doubles.PRES_hPa(find(strcmp(T_chars.DWPT_C,'Observations'),1));
            boolean_two_word_in_station_name = true;
        end
        
        % subtables detection
        array_data_beginnings = find(T_doubles.PRES_hPa==station_number);
        array_data_ends = find(T_doubles.TEMP_C==station_number);
        if boolean_two_word_in_station_name == false
            array_data_hours = T_chars.("RELH_%")(array_data_beginnings);
        else
            array_data_hours = T_chars.("MIXR_g/kg")(array_data_beginnings);
        end
        % cleaning the incomplete data lines to the line full of NaNs 
        for i = 1:length(array_data_beginnings)
            for j = (array_data_beginnings(i)+5):(array_data_ends(i)-2)
                if isnan(T_doubles.THTV_K(j))
                    T_doubles(j,:) = array2table(nan(1,width(T_doubles)));
                end
            end
        end

        % matrices for mean profile calculations are created
        temp_matrix_mean_wind_speeds = zeros(ceil((max(T_doubles.HGHT_m)-station_elevation)/100),4);
        temp_matrix_wind_speed_u = zeros(ceil((max(T_doubles.HGHT_m)-station_elevation)/100),4);
        temp_matrix_wind_speed_v = zeros(ceil((max(T_doubles.HGHT_m)-station_elevation)/100),4);
        temp_matrix_counters = zeros(ceil((max(T_doubles.HGHT_m)-station_elevation)/100),4);
        for i = 1:length(array_data_beginnings)
            % an hour of measurement is detected
            if strcmp(array_data_hours{i,1},'00Z')
                temp_column = 1;
            elseif strcmp(array_data_hours{i,1},'06Z')
                temp_column = 2;
            elseif strcmp(array_data_hours{i,1},'12Z')
                temp_column = 3;
            else
                temp_column = 4;
            end
            % wind speed is averaged in every bucket of 100 m (limits are 
            % always every 100m starting from station's elevation)
            % in this way, ground effect is averaged and for similar
            % neighbourhoods of stations it should be almost identical
            % 0 m level is always at the station's elevation
            for j = (array_data_beginnings(i)+5):(array_data_ends(i)-2)
                if ~isnan(T_doubles.SKNT_knot(j))
                    if T_doubles.HGHT_m(j)>station_elevation
                        temp_matrix_mean_wind_speeds(ceil((T_doubles.HGHT_m(j)-station_elevation)/100),temp_column) = ...
                            (temp_matrix_mean_wind_speeds(ceil((T_doubles.HGHT_m(j)-station_elevation)/100),temp_column) * ...
                            temp_matrix_counters(ceil((T_doubles.HGHT_m(j)-station_elevation)/100),temp_column) + T_doubles.SKNT_knot(j)*0.51444)/ ...
                            (temp_matrix_counters(ceil((T_doubles.HGHT_m(j)-station_elevation)/100),temp_column) + 1);
                        temp_matrix_wind_speed_u(ceil((T_doubles.HGHT_m(j)-station_elevation)/100),temp_column) = ...
                            temp_matrix_wind_speed_u(ceil((T_doubles.HGHT_m(j)-station_elevation)/100),temp_column) + ...
                            -sin(pi/180*T_doubles.DRCT_deg(j))*T_doubles.SKNT_knot(j)*0.51444;
                        temp_matrix_wind_speed_v(ceil((T_doubles.HGHT_m(j)-station_elevation)/100),temp_column) = ...
                            temp_matrix_wind_speed_v(ceil((T_doubles.HGHT_m(j)-station_elevation)/100),temp_column) + ...
                            -cos(pi/180*T_doubles.DRCT_deg(j))*T_doubles.SKNT_knot(j)*0.51444;
                        temp_matrix_counters(ceil((T_doubles.HGHT_m(j)-station_elevation)/100),temp_column) = ...
                            temp_matrix_counters(ceil((T_doubles.HGHT_m(j)-station_elevation)/100),temp_column) + 1;
                    elseif T_doubles.HGHT_m(j) == station_elevation
                        temp_matrix_mean_wind_speeds(1,temp_column) = (temp_matrix_mean_wind_speeds(1,temp_column) * ...
                            temp_matrix_counters(1,temp_column) + T_doubles.SKNT_knot(j)*0.51444)/(temp_matrix_counters(1,temp_column) + 1);
                        temp_matrix_wind_speed_u(1,temp_column) = temp_matrix_wind_speed_u(1,temp_column) + ...
                            -sin(pi/180*T_doubles.DRCT_deg(j))*T_doubles.SKNT_knot(j)*0.51444;
                        temp_matrix_wind_speed_v(1,temp_column) = temp_matrix_wind_speed_v(1,temp_column) + ...
                            -cos(pi/180*T_doubles.DRCT_deg(j))*T_doubles.SKNT_knot(j)*0.51444;
                        temp_matrix_counters(1,temp_column) = temp_matrix_counters(1,temp_column) + 1;
                    end
                end
            end
        end
        for i = 1:width(T_chars)
            if ~strcmp(T_chars{1,width(T_chars)-i+1},'')
                station_year{1,1} = T_chars{1,width(T_chars)-i+1};
                break;
            end
        end
        station_year_position_in_string = strfind(files_list(filename_number).name,station_year{1,1});
        station_year = strcat('year', station_year{1,1});
        station_name = strcat('location',files_list(filename_number).name(1:(station_year_position_in_string-1)));
        station_month = strcat('month',files_list(filename_number).name((station_year_position_in_string+4):(station_year_position_in_string+5)));
        Struct_counters.(station_name).(station_year{1,1}).(station_month) = temp_matrix_counters;
        if chosen_month_number == 0
            temp_matrix_counters(find(temp_matrix_counters == 0))=NaN;
            temp_matrix_mean_wind_speeds(isnan(temp_matrix_counters))=NaN;
        end
        Struct_wind.(station_name).(station_year{1,1}).(station_month) = temp_matrix_mean_wind_speeds;
        Struct_wind_direction.(station_name).(station_year{1,1}).(station_month) = ...
            atan2(temp_matrix_wind_speed_u, temp_matrix_wind_speed_v)*180/pi + 180;
    end
end



%% plotting
list_stations = fieldnames(Struct_wind);
list_hours = {'00';'06';'12';'18'};
if chosen_month_number == 0
    if boolean_general_plots_for_meteo_stations
        for k = 1:length(list_stations)
            list_years = fieldnames(Struct_wind.(list_stations{k,1}));
            for l = 1:length(list_years)
                list_months = fieldnames(Struct_wind.(list_stations{k,1}).(list_years{l,1}));
                % month comparing for chosen hour
                for j = 1:length(list_hours)
                    figure;
                    graphicsname1 = strcat('month_comparing\mean_wind_for_each_month_',list_stations{k,1},'_',list_years{l,1},'_month01-06_hour',list_hours{j,1},'.png');
                    graphicstitle1 = strcat('Mean wind for',{' '},list_stations{k,1},{' '},list_years{l,1},{' '},'month01-06 hour',list_hours{j,1});
                    title(graphicstitle1);
                    hold on;
                    for i = 1:6
                        plot(50:100:length(Struct_wind.(list_stations{k,1}).(list_years{l,1}).(list_months{i,1}))*100-50,Struct_wind.(list_stations{k,1}).(list_years{l,1}).(list_months{i,1})(:,j));
                    end
                    legend(list_months(1:6,:));
                    ylim([0 140]);
                    xlim([0 40000]);
                    exportgraphics(gca,graphicsname1,"Resolution",300);

                    figure;
                    graphicsname2 = strcat('month_comparing\mean_wind_for_each_month_',list_stations{k,1},'_',list_years{l,1},'_month07-12_hour',list_hours{j,1},'.png');
                    graphicstitle2 = strcat('Mean wind for',{' '},list_stations{k,1},{' '},list_years{l,1},{' '},'month07-12 hour',list_hours{j,1});
                    title(graphicstitle2);
                    hold on;
                    for i = 7:length(list_months)
                        plot(50:100:length(Struct_wind.(list_stations{k,1}).(list_years{l,1}).(list_months{i,1}))*100-50,Struct_wind.(list_stations{k,1}).(list_years{l,1}).(list_months{i,1})(:,j));
                    end
                    legend(list_months(7:end,:));
                    ylim([0 140]);
                    xlim([0 40000]);
                    exportgraphics(gca,graphicsname2,"Resolution",300);
                end
            end
            close all;
        end

        for k = 1:length(list_stations)
            list_years = fieldnames(Struct_wind.(list_stations{k,1}));
            for l = 1:length(list_years)
                list_months = fieldnames(Struct_wind.(list_stations{k,1}).(list_years{l,1}));
                % hour comparing for chosen month
                for i = 1:length(list_months)
                    figure;
                    graphicsname3 = strcat('hour_comparing\mean_wind_for_each_month_',list_stations{k,1},'_',...
                        list_years{l,1},'_',list_months{i,1},'.png');
                    graphicstitle3 = strcat('Mean wind for',{' '},list_stations{k,1},{' '},list_years{l,1},{' '},...
                        list_months{i,1});
                    title(graphicstitle3);
                    hold on;
                    for j = 1:length(list_hours)
                        plot(50:100:length(Struct_wind.(list_stations{k,1}).(list_years{l,1}).(list_months{i,1}))*100-50,...
                            Struct_wind.(list_stations{k,1}).(list_years{l,1}).(list_months{i,1})(:,j));
                    end
                    legend(list_hours);
                    ylim([0 140]);
                    xlim([0 40000]);
                    exportgraphics(gca,graphicsname3,"Resolution",300);
                end
            end
            close all;
        end
    end

%% output for selected month
else
    if boolean_plot_and_files_for_training_ground
        % geografical coordinates are rewritten manually from data files
        hav_lat_array = [54.10; %Greifswald
            52.21;          %Lindenberg
            54.75;          %Leba
            52.40;          %Legionowo
            51.13];         %Wroclaw I
        hav_long_array= [13.40; %Greifswald
            14.12;          %Lindenberg
            17.53;          %Leba
            20.96;          %Legionowo
            16.98];         %Wroclaw I
        % hav_lat=53.413533; hav_long=15.768197; training_ground_name = 'Drawsko Pomorskie';            % MODIFY HERE
        % hav_lat=52.9442; hav_long=18.62207; training_ground_name = 'Torun';                           % MODIFY HERE
        % hav_lat=50.4460436; hav_long=21.7863401; training_ground_name = 'Nowa Deba';                  % MODIFY HERE
        % hav_lat=50.733611; hav_long=21.956944; training_ground_name = 'Lipa';                         % MODIFY HERE
        hav_lat=54.56537; hav_long=16.66746; training_ground_name = 'Wicko';                          % MODIFY HERE
        % dist = haversine(lat_array, long_array, lat, long);
        hav_lat_array = hav_lat_array*pi/180;
        hav_long_array = hav_long_array*pi/180;
        hav_lat = hav_lat*pi/180;
        hav_long = hav_long*pi/180;
        hav_R = 6371;                               % Earth's mean radius in km
        hav_delta_lat = hav_lat_array - hav_lat;            % difference in latitude
        hav_delta_lon = hav_long_array - hav_long;          % difference in longitude
        hav_under_root = sin(hav_delta_lat/2).^2 + cos(hav_lat) * cos(hav_lat_array) .* sin(hav_delta_lon/2).^2;
        hav_dist = 2*hav_R*asin(sqrt(hav_under_root));               % distance in km

        if chosen_month_number < 10
            chosen_month = strcat('month0', num2str(chosen_month_number));
        else
            chosen_month = strcat('month', num2str(chosen_month_number));
        end
        switch chosen_month_number
            case 1
                month_name = 'January';
            case 2
                month_name = 'February';
            case 3
                month_name = 'March';
            case 4
                month_name = 'April';
            case 5
                month_name = 'May';
            case 6
                month_name = 'June';
            case 7
                month_name = 'July';
            case 8
                month_name = 'August';
            case 9
                month_name = 'September';
            case 10
                month_name = 'October';
            case 11
                month_name = 'November';
            case 12
                month_name = 'December';
        end

        total_mean_wind = [];
        total_mean_direction_u = [];
        total_mean_direction_v = [];
        total_mean_wind_counters_sum = [];        % case counter weightened by distance also
        total_mean_wind_counters_control = [];    % case counter (just to control)
        for k = 1:length(list_stations)
            list_years = fieldnames(Struct_wind.(list_stations{k,1}));
            for l = 1:length(list_years)
                list_months = fieldnames(Struct_wind.(list_stations{k,1}).(list_years{l,1}));
                for j = 1:length(list_hours)
                    if isfield((Struct_wind.(list_stations{k,1}).(list_years{l,1})),(chosen_month))
                        length_mean_wind = length(total_mean_wind);
                        length_analysed_month = length((Struct_wind.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) .* (Struct_wind.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ./ hav_dist(k));
                        if length_mean_wind > length_analysed_month
                            total_mean_wind = total_mean_wind + cat(1,(Struct_wind.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ...
                                .* (Struct_counters.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ./ hav_dist(k), ...
                                zeros(length_mean_wind-length_analysed_month,1));
                            total_mean_direction_u = total_mean_direction_u + ...
                                cat(1, -sin((Struct_wind_direction.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j))*pi/180).*(Struct_wind.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ...
                                .* (Struct_counters.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ./ hav_dist(k), ...
                                zeros(length_mean_wind-length_analysed_month,1));
                            total_mean_direction_v = total_mean_direction_v + ...
                                cat(1, -cos((Struct_wind_direction.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j))*pi/180).*(Struct_wind.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ...
                                .* (Struct_counters.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ./ hav_dist(k), ...
                                zeros(length_mean_wind-length_analysed_month,1));
                            total_mean_wind_counters_sum = total_mean_wind_counters_sum ...
                                + cat(1,(Struct_counters.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ./ hav_dist(k), ...
                                zeros(length_mean_wind-length_analysed_month,1));
                            total_mean_wind_counters_control = total_mean_wind_counters_control ...
                                + cat(1,(Struct_counters.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)), ...
                                zeros(length_mean_wind-length_analysed_month,1));
                        else
                            total_mean_wind = cat(1,total_mean_wind,zeros(length_analysed_month-length_mean_wind,1)) ...
                                + (Struct_wind.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j))...
                                .* (Struct_counters.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ./ hav_dist(k);
                            total_mean_direction_u = cat(1,total_mean_direction_u,zeros(length_analysed_month-length_mean_wind,1)) + ...
                                -sin((Struct_wind_direction.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j))*pi/180).*(Struct_wind.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ...
                                .* (Struct_counters.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ./ hav_dist(k);
                            total_mean_direction_v = cat(1,total_mean_direction_v,zeros(length_analysed_month-length_mean_wind,1)) + ...
                                -cos((Struct_wind_direction.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j))*pi/180).*(Struct_wind.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ...
                                .* (Struct_counters.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ./ hav_dist(k);
                            total_mean_wind_counters_sum = cat(1,total_mean_wind_counters_sum,zeros(length_analysed_month-length_mean_wind,1)) ...
                                + (Struct_counters.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j)) ./ hav_dist(k);
                            total_mean_wind_counters_control = cat(1,total_mean_wind_counters_control, ...
                                zeros(length_analysed_month-length_mean_wind,1)) ...
                                + (Struct_counters.(list_stations{k,1}).(list_years{l,1}).(chosen_month)(:,j));
                        end
                    end
                end
            end
        end
        total_mean_wind = total_mean_wind ./ total_mean_wind_counters_sum;
        total_mean_direction = atan2(total_mean_direction_u,total_mean_direction_v) * 180/pi + 180;

        figure;
        graphicsname4 = strcat('chosen_location_plots_and_RFSwind_files\',training_ground_name,'_mean_wind_in_',...
            chosen_month,'.png');
        plot(50:100:length(total_mean_wind)*100-50, total_mean_wind);
        % ylim([0 140]);
        % xlim([0 40000]);
        title(strcat('Mean wind speed in', {' '}, month_name, ' for', {' '}, training_ground_name));
        xlabel('Altitude [m]');
        ylabel('Wind speed [m/s]');
        exportgraphics(gca,graphicsname4,"Resolution",300);


        filename_radiosondes = fopen(strcat('chosen_location_plots_and_RFSwind_files\',training_ground_name,...
            '2021-2023', chosen_month,'.RFSwind'),'w');
        fprintf(filename_radiosondes, "h[m]\tv[m/s]\tfi[deg]\n");
        for i = 1:length(total_mean_wind)
            %fprintf(filename_radiosondes, "%.0f\t%.3f\t%0.f\n",i*100-50,total_mean_wind(i,1),total_mean_direction(i,1));
            fprintf(filename_radiosondes, "%.0f\t%.3f\t%0.f\n",i*100-50,total_mean_wind(i,1),0);
        end
        fclose(filename_radiosondes);
    end
end

%% notes
% V  macierz -> 4 kolumny (00, 06, 12, 18) x n wierszy przedziałów wysokości co 100m
% V  w zasadzie dwie tabele (pierwsza zbiera wartość średnią, druga to
%    liczniki do liczenia tej średniej: mean_new=(mean_old*counter+new_value)/(counter+1), counter++)
% V  wczytanie
% V  co zrobić z różnicami wysokości miejsc? Wstępnie każda wysokości
% stacji zerem, ale potem trzeba ocenić wysokość wpływu gruntu... Róznica
% wysokości poligonów to maksymalnie 114 metrów (2 vs 116).
% V  Struct.(nazwa_stacji).(miesiąc) = macierz n x 4
% V  poprawić, aby działało dla każdego
% V  przekminić zmienność dobową i roczną danych
% -  na początku mogę zapamiętywać, ale koniec końców potrzebuję tylko
% średniej rocznej chyba - nie, inaczej!
% V  wybór miesiąca
% V  Uśrednić sierpień lub październik. Waga to ilość pomiarów dla 
% kubełka/odległość, która działa oczywiście dla środka kubełka i średniej
% prędkości w kubełku.


% -  wyciąć puste miejsca (tj. 'Station information and sounding indices') - nie, to potrzebne!
% V  wyciąć dane ponizej poziomu stacji - koniecznie!
% V  potem średnia dla danych z każdych 100m, zaczynanych co okrągła liczba
% V  jeśli uda się znaleźć sposób do dla każdej godziny osobno, na wypadek zmienności dobowej xd

