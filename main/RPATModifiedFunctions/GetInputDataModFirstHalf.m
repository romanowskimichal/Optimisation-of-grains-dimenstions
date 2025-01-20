function [InputStruct, extension] = GetInputDataModFirstHalf(InputStruct, ...
    input_data_location, run_by_gui)

if (~run_by_gui)
[~, input_function_name, extension] = fileparts(input_data_location);

% if(input_filename == 0)
    %     disp("Name wasn't set");
    %     InputStruct.Grain_Struct=nan;
    %     InputStruct.Fuel_Input=nan;
    %     InputStruct.Engine_Parameters=nan;
    %     InputStruct.Ambient_Input=nan;
    %     InputStruct.Simulation_Settings=nan;
    %     extension=nan;
    %     cancel_flag=true;
    %     return;
    % else
    %     cancel_flag=false;
    % end
    
    if(extension == ".RPATsession")
        JSON_Data_Struct = jsondecode(fileread(input_data_location));
        InputStruct.Simulation_Settings = JSON_Data_Struct.Simulation_Settings;
        InputStruct.Fuel_Input = JSON_Data_Struct.Fuel_Input;
        InputStruct.Ambient_Input = JSON_Data_Struct.Ambient_Input;
        InputStruct.Engine_Parameters = JSON_Data_Struct.Engine_Parameters;
        InputStruct.Grain_Struct = JSON_Data_Struct.Grain_Struct;
    elseif(extension == ".m")
        InputFunctionHandle = str2func(input_function_name);
        [InputStruct.Fuel_Input, InputStruct.Grain_Struct, InputStruct.Engine_Parameters, ...
            InputStruct.Ambient_Input, InputStruct.Simulation_Settings] = InputFunctionHandle();
    elseif(extension == ".mat")
        load(input_data_location, 'Fuel_Input', 'Grain_Struct', 'Engine_Parameters', ...
            'Ambient_Input', 'Simulation_Settings')
        InputStruct.Simulation_Settings.input_data_location = input_data_location;
        InputStruct.Simulation_Settings.continuing_simulation = true;
        InputStruct.Simulation_Settings.load_grain_struct = false;
    else
        error('Wrong input file extension. Please choose *.m, *.RPATsession or *.mat file!');
    end
else
    % input_data_location=0;
    extension=0;
    % cancel_flag=false;
end


% Validate input file
[InputStruct.Grain_Struct, InputStruct.Simulation_Settings, InputStruct.Engine_Parameters, ...
    InputStruct.Ambient_Input, InputStruct.Fuel_Input] = ValidateInputFile(InputStruct.Grain_Struct, ...
    InputStruct.Simulation_Settings, InputStruct.Engine_Parameters, InputStruct.Ambient_Input, InputStruct.Fuel_Input);


end