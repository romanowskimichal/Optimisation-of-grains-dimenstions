function [smallest_distance] = SmallestDistanceToTrainingGroundCeilInMeters(RecalculatedPoints, training_groud_ceil)

% Apogee (substruct)
fieldnames_A = fieldnames(RecalculatedPoints.Apogee);
for i = 1:length(fieldnames_A)
    % array with distances
    distances = zeros(1,length(RecalculatedPoints.Apogee.(fieldnames_A{i, 1}).alt));
    for j = 1:length(RecalculatedPoints.Apogee.(fieldnames_A{i, 1}).alt)
        distances(j) = training_groud_ceil - RecalculatedPoints.Apogee.(fieldnames_A{i, 1}).alt(j);
    end
    if i == 1 || min(distances)<smallest_distance
        smallest_distance = min(distances);
    end
end

end