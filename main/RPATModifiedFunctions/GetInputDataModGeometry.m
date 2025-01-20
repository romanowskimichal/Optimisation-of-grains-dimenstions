function InputStruct = GetInputDataModGeometry(InputStruct, run_by_gui)

%% Getting the geometry
%grains order from clousure to nozzle 1------->5
%a grain sorting algorithm should go here]

if  ~run_by_gui && exist(InputStruct.Simulation_Settings.grain_struct_path, 'file')...
        && InputStruct.Simulation_Settings.Booleans.load_grain_struct
    warning('Grain_Struct being overwritten because load_grain_struct is enabled');
    clearvars Grain_Struct;
    load(InputStruct.Simulation_Settings.grain_struct_path);
else
    %if there are multiple grains of the same filename, copy them instead
    %of having the ReadGrain function run again
    check_repeated_grain = strings(3, length(InputStruct.Grain_Struct));
    check_repeated_grain(1, :) = string({InputStruct.Grain_Struct(1:length(InputStruct.Grain_Struct)).Grain_stl_filename});
    check_repeated_grain(2, :) = string([InputStruct.Grain_Struct(1:length(InputStruct.Grain_Struct)).geometry_type]);
    check_repeated_grain(3, :) = string([InputStruct.Grain_Struct(1:length(InputStruct.Grain_Struct)).period_instances]);

    for i = 1 : length(InputStruct.Grain_Struct)
        if InputStruct.Grain_Struct(i).load_crossection_evolution == true
            InputStruct.Grain_Struct(i).Cross_Section_Struct = [];
            InputStruct.Grain_Struct(i) = LoadCrosssectionEvolution(InputStruct.Grain_Struct(i));
        else
            [~, index_of_repeated] = ismember(string({InputStruct.Grain_Struct(i).Grain_stl_filename, ...
                InputStruct.Grain_Struct(i).geometry_type, InputStruct.Grain_Struct(i).period_instances,}), ...
                check_repeated_grain', 'rows');
            if i > 1 && index_of_repeated ~= i
                InputStruct.Grain_Struct(i).Cross_Section_Struct = ...
                    InputStruct.Grain_Struct(index_of_repeated).Cross_Section_Struct;
            else
                InputStruct.Grain_Struct(i).Cross_Section_Struct = ReadGrain(InputStruct.Grain_Struct(i).Grain_stl_filename,...
                    InputStruct.Grain_Struct(i).geometry_type, InputStruct.Grain_Struct(i).period_instances, ...
                    InputStruct.Grain_Struct(i).coordinate_frame_axes, InputStruct.Grain_Struct(i).slice_height, ...
                    InputStruct.Grain_Struct(i).Inhibition,InputStruct.Grain_Struct(i).constant_cross_section);
            end

        end

    end
    if (~run_by_gui) && InputStruct.Simulation_Settings.save_grain_struct == true
        if ~exist('.\InputFiles\Grains', 'dir')
            mkdir('.\InputFiles\Grains');
            save(InputStruct.Simulation_Settings.grain_struct_path, 'Grain_Struct');
        else
            save(InputStruct.Simulation_Settings.grain_struct_path, 'Grain_Struct');
        end
    end
end


end