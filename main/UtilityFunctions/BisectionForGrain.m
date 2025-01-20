function [new_grain_dimention, grain_dimention_min_volume, ...
    grain_dimention_max_volume, boolean_it_is_finally_over] = BisectionForGrain(boolean_points_in_training_ground, ...
    grain_dimention, grain_dimention_min_volume, grain_dimention_max_volume, ...
    expected_accuracy_multiplied_by_dim, ...
    boolean_FunctionChannel, resolution_FunctionChannel)

% more readable (i think) scheme of this function:
% boolean... == true: 
%   grain_dimention_min_volume := grain_dimention
%       [NewGrainDimention := avg(StrukturaWymiarowZiarna,grain_dimention_max_volume)]
%   NewGrainDimention := avg(grain_dimention_min_volume,grain_dimention_max_volume)
%   grain_dimention_max_volume [no change]
% boolean... == false: 
%   grain_dimention_max_volume := grain_dimention
%       [NewGrainDimention := avg(GrainDimention,grain_dimention_max_volume)]
%   new_grain_dimention := avg(grain_dimention_min_volume,grain_dimention_max_volume)
%   grain_dimention_min_volume [no change]

if boolean_points_in_training_ground == true
grain_dimention_min_volume = grain_dimention;
else
grain_dimention_max_volume = grain_dimention;
end

% as FunctionChannel works on string it needs other way
if boolean_FunctionChannel
    
    if exist('resolution_FunctionChannel','var')&&~isnan(resolution_FunctionChannel)
        angle=linspace(0,2*pi,resolution_FunctionChannel)';
    else
        angle=linspace(0,2*pi)';
    end
    max_value_Max = max(eval(grain_dimention_max_volume));
    max_value_Min = max(eval(grain_dimention_min_volume));
    max_value = max(eval(grain_dimention));
    multiplicator = (max_value_Min+max_value_Max)/2/max_value;

    new_grain_dimention = SingleMultiplicatorForGrainWithFunctionChannel (grain_dimention, multiplicator);

    if max_value_Min - max_value_Max < expected_accuracy_multiplied_by_dim
        boolean_it_is_finally_over = true;
    else
        boolean_it_is_finally_over = false;
    end
else
    new_grain_dimention = (grain_dimention_min_volume+grain_dimention_max_volume)/2;

    if grain_dimention_min_volume - grain_dimention_max_volume < expected_accuracy_multiplied_by_dim
        boolean_it_is_finally_over = true;
    else
        boolean_it_is_finally_over = false;
    end
end

end