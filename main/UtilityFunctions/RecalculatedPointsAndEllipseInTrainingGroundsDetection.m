function [boolean_points_in_training_ground, objectcases_in_training_ground, objectcases_under_ceil, ...
    objectcases_total] = RecalculatedPointsAndEllipseInTrainingGroundsDetection(RecalculatedPoints, ...
    input_json_txtTrainingGround, training_groud_ceil, lat_ellipse, long_ellipse)

objectcases_in_training_ground = 0;
objectcases_under_ceil = 0;
objectcases_total = 0;
objectcases_total2 = 0;
objectcases_nans_1 = 0;
objectcases_nans_2 = 0;
boolean_points_in_training_ground = false;

input_json_txtTrainingGround = input_json_txtTrainingGround*pi/180;


% LandingPoints
fieldnames_LP = fieldnames(RecalculatedPoints.Landing_Points);
for i = 1:length(fieldnames_LP)
    for j = 1:length(RecalculatedPoints.Landing_Points.(fieldnames_LP{i, 1}).lat)
        if inpolygon(RecalculatedPoints.Landing_Points.(fieldnames_LP{i, 1}).lat(j), ...
                RecalculatedPoints.Landing_Points.(fieldnames_LP{i, 1}).long(j), ...
                input_json_txtTrainingGround(:,1), input_json_txtTrainingGround(:,2))
            objectcases_in_training_ground = objectcases_in_training_ground + 1;
        elseif or(isnan(RecalculatedPoints.Landing_Points.(fieldnames_LP{i, 1}).lat(j)), ...
                isnan(RecalculatedPoints.Landing_Points.(fieldnames_LP{i, 1}).long(j)))
            objectcases_nans_1 = objectcases_nans_1 + 1;
        end
        objectcases_total = objectcases_total + 1;
    end
end
warning_string_1 = strcat('OPTmessage:', {' '}, num2str(objectcases_nans_1), ' objectcases have NaNs for Landing Points!');
if objectcases_nans_1 > 0
    warning(warning_string_1{1,1});
end


% Apogee
fieldnames_A = fieldnames(RecalculatedPoints.Apogee);
for i = 1:length(fieldnames_A)
    for j = 1:length(RecalculatedPoints.Apogee.(fieldnames_A{i, 1}).lat)
        if RecalculatedPoints.Apogee.(fieldnames_A{i, 1}).alt(j) < training_groud_ceil
            objectcases_under_ceil = objectcases_under_ceil + 1;
        elseif isnan(RecalculatedPoints.Apogee.(fieldnames_A{i, 1}).alt(j))
            objectcases_nans_2 = objectcases_nans_2 + 1;
        end
        objectcases_total2 = objectcases_total2 + 1;
    end
end
warning_string_2 = strcat('OPTmessage:', {' '}, num2str(objectcases_nans_2), ' objectcases have NaNs for Apopgees!');
if objectcases_nans_2 > 0
    warning(warning_string_2{1,1});
end


% Ellipse
if all(inpolygon(lat_ellipse, long_ellipse, input_json_txtTrainingGround(:,1), input_json_txtTrainingGround(:,2)))
    objectcases_in_training_ground = objectcases_in_training_ground + 1;
elseif or(any(isnan(lat_ellipse)),any(isnan(long_ellipse)))
    objectcases_nans_1 = objectcases_nans_1 + 1;
    warning_string_3 = strcat('OPTmessage:', {' '}, num2str(objectcases_nans_1), ' objectcases have NaNs for pseudoellipse!');
    warning(warning_string_3{1,1});
end
objectcases_total = objectcases_total + 1;


if (objectcases_in_training_ground + objectcases_nans_1 == objectcases_total && ...
        objectcases_under_ceil + objectcases_nans_2 == objectcases_total2)
    boolean_points_in_training_ground = true;
end
end