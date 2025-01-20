function [grain_dimention_min_volume, grain_dimention_max_volume] = CalculateMinAndMaxVolumeDimensions(GeometryIter)

if strcmp(GeometryIter.type,'Tube')
    if strcmp(GeometryIter.optimised_dimension, 'diameter_inner')
        grain_dimention_min_volume = GeometryIter.diameter_outer;
        grain_dimention_max_volume = 0;
    else
        error('Undefined optimisation for this dimension!');
    end
% "type":"Tube",
% "length_cyl":500,
% "diameter_outer":117.5,
% "diameter_inner":50,
% "optimised_dimension":"diameter_inner",

elseif strcmp(GeometryIter.type,'MultiChannel')
    if strcmp(GeometryIter.optimised_dimension, 'channel_diameter')
        grain_dimention_min_volume = GeometryIter.channel_ring_diameter*sin(pi/GeometryIter.channel_number);
        grain_dimention_max_volume = 0;
    else
        error('Undefined optimisation for this dimension!');
    end
% "type":"MultiChannel",
% "length_cyl":500,
% "diameter_outer":117.5,
% "channel_number":3,
% "channel_diameter":10,
% "channel_ring_diameter":75,
% "optimised_dimension":"channel_diameter",

elseif strcmp(GeometryIter.type,'Star')
    if strcmp(GeometryIter.optimised_dimension, 'star_outer_diameter')
        grain_dimention_min_volume = GeometryIter.diameter_outer;
        grain_dimention_max_volume = 0;
    else
        error('Undefined optimisation for this dimension!');
    end
% "type":"Star",
% "length_cyl":500,
% "diameter_outer":117.5,
% "star_arms_number":5,
% "star_outer_diameter":75,
% "star_arm_angle":90,
% "optimised_dimension":"star_outer_diameter",

elseif strcmp(GeometryIter.type,'FunctionChannel')
    if strcmp(GeometryIter.optimised_dimension, 'radial_function')
        if isfield(GeometryIter,'resolution')&&~isnan(GeometryIter.resolution)
            angle=linspace(0,2*pi,GeometryIter.resolution)';
        else
            angle=linspace(0,2*pi)';
        end
        max_value = max(eval(GeometryIter.radial_function));
        multiplicator = GeometryIter.diameter_outer/2/max_value;
        grain_dimention_min_volume = SingleMultiplicatorForGrainWithFunctionChannel (GeometryIter.radial_function, multiplicator);
        % grain_dimention_min_volume = strcat(num2str(multiplicator),'*(',GeometryIter.radial_function,')');
        grain_dimention_max_volume = num2str(0);
    else
        error('Undefined optimisation for this dimension!');
    end
% "type":"FunctionChannel",
% "length_cyl":500,
% "diameter_outer":117.5,
% "resolution":[null],
% "radial_function":"30+10*abs(cos(4*angle))",
% "optimised_dimension":"radial_function",

end

end 