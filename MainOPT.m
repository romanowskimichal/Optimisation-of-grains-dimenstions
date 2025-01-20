function MainOPT(input_json_OPT, run_by_GUI, app)
clc; clearvars -except input_json_OPT run_by_GUI app; close all;

%% adding programme subfolders to path, reading OPTsession
% Add folders needed by the program to work
path_folders = {genpath('main\Input'), 'main\GeometryFunctions', 'main\UtilityFunctions',...
    'main\CEAM', 'main\RPATModifiedFunctions', 'main\RFSModifiedFunctions', 'main\GeoplotFunctions'};
current_file_name = mfilename('fullpath');
[path_string, ~, ~] = fileparts(current_file_name);
for i = 1:numel(path_folders)
    addpath(fullfile(path_string, path_folders{i}));
end

if ~exist('run_by_GUI','var')
    run_by_GUI = false;
end
if run_by_GUI == false
    % Read session file if session_string does not exist or is empty
    if ~exist('input_geometry_string', 'var')
        [inputFileName, inputPath, ~] = uigetfile(fullfile('main\Input\Sessions','*.OPTsession'),...
            'Select input file');
        inputFullFilename = fullfile(inputPath, inputFileName);
        [~, session_name, ~] = fileparts(inputFullFilename);
        input_geometry_string = fileread(inputFullFilename);
    end

    input_json_OPT = jsondecode(input_geometry_string);
    if ~isfield(input_json_OPT.General,'session_title')
        input_json_OPT.General.session_title = session_name;
    end
end


[output_path_name, output_folder_or_file_name] = CreateOutputFolderOPT(input_json_OPT.General.session_title);
mkdir(fullfile(path_string, output_path_name));
diary(fullfile(output_path_name, [output_folder_or_file_name '.log']));
HTML_1 = strcat('<html><head><style> table {font-family: arial, sans-serif; border-collapse: collapse; width:',...
    ' 100%;} td, th {border: 1px solid #dddddd; text-align: left; padding: 8px;} tr:nth-child(even)',...
    ' {background-color: #dddddd;}</style></head><body><h2>',input_json_OPT.General.session_title,{' '},...
    '(',string(datetime),')</h2>');
HTML_2 = '<table><tr><th>Date and time</th><th>Message</th></tr>';
HTML_3 = '</table></body></html>';


%% adding programmes to path, functions with the same name differentiation and reading JSONs

% RPAT is added to path

path_folders={genpath('../rpat/Source/main/InputFiles'), ...
    '../rpat/Source/main/Auxiliary', '../rpat/Source/main/Ballistics',...
    '../rpat/Source/main/Core', '../rpat/Source/main/Debug', ...
    '../rpat/Source/main/Grain', '../rpat/Source/main/GrainRegression', ...
    '../rpat/Source/main/Hybrid', ... '../rpat/Source/main/PausedSimulations', ...
    '../rpat/Source/main/UtilityFunctions', '../rpat/Source/main'};
for i = 1:numel(path_folders)
    addpath(fullfile(strcat(path_string), path_folders{i}));
end
path_folders={'main\Input\RPATsessions'};
addpath(fullfile(path_string, path_folders{1}));

% doubled names in RPAT
RPATRFSdoubled_names = {"Main"; "rk4"; "AskForSimulationTitle"; "DrawPlots"; ...
    "SaveFigureToFiles"; "StartParallelPool"};
MainRPAT = str2func(RPATRFSdoubled_names{1,1});
rk4RPAT = str2func(RPATRFSdoubled_names{2,1});
AskForSimulationTitleRPAT = str2func(RPATRFSdoubled_names{3,1});
DrawPlotsRPAT = str2func(RPATRFSdoubled_names{4,1});
SaveFigureToFilesRPAT = str2func(RPATRFSdoubled_names{5,1});
StartParallelPoolRPAT = str2func(RPATRFSdoubled_names{6,1});


% RFS is added to path

% path_folders = {'../symulacja-lotu/Source/main'};
path_folders = {genpath('../symulacja-lotu/Source/main/InputData'), ...
    '../symulacja-lotu/Source/main/Aerodynamics', '../symulacja-lotu/Source/main/Atmosphere', ...
    '../symulacja-lotu/Source/main/Core', '../symulacja-lotu/Source/main/DataManagement', ...
    '../symulacja-lotu/Source/main/Gravity', '../symulacja-lotu/Source/main/InputFunctions', ...
    '../symulacja-lotu/Source/main/MathematicalFunctions', '../symulacja-lotu/Source/main/Motor', ...
    '../symulacja-lotu/Source/main/UtilityFunctions', '../symulacja-lotu/Source'};
for i = 1:numel(path_folders)
    addpath(fullfile(strcat(path_string), path_folders{i}));
end

% doubled names in RFS
MainRFS = str2func(RPATRFSdoubled_names{1,1});
rk4RFS = str2func(RPATRFSdoubled_names{2,1});
AskForSimulationTitleRFS = str2func(RPATRFSdoubled_names{3,1});
DrawPlotsRFS = str2func(RPATRFSdoubled_names{4,1});
SaveFigureToFilesRFS = str2func(RPATRFSdoubled_names{5,1});
StartParallelPoolRFS = str2func(RPATRFSdoubled_names{6,1});



%% reading global input files

                                                                                %NOTE: DODAĆ INNE ROZSZERZENIA DO RPAT-A
                                                                                    %PRZEZ GetInputDataMod?
                                                                                    %DODANE
                                                                                    %TERAZ ZWERYFIKOWAĆ DZIAŁANIE
inputFullFilename_RPATinput = fullfile(path_string, input_json_OPT.RPATdata.original_session_filepath);
inputFullFilename_RFSsession = fullfile(path_string, input_json_OPT.RFSdata.original_session_filepath);
inputFullFilename_txtTrainingGround = fullfile(path_string, input_json_OPT.RFSdata.training_groud_filepath);

%input_RPATsession_string = fileread(inputFullFilename_RPATsession);
input_RFSsession_string = fileread(inputFullFilename_RFSsession);
input_txtTrainingGround_string = fileread(inputFullFilename_txtTrainingGround);

%input_json_RPATsession = jsondecode(input_RPATsession_string);
input_json_RFSsession = jsondecode(input_RFSsession_string);
input_json_txtTrainingGround = jsondecode(input_txtTrainingGround_string);

% reading RPAT input file (.m/.RPATsession/.mat)
[input_json_RPATsession.Grain_Struct, input_json_RPATsession.Fuel_Input, ...
    input_json_RPATsession.Engine_Parameters, input_json_RPATsession.Ambient_Input, ...
    input_json_RPATsession.Simulation_Settings, run_by_gui] = deal(0);
[input_json_RPATsession, ~] = ...
    GetInputDataModFirstHalf(input_json_RPATsession, inputFullFilename_RPATinput, run_by_gui);

% reading .RFSrocket files
[path_string_RFSrocket, ~, ~] = fileparts(inputFullFilename_RFSsession);
inputFullFilename_RFSrocket = fullfile(path_string_RFSrocket, '..\..\..\',input_json_RFSsession.rocket_file);
input_RFSrocket_string = fileread(inputFullFilename_RFSrocket);
% input_json_RFSrocket = jsondecode(input_RFSrocket_string);

% saving original input files
output_path_name_for_original_files = fullfile(path_string, output_path_name, 'InputDataOriginal');
mkdir(output_path_name_for_original_files);
copyfile(inputFullFilename_RPATinput, output_path_name_for_original_files);
copyfile(inputFullFilename_RFSsession, output_path_name_for_original_files);
copyfile(inputFullFilename_txtTrainingGround, output_path_name_for_original_files);
copyfile(inputFullFilename_RFSrocket, output_path_name_for_original_files);
file_OPTsession_backup = fopen(fullfile(output_path_name_for_original_files,strcat(output_folder_or_file_name,'.OPTsession')),'w');
fprintf(file_OPTsession_backup, jsonencode(input_json_OPT,PrettyPrint=true));
fclose(file_OPTsession_backup);


% extracting training ground's name from its filename
[~, inputTrainingGroundName, ~] = fileparts(inputFullFilename_txtTrainingGround);
inputTrainingGroundName = strrep(inputTrainingGroundName,'_',' ');


% latitude, longitude and altitude from GUI
if isfield(input_json_OPT.RFSdata,'boolean_coordinates_from_session') ...
        && ~input_json_OPT.RFSdata.boolean_coordinates_from_session % '~' because true is standard value
    input_json_RFSsession.motion_initialization_launchpad.lat = input_json_OPT.RFSdata.latitude;
    input_json_RFSsession.motion_initialization_launchpad.long = input_json_OPT.RFSdata.longitude;
end
if isfield(input_json_OPT.RFSdata,'boolean_azimuth_from_session') ...
        && ~input_json_OPT.RFSdata.boolean_azimuth_from_session % '~' because true is standard value
    input_json_RFSsession.motion_initialization_launchpad.azimuth = input_json_OPT.RFSdata.azimuth;
end

% wind files creation
wind_saving_location = strcat(path_string, '\', output_path_name, '\WindProfiles\');
if isfield(input_json_OPT.RFSdata,'max_wind_speed')
    wind_full_filenames = WindConstantFilesGenerator (input_json_OPT.RFSdata.max_wind_speed, ...
        input_json_RFSsession.motion_initialization_launchpad.azimuth, ...
        input_json_RFSsession.motion_initialization_launchpad.lat, ...
        input_json_RFSsession.alt_surface, wind_saving_location, output_folder_or_file_name);
elseif isfield(input_json_OPT.RFSdata,'wind_profile_filepath')
    wind_full_filenames = WindProfileFilesGenerator (input_json_OPT.RFSdata.wind_profile_filepath, ...
        input_json_RFSsession.motion_initialization_launchpad.azimuth, ...
        wind_saving_location, output_folder_or_file_name);
end


%% CEAM

if input_json_OPT.RPATdata.boolean_CEAM_data_usage
    % calculating constants from input for RPAT
    facAcAt = input_json_RPATsession.Engine_Parameters.Chamber_Input.crosssection_area/...
        (pi*(input_json_RPATsession.Engine_Parameters.Nozzle_Input.throat_diameter)^2);
    p_bar = (input_json_RPATsession.Fuel_Input.coeffs_ranges(1)+ ...
        input_json_RPATsession.Fuel_Input.coeffs_ranges(2))/2*10; % mean value, recalculated from MPa to bar
    supAeAt = (input_json_RPATsession.Engine_Parameters.Nozzle_Input.exit_diameter/...
        input_json_RPATsession.Engine_Parameters.Nozzle_Input.throat_diameter)^2;
    % reading parts of string from input for OPT
    CEA_full_input_string = ReadingCEAMReactantsInput(input_json_OPT.CEAMreactants);
    % adding to string data from input for RPAT
    CEA_full_input_string = strcat(CEA_full_input_string, '''problem'',''rocket'',');
    CEA_full_input_string = strcat(CEA_full_input_string, '''fac'',''acat'',', num2str(facAcAt), ',');
    CEA_full_input_string = strcat(CEA_full_input_string, '''p,bar'',', num2str(p_bar), ',');
    CEA_full_input_string = strcat(CEA_full_input_string, '''sup,ae/at'',', num2str(supAeAt), ',');
    CEA_full_input_string = strcat(CEA_full_input_string, '''output'',''transport'',''mks'',');
    CEA_full_input_string = strcat(CEA_full_input_string, '''end'',''', output_path_name, '\', ...
        input_json_OPT.General.session_title, '_CEAMoutput.txt''');
    % use of CEA function
    CEAM_output = eval(strcat('CEA(',CEA_full_input_string,')'));
    [~,CEAM_values_in_output] = ReadingCEAMOutput(strcat(output_path_name, '\', input_json_OPT.General.session_title, '_CEAMoutput.txt'));

    % CEAM data overwriting into RPAT input
    input_json_RPATsession.Fuel_Input.temperature_combustion = CEAM_values_in_output(1);
    input_json_RPATsession.Fuel_Input.kappa = CEAM_values_in_output(2);
    input_json_RPATsession.Fuel_Input.molar_mass = CEAM_values_in_output(3);
    input_json_RPATsession.Fuel_Input.dynamic_viscosity = CEAM_values_in_output(4);
    input_json_RPATsession.Fuel_Input.C_p = CEAM_values_in_output(5);
    input_json_RPATsession.Fuel_Input.Pr = CEAM_values_in_output(6);
    input_json_RPATsession.Fuel_Input.conductivity = CEAM_values_in_output(7);
    propellant_CEAM_name = [];
    reactant_CEAM_names = fieldnames(input_json_OPT.CEAMreactants);
    for i=1:length(reactant_CEAM_names)
        propellant_CEAM_name = strcat(propellant_CEAM_name, (reactant_CEAM_names{i, 1}), ...
            num2str(input_json_OPT.CEAMreactants.(reactant_CEAM_names{i, 1}).weight_percent));
        if i~=length(reactant_CEAM_names)
            propellant_CEAM_name = strcat(propellant_CEAM_name, '-');
        end
    end
    input_json_RPATsession.Fuel_Input.propellant_name  = propellant_CEAM_name;

    % non-CEAM data overwriting into RPAT input
    input_json_RPATsession.Fuel_Input.propellant_density = input_json_OPT.NonCEAMDataForRPAT.propellant_density;
    input_json_RPATsession.Fuel_Input.burn_coefficient = input_json_OPT.NonCEAMDataForRPAT.burn_coefficient;
    input_json_RPATsession.Fuel_Input.burn_expo = input_json_OPT.NonCEAMDataForRPAT.burn_expo;
    input_json_RPATsession.Fuel_Input.C_pr = input_json_OPT.NonCEAMDataForRPAT.C_pr;
    input_json_RPATsession.Fuel_Input.beta = input_json_OPT.NonCEAMDataForRPAT.beta;

    disp('OPTmessage: CEAM data calculations and Non-CEAM data import have been completed with success!');
    HTML_2 = strcat(HTML_2,'<tr><td>',string(datetime),...
        '</td><td>CEAM data calculations and Non-CEAM data import have been completed with success!</td></tr>');
    app.HTML.HTMLSource = strcat (HTML_1,HTML_2,HTML_3);
end


%% loops start
% outer loop - every iteration is another geometry type typu
number_of_geometries = length(input_json_OPT.Geometry);
ResultsForGUITable = table();
for geometry_number = 1:number_of_geometries
% a trick to overcome problems with different indexing for one and multiple
% geometries (the same geometry is added at end, but is not used as it lies
% beyond final value of geometry_number) in an easy way
if length(input_json_OPT.Geometry) == 1
    input_json_OPT.Geometry = {input_json_OPT.Geometry{1,1}; []};
end
[grain_dimention_min_volume, grain_dimention_max_volume] = CalculateMinAndMaxVolumeDimensions(input_json_OPT.Geometry{geometry_number, 1});




% inner loop - every iteration is another geometry of the same type
specific_geometry_iter = 0;
boolean_it_is_finally_over = false;
boolean_ever_were_points_in_training_ground = false;
number_last_points_in_training_ground = 0;
while (boolean_it_is_finally_over == false)
specific_geometry_iter = specific_geometry_iter + 1;



%% RPAT pre-launch
% creating .stl file for each iteration
output_path_name_for_iteration = strcat(output_path_name,'\', ...
    input_json_OPT.Geometry{geometry_number,1}.filename,'\',num2str(specific_geometry_iter));

mkdir(fullfile(path_string, output_path_name_for_iteration));
addpath(fullfile(path_string, output_path_name_for_iteration));
stl_pathname = ComputeGeometry(input_json_OPT,output_path_name_for_iteration,geometry_number,specific_geometry_iter);

input_json_RPATsession.Grain_Struct.Grain_stl_filename = stl_pathname;


%% RPAT launch with grain proper for each iteration

% ReadGrain output overwriting
input_json_RPATsession = GetInputDataModGeometry(input_json_RPATsession, run_by_gui);

% Getting simulation name
if (~run_by_gui)
    simulation_title = strcat(input_json_OPT.General.session_title,'_',input_json_OPT.Geometry{geometry_number,1}.filename,...
        '_',num2str(specific_geometry_iter));
else
    simulation_title = input_json_RPATsession.Simulation_Settings.GUI_simulation_title;
end

% Creating output path name
input_json_RPATsession.Simulation_Settings.output_folder_name = '\OutputDataRPAT';
input_json_RPATsession.Simulation_Settings.output_path_name = strcat(output_path_name_for_iteration,...
    input_json_RPATsession.Simulation_Settings.output_folder_name, '\');

%in most cases not needed, copied from original GetInputData.m:
if(input_json_RPATsession.Simulation_Settings.Booleans.perform_3D_visualisation == true)
    mkdir(fullfile(input_json_RPATsession.Simulation_Settings.output_path_name, 'Visualisation'));
    input_json_RPATsession.Simulation_Settings.Visualisation_Settings.output_path_name = ...
        strcat(output_path_name_for_iteration, '/Visualisation');
end

% if cancel_flag==true
%     return;
% end

if ~exist(input_json_RPATsession.Simulation_Settings.output_path_name, 'dir')% && ~exist(Simulation_Settings.output_folder_name,"var")
    mkdir(input_json_RPATsession.Simulation_Settings.output_path_name);
end

% Start counting time taken by the simulation
tic

scripted = true;    %Set it to true if using scriptability

% Core Calculations
[input_json_RPATsession.Simulation_Results, input_json_RPATsession.Output_Data, ...
    input_json_RPATsession.Fuel_Input, input_json_RPATsession.Engine_Parameters] = ...
    CoreCalculations(input_json_RPATsession.Grain_Struct, input_json_RPATsession.Fuel_Input, ...
    input_json_RPATsession.Engine_Parameters, input_json_RPATsession.Ambient_Input, ...
    input_json_RPATsession.Simulation_Settings);

% Return time taken by the simulation
input_json_RPATsession.Simulation_Settings.elapsed_simulation_time=toc;

% Create InputData subfolder in output folder
mkdir(fullfile(input_json_RPATsession.Simulation_Settings.output_path_name, 'InputData'));

% RPAT Output files
if (~run_by_gui)
    if scripted
        WriteInputFile(strcat(input_json_RPATsession.Simulation_Settings.output_path_name, "InputData\"), ...
            strcat(simulation_title, "_InputRPAT"),input_json_RPATsession.Fuel_Input, ...
            input_json_RPATsession.Grain_Struct,input_json_RPATsession.Engine_Parameters, ...
            input_json_RPATsession.Ambient_Input,input_json_RPATsession.Simulation_Settings);
    end

    % Plots
    if(input_json_RPATsession.Simulation_Settings.Booleans.draw_plots == true && ...
            ~input_json_RPATsession.Simulation_Results.terminated_flag && ...
            input_json_RPATsession.Simulation_Settings.Booleans.hybrid_engine == false)
        DrawPlotsRPAT(input_json_RPATsession.Simulation_Settings.output_path_name, ...
            simulation_title, input_json_RPATsession.Simulation_Results, ...
            input_json_RPATsession.Simulation_Settings.Plots_Settings);
    end
    if (input_json_RPATsession.Simulation_Settings.Booleans.draw_plots == true && ...
            ~input_json_RPATsession.Simulation_Results.terminated_flag && ...
            input_json_RPATsession.Simulation_Settings.Booleans.hybrid_engine == true)
        DrawPlotsHybrid(input_json_RPATsession.Simulation_Settings.output_path_name, ...
            input_json_RPATsession.Simulation_Results, input_json_RPATsession.Simulation_Settings.Plots_Settings);
    end

end


if(input_json_RPATsession.Simulation_Settings.Booleans.generate_output_all == true && ...
        input_json_RPATsession.Simulation_Settings.Booleans.hybrid_engine == false)
    GenerateOutputAll(input_json_RPATsession.Simulation_Settings.output_path_name, ...
        input_json_RPATsession.Simulation_Results,simulation_title);
end

if(input_json_RPATsession.Simulation_Settings.Booleans.generate_output_all == true && ...
        input_json_RPATsession.Simulation_Settings.Booleans.hybrid_engine == true)
    GenerateOutputAllHybrid(input_json_RPATsession.Simulation_Settings.output_path_name, ...
        input_json_RPATsession.Simulation_Results);
end

if(input_json_RPATsession.Simulation_Settings.Booleans.generate_rfs_input == true)
    GenerateRfsInput(input_json_RPATsession.Simulation_Settings.output_path_name, ...
        simulation_title, input_json_RPATsession.Simulation_Results, simulation_title);
end

if(input_json_RPATsession.Simulation_Settings.Booleans.generate_output_short == true)
    GenerateOutputShort(input_json_RPATsession.Simulation_Settings.output_path_name, ...
        simulation_title, simulation_title, input_json_RPATsession.Output_Data, ...
        input_json_RPATsession.Simulation_Results.propellant_mass(1), ...
        input_json_RPATsession.Fuel_Input, input_json_RPATsession.Ambient_Input, ...
        input_json_RPATsession.Engine_Parameters, input_json_RPATsession.Grain_Struct, ...
        input_json_RPATsession.Simulation_Settings);

    %Creating HTML output file:
    GenerateOutputShortHTML(input_json_RPATsession.Simulation_Settings.output_path_name, ...
        simulation_title, simulation_title, input_json_RPATsession.Output_Data, ...
        input_json_RPATsession.Simulation_Results.propellant_mass(1),...
        input_json_RPATsession.Fuel_Input, input_json_RPATsession.Ambient_Input, ...
        input_json_RPATsession.Engine_Parameters, input_json_RPATsession.Grain_Struct, ...
        input_json_RPATsession.Simulation_Settings);
end
                                                                                %NOTE: USUŃ TO POTEM
% if ~run_by_gui % Prevent from displaying 'ans' in the Command Window while using Main() manually
%     clearvars;
% end

disp(strcat('OPTmessage: RPAT calculations has been completed with success for the geometry', {' '}, ...
    num2str(geometry_number),', iteration', {' '}, num2str(specific_geometry_iter), '!'));
HTML_2 = strcat(HTML_2,'<tr><td>',string(datetime),'</td><td>RPAT calculations has been completed with success for the geometry', {' '}, ...
    num2str(geometry_number),', iteration', {' '}, num2str(specific_geometry_iter), '!</td></tr>');
app.HTML.HTMLSource = strcat (HTML_1,HTML_2{1,1},HTML_3);



%% RFS pre-launch
% creating input files by remake of original .RFSrocket file (adress in .RFSsession), 
% motor files is changed on new one from RPAT in this script 

% renewed reading of RFS input is needed as cells are tranformed into
% struct - change of variable type is a change of way of indexing
input_json_RFSrocket = jsondecode(input_RFSrocket_string);

output_path_name_for_RFSmotor = strcat(path_string, '\', input_json_RPATsession.Simulation_Settings.output_path_name, ...
    simulation_title,'.RFSmotor');
% due to some problems with '\O' such replacement is needed:
output_path_name_for_RFSmotor = strrep(output_path_name_for_RFSmotor,'\','/');

% motor files is changed here, objects without motor cannot have field 'Motor_Parameters'
for i = 1:length(input_json_RFSrocket)
    if isfield(input_json_RFSrocket{i, 1}, 'Motor_Parameters')
        input_json_RFSrocket{i, 1}.Motor_Parameters.filepath = output_path_name_for_RFSmotor;
    end
end
% input_json_RFSrocket{1, 1}.Motor_Parameters.filepath = output_path_name_for_RFSmotor; %NOTE: USUŃ TO
% input_json_RFSrocket{3, 1}.Motor_Parameters.filepath = output_path_name_for_RFSmotor;

% objects with motors of next objects need recalculation of mass
input_json_RFSrocket = ProperObjectMassForNewMotor(input_json_RFSrocket);

% names for whole RFS
OPTsimulation_title_for_RFS = strcat(input_json_OPT.General.session_title,'Geometry', ... 
    input_json_OPT.Geometry{geometry_number,1}.filename,'Case',num2str(specific_geometry_iter));
output_path_name_for_RFS = strcat(path_string, '\', output_path_name_for_iteration, ...
    '\OutputDataRFS');

% name for .RFSrocket file and its temporary directory
output_path_name_for_RFSrocket_temp = strcat(path_string, '\', output_path_name_for_iteration,'\Temp\',OPTsimulation_title_for_RFS,'.RFSrocket');
mkdir(strcat(output_path_name_for_RFS,'\..\Temp\'));
% saving .RFSrocket file with proper .RFSmotor file in JSON PrettyPrint format
input_RFSrocket_string_new = jsonencode(input_json_RFSrocket,PrettyPrint=true);
input_RFSrocket_string_new = strrep(input_RFSrocket_string_new,'null','[null]');
RFSrocket_file_id = fopen(output_path_name_for_RFSrocket_temp,'w');
fprintf(RFSrocket_file_id, input_RFSrocket_string_new);
fclose(RFSrocket_file_id);

%due the same problems with '\O' such replacement is needed:
output_path_name_for_RFSrocket_temp = strrep(output_path_name_for_RFSrocket_temp,'\','/');
% proper .RFSrocket file (with proper .RFSmotor file) path in .RFSsession
% and number of workers is added to conduct all 4 simulations simultanously
input_json_RFSsession.rocket_file = output_path_name_for_RFSrocket_temp;
input_json_RFSsession.number_of_workers = 4;

%% RFS launch

% settings
results_filter = {'lat', 'long','alt', 'alt_rel'};
filename = fullfile('Output',output_path_name_for_iteration);

input_json_RFSrocket = input_json_RFSrocket';
input_json_RFSsession = input_json_RFSsession';
stages_number = length(input_json_RFSrocket);

if ~isstruct(input_json_RFSrocket)
    Temp_Objects = input_json_RFSrocket{1};
    for stage = 2:stages_number
        parameters_names = fieldnames(input_json_RFSrocket{stage});
        for parameter = 1:length(parameters_names)
            Temp_Objects(stage).(parameters_names{parameter}) =...
                input_json_RFSrocket{stage}.(parameters_names{parameter});
        end
    end
    input_json_RFSrocket = Temp_Objects;
end

for i = 1:length(wind_full_filenames)
	Modified_Session(i) = input_json_RFSsession;
	Modified_Session(i).wind_file = wind_full_filenames{i,1};
end



input_json_RFSsession.session_name = 'Grot3';
input_RFSsession_string_new = jsonencode(input_json_RFSsession);

cd ..\symulacja-lotu\Source\

Simulation_Results = MainRFSMod(input_RFSsession_string_new, [], Modified_Session, ...
    results_filter, output_path_name_for_RFS, OPTsimulation_title_for_RFS);

cd (path_string)

delete(output_path_name_for_RFSrocket_temp);
rmdir(strcat(output_path_name_for_RFS,'\..\Temp\'));

% saving results to struct
for i = 1:size(Simulation_Results, 1)
    latitude = [Simulation_Results{i}{1}.lat];
    longitude = [Simulation_Results{i}{1}.long];
    Landing_Points.stage123.lat(i) = latitude(end);
    Landing_Points.stage123.long(i) = longitude(end);
    alt = [Simulation_Results{i}{1}.alt];
    alt_rel = [Simulation_Results{i}{1}.alt_rel];
    [~,j] = max(alt_rel);
    Apogee.stage123.lat(i) = latitude(j);
    Apogee.stage123.long(i) = longitude(j);
    Apogee.stage123.alt(i) = alt(j);
    Apogee.stage123.alt_rel(i) = alt_rel(j);

    latitude = [Simulation_Results{i}{2}.lat];
    longitude = [Simulation_Results{i}{2}.long];
    Landing_Points.stage1.lat(i) = latitude(end);
    Landing_Points.stage1.long(i) = longitude(end);
    alt = [Simulation_Results{i}{2}.alt];
    alt_rel = [Simulation_Results{i}{2}.alt_rel];
    [~,j] = max(alt_rel);
    Apogee.stage1.lat(i) = latitude(j);
    Apogee.stage1.long(i) = longitude(j);
    Apogee.stage1.alt(i) = alt(j);
    Apogee.stage1.alt_rel(i) = alt_rel(j);
    
    latitude = [Simulation_Results{i}{3}.lat];
    longitude = [Simulation_Results{i}{3}.long];
    Landing_Points.stage23.lat(i) = latitude(end);
    Landing_Points.stage23.long(i) = longitude(end);
    alt = [Simulation_Results{i}{3}.alt];
    alt_rel = [Simulation_Results{i}{3}.alt_rel];
    [~,j] = max(alt_rel);
    Apogee.stage23.lat(i) = latitude(j);
    Apogee.stage23.long(i) = longitude(j);
    Apogee.stage23.alt(i) = alt(j);
    Apogee.stage23.alt_rel(i) = alt_rel(j);
    
    latitude = [Simulation_Results{i}{4}.lat];
    longitude = [Simulation_Results{i}{4}.long];
    Landing_Points.stage2.lat(i) = latitude(end);
    Landing_Points.stage2.long(i) = longitude(end);
    alt = [Simulation_Results{i}{4}.alt];
    alt_rel = [Simulation_Results{i}{4}.alt_rel];
    [~,j] = max(alt_rel);
    Apogee.stage2.lat(i) = latitude(j);
    Apogee.stage2.long(i) = longitude(j);
    Apogee.stage2.alt(i) = alt(j);
    Apogee.stage2.alt_rel(i) = alt_rel(j);
    
    latitude = [Simulation_Results{i}{5}.lat];
    longitude = [Simulation_Results{i}{5}.long];
    Landing_Points.stage3.lat(i) = latitude(end);
    Landing_Points.stage3.long(i) = longitude(end);
    alt = [Simulation_Results{i}{5}.alt];
    alt_rel = [Simulation_Results{i}{5}.alt_rel];
    [~,j] = max(alt_rel);
    Apogee.stage3.lat(i) = latitude(j);
    Apogee.stage3.long(i) = longitude(j);
    Apogee.stage3.alt(i) = alt(j);
    Apogee.stage3.alt_rel(i) = alt_rel(j);
end

Points(specific_geometry_iter).Landing_Points=Landing_Points;
Points(specific_geometry_iter).Apogee=Apogee;

disp(strcat('OPTmessage: RFS calculations has been completed with success for the geometry', {' '}, ...
    num2str(geometry_number),', iteration', {' '}, num2str(specific_geometry_iter), '!'));
HTML_2 = strcat(HTML_2,'<tr><td>',string(datetime),'</td><td>RFS calculations has been completed with success for the geometry', {' '}, ...
    num2str(geometry_number),', iteration', {' '}, num2str(specific_geometry_iter), '!</td></tr>');
app.HTML.HTMLSource = strcat (HTML_1,HTML_2{1,1},HTML_3);



%% before next iteration things and inner loop stop (end is below)
% saving Points to file for every geometry iteration
mat_filename_iter = fullfile(output_path_name,input_json_OPT.Geometry{geometry_number,1}.filename, 'Points');
mkdir(mat_filename_iter);
mat_filename_iter = strcat(mat_filename_iter,'\Points_',input_json_OPT.Geometry{geometry_number,1}.filename, ...
    num2str(specific_geometry_iter),'.mat');
Points_iter=Points(specific_geometry_iter);
save(mat_filename_iter, 'Points_iter');

% Points recalculation by coefficient and detection if it fits in training ground
RecalculatedPoints = PointsRecalculation(input_json_RFSsession.motion_initialization_launchpad.lat, ...
    input_json_RFSsession.motion_initialization_launchpad.long, Points_iter, input_json_OPT.General.factor_landing_points, ...
    input_json_OPT.General.factor_altitude);

safety_factor_landingpoints = 1; % because new points already calculated
[furthest_point, opposite_point, sidewind_point, ~, ~, ~] = ...
    ExtremePointsForWindEllipses(input_json_RFSsession.motion_initialization_launchpad.lat, ...
    input_json_RFSsession.motion_initialization_launchpad.long, RecalculatedPoints, ...
    safety_factor_landingpoints);
[lat_pseudoellipse, long_pseudoellipse] = GeneratePseudoellipse(input_json_RFSsession.motion_initialization_launchpad.lat, ...
    input_json_RFSsession.motion_initialization_launchpad.long, ...
    furthest_point, opposite_point, sidewind_point, false); % this pseudoellipse is only used for calculation, not for plotting

% [boolean_points_in_training_ground,~,~,~] = RecalculatedPointsInTrainingGroundsDetection(RecalculatedPoints, ...
%     input_json_txtTrainingGround, input_json_OPT.RFSdata.training_groud_ceil);
[boolean_points_in_training_ground,~,~,~] = RecalculatedPointsAndEllipseInTrainingGroundsDetection(RecalculatedPoints, ...
    input_json_txtTrainingGround, input_json_OPT.RFSdata.training_groud_ceil, lat_pseudoellipse, long_pseudoellipse);

if boolean_points_in_training_ground
    boolean_ever_were_points_in_training_ground = true;

    % Detection if it fits in margin
    smallest_distance_on_ground = SmallestDistanceFromTrainingGroundBorderInMeters(input_json_RFSsession.motion_initialization_launchpad.lat, ...
        input_json_RFSsession.motion_initialization_launchpad.long, lat_pseudoellipse, long_pseudoellipse, input_json_txtTrainingGround);
    smallest_distance_for_apogees = SmallestDistanceToTrainingGroundCeilInMeters(RecalculatedPoints, ...
        input_json_OPT.RFSdata.training_groud_ceil);
    smallest_distance = min(smallest_distance_on_ground,smallest_distance_for_apogees);
    if isfield(input_json_OPT.RFSdata,'margin') && smallest_distance >= input_json_OPT.RFSdata.margin 
        disp(strcat('OPTmessage: The rocket has landed within the training ground and the margin requirement (', ...
            num2str(round(input_json_OPT.RFSdata.margin)), ' m) has been fulfilled for geometry', {' '}, ...
            num2str(geometry_number), ', iteration', {' '}, num2str(specific_geometry_iter), ...
            '! The smallest distance on the ground was', {' '}, num2str(round(smallest_distance_on_ground)), ...
            ' m and for apogees', {' '}, num2str(round(smallest_distance_for_apogees)), ' m.'));
        HTML_2 = strcat(HTML_2,'<tr><td>',string(datetime),...
            '</td><td>The rocket has landed within the training ground and the margin requirement(', ...
            num2str(round(input_json_OPT.RFSdata.margin)), ' m) has been fulfilled for geometry', {' '}, ...
            num2str(geometry_number), ', iteration', {' '}, num2str(specific_geometry_iter), ...
            '! The smallest distance on the ground was', {' '}, num2str(round(smallest_distance_on_ground)), ...
            ' m and for apogees', {' '}, num2str(round(smallest_distance_for_apogees)), ' m.</td></tr>');
        app.HTML.HTMLSource = strcat (HTML_1,HTML_2{1,1},HTML_3);
        boolean_margin_requirement_fulfilled = true;
        number_last_points_in_training_ground = specific_geometry_iter;
    elseif isfield(input_json_OPT.RFSdata,'margin')
        disp(strcat('OPTmessage: The rocket has landed within the training ground and the margin requirement (', ...
            num2str(round(input_json_OPT.RFSdata.margin)), ' m) has NOT been fulfilled for geometry', {' '}, ...
            num2str(geometry_number), ', iteration', {' '}, num2str(specific_geometry_iter), ...
            '! The smallest distance on the ground was', {' '}, num2str(round(smallest_distance_on_ground)), ...
            ' m and for apogees', {' '}, num2str(round(smallest_distance_for_apogees)), ' m.'));
        HTML_2 = strcat(HTML_2,'<tr style="color:Orange;"><td>',string(datetime),...
            '</td><td>The rocket has landed within the training ground and the margin requirement(', ...
            num2str(round(input_json_OPT.RFSdata.margin)), ' m) has NOT been fulfilled for geometry', {' '}, ...
            num2str(geometry_number), ', iteration', {' '}, num2str(specific_geometry_iter), ...
            '! The smallest distance on the ground was', {' '}, num2str(round(smallest_distance_on_ground)), ...
            ' m and for apogees', {' '}, num2str(round(smallest_distance_for_apogees)), ' m.</td></tr>');
        app.HTML.HTMLSource = strcat (HTML_1,HTML_2{1,1},HTML_3);
        boolean_margin_requirement_fulfilled = false;
    else
        disp(strcat('OPTmessage: The rocket has landed within the training ground, but any margin requirement has not been declared for geometry', ...
            {' '}, num2str(geometry_number), ', iteration', {' '}, num2str(specific_geometry_iter), ...
            '! The smallest distance on the ground was', {' '}, num2str(round(smallest_distance_on_ground)), ...
            ' m and for apogees', {' '}, num2str(round(smallest_distance_for_apogees)), ' m.'));
        HTML_2 = strcat(HTML_2,'<tr><td>',string(datetime),...
            '</td><td>The rocket has landed within the training ground, but any margin requirement has not been declared for geometry', ...
            {' '}, num2str(geometry_number), ', iteration', {' '}, num2str(specific_geometry_iter), ...
            '! The smallest distance on the ground was', {' '}, num2str(round(smallest_distance_on_ground)), ...
            ' m and for apogees', {' '}, num2str(round(smallest_distance_for_apogees)), ' m.</td></tr>');
        app.HTML.HTMLSource = strcat (HTML_1,HTML_2{1,1},HTML_3);
        boolean_margin_requirement_fulfilled = true;
        number_last_points_in_training_ground = specific_geometry_iter;
    end
else
    boolean_margin_requirement_fulfilled = false;
end



temp_optimised_dimension = input_json_OPT.Geometry{geometry_number, 1}.(input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension);
% decision for shape of geometry for next iteration
if boolean_margin_requirement_fulfilled && boolean_points_in_training_ground && isfield(input_json_OPT.RFSdata,'margin_strict') ...
        && input_json_OPT.RFSdata.margin_strict
    boolean_points_in_training_ground_with_margin_requirement = true;
elseif isfield(input_json_OPT.RFSdata,'margin_strict') && input_json_OPT.RFSdata.margin_strict
    boolean_points_in_training_ground_with_margin_requirement = false;
else
    boolean_points_in_training_ground_with_margin_requirement = boolean_points_in_training_ground;
end
if strcmp(input_json_OPT.Geometry{geometry_number, 1}.type,'FunctionChannel')
    [input_json_OPT.Geometry{geometry_number, 1}.(input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension), ...
        grain_dimention_min_volume, grain_dimention_max_volume, ...
        boolean_it_is_finally_over] = BisectionForGrain(boolean_points_in_training_ground_with_margin_requirement, ...
        input_json_OPT.Geometry{geometry_number, 1}.(input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension), ...
        grain_dimention_min_volume, grain_dimention_max_volume, ...
        input_json_OPT.General.expected_relative_accuracy*input_json_OPT.Geometry{geometry_number,1}.diameter_outer, ...
        true, input_json_OPT.Geometry{geometry_number, 1}.resolution);
else
    [input_json_OPT.Geometry{geometry_number, 1}.(input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension), ...
        grain_dimention_min_volume, grain_dimention_max_volume, ...
        boolean_it_is_finally_over] = BisectionForGrain(boolean_points_in_training_ground_with_margin_requirement, ...
        input_json_OPT.Geometry{geometry_number, 1}.(input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension), ...
        grain_dimention_min_volume, grain_dimention_max_volume, ...
        input_json_OPT.General.expected_relative_accuracy*input_json_OPT.Geometry{geometry_number,1}.diameter_outer, ...
        false);
end

disp(strcat('OPTmessage: The geometry has been changed (', input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension, ...
    ':', {' '}, num2str(temp_optimised_dimension), ' mm ->', {' '}, ...
    num2str(input_json_OPT.Geometry{geometry_number, 1}.(input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension)), ...
    ' mm) for', {' '}, num2str(geometry_number),', iteration', {' '}, num2str(specific_geometry_iter), '!'));
HTML_2 = strcat(HTML_2,'<tr style="color:DodgerBlue;"><td>',string(datetime),'</td><td>The geometry has been changed (', ...
    input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension, ':', {' '}, num2str(temp_optimised_dimension), ' mm ->', ...
    {' '}, num2str(input_json_OPT.Geometry{geometry_number, 1}.(input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension)), ...
    ' mm) for', {' '}, num2str(geometry_number),', iteration', {' '}, num2str(specific_geometry_iter), '!</td></tr>');
app.HTML.HTMLSource = strcat (HTML_1,HTML_2{1,1},HTML_3);

%% geoplots
if isfield(input_json_OPT.RFSdata,'max_wind_speed')
    GenerateGeoplot(input_json_RFSsession.motion_initialization_launchpad.lat, ...
        input_json_RFSsession.motion_initialization_launchpad.long, Points_iter, ...
        input_json_txtTrainingGround, inputTrainingGroundName, ...
        input_json_OPT.General.factor_landing_points, ...
        input_json_OPT.General.factor_altitude, input_json_OPT.RFSdata.max_wind_speed, ...
        input_json_RFSsession.motion_initialization_launchpad.elevation, ...
        input_json_RFSsession.motion_initialization_launchpad.azimuth, specific_geometry_iter, ...
        input_json_OPT.RFSdata.training_groud_ceil, ...
        strcat(output_path_name_for_iteration,'\' ,OPTsimulation_title_for_RFS));
elseif isfield(input_json_OPT.RFSdata,'wind_profile_filepath')
    GenerateGeoplot(input_json_RFSsession.motion_initialization_launchpad.lat, ...
        input_json_RFSsession.motion_initialization_launchpad.long, Points_iter, ...
        input_json_txtTrainingGround, inputTrainingGroundName, ...
        input_json_OPT.General.factor_landing_points, ...
        input_json_OPT.General.factor_altitude, 'wind profile', ...
        input_json_RFSsession.motion_initialization_launchpad.elevation, ...
        input_json_RFSsession.motion_initialization_launchpad.azimuth, specific_geometry_iter, ...
        input_json_OPT.RFSdata.training_groud_ceil, ...
        strcat(output_path_name_for_iteration,'\' ,OPTsimulation_title_for_RFS));
end



% NOTE: wyczyszczenie struktur RPAT i RFS - lepiej tak?
clear Modified_Session;

disp(strcat('OPTmessage: Results and geoplot of calculations has been saved with success for the geometry', {' '}, ...
    num2str(geometry_number),', iteration', {' '}, num2str(specific_geometry_iter), '!'));
HTML_2 = strcat(HTML_2,'<tr style="color:ForestGreen;"><td>',string(datetime),...
    '</td><td>Results and geoplot of calculations has been saved with success for the geometry', {' '}, ...
    num2str(geometry_number),', iteration', {' '}, num2str(specific_geometry_iter), '!</td></tr>');
app.HTML.HTMLSource = strcat (HTML_1,HTML_2{1,1},HTML_3);


end



%% command window message after geometry type and outer loop stop (end is below)
date_and_time = strcat(output_folder_or_file_name(1:4),'-',output_folder_or_file_name(5:6),'-',output_folder_or_file_name(7:8),...
    {' '},output_folder_or_file_name(10:11),':',output_folder_or_file_name(12:13),':',output_folder_or_file_name(14:15));
if boolean_ever_were_points_in_training_ground
    disp(strcat('OPTmessage: Calculations has been completed with success! For the geometry', {' '}, ...
    num2str(geometry_number),', the iteration', {' '}, num2str(number_last_points_in_training_ground), ...
    {' '}, 'is a solution. All uncalculated possible solutions are in the interval [', num2str(grain_dimention_max_volume), ...
    ',',num2str(grain_dimention_min_volume),'].'));
    HTML_2 = strcat(HTML_2,'<tr style="color:DarkGreen;"><td>',string(datetime),...
        '</td><td>Calculations has been completed with success! For the geometry', {' '}, ...
        num2str(geometry_number),', the iteration', {' '}, num2str(number_last_points_in_training_ground), ...
        {' '}, 'is a solution. All uncalculated possible solutions are in the interval [', num2str(grain_dimention_max_volume), ...
        ',',num2str(grain_dimention_min_volume),'].</td></tr>');
    app.HTML.HTMLSource = strcat (HTML_1,HTML_2{1,1},HTML_3);
    if height(ResultsForGUITable) == 0
        ResultsForGUITable = table({date_and_time{1,1}}, {input_json_OPT.Geometry{geometry_number, 1}.type}, ...
            {input_json_OPT.Geometry{geometry_number, 1}.filename}, ...
            {input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension}, ...
            {input_json_OPT.Geometry{geometry_number, 1}.(input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension)}, ...
            {stl_pathname}, {strcat(output_path_name_for_iteration,'\' ,OPTsimulation_title_for_RFS, '.fig')});
    else
        ResultsForGUITable = [ResultsForGUITable; ...
            table({date_and_time{1,1}}, {input_json_OPT.Geometry{geometry_number, 1}.type}, ...
            {input_json_OPT.Geometry{geometry_number, 1}.filename}, ...
            {input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension}, ...
            {input_json_OPT.Geometry{geometry_number, 1}.(input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension)}, ...
            {stl_pathname}, {strcat(output_path_name_for_iteration,'\' ,OPTsimulation_title_for_RFS, '.fig')})];
    end
    if run_by_GUI
        if height(app.UITableResults.Data) == 0
            % date_and_time, geometry_type, name, opt_dim, opt_dim_value, geometry_path, geoplot_path
            app.UITableResults.Data = table({date_and_time{1,1}}, {input_json_OPT.Geometry{geometry_number, 1}.type}, ...
                {input_json_OPT.Geometry{geometry_number, 1}.filename}, ...
                {input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension}, ...
                {input_json_OPT.Geometry{geometry_number, 1}.(input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension)}, ...
                {stl_pathname}, {strcat(output_path_name_for_iteration,'\' ,OPTsimulation_title_for_RFS, '.fig')});
        else
            app.UITableResults.Data = [app.UITableResults.Data; ...
                table({date_and_time{1,1}}, {input_json_OPT.Geometry{geometry_number, 1}.type}, ...
                {input_json_OPT.Geometry{geometry_number, 1}.filename}, ...
                {input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension}, ...
                {input_json_OPT.Geometry{geometry_number, 1}.(input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension)}, ...
                {stl_pathname}, {strcat(output_path_name_for_iteration,'\' ,OPTsimulation_title_for_RFS, '.fig')})];
        end
    end
else
    disp(strcat('OPTmessage: Calculations has been completed without succes. For the chosen fuel and geometry', ...
    {' '}, num2str(geometry_number), ', the rocket would not fit in the training ground.'));
    HTML_2 = strcat(HTML_2,'<tr style="color:FireBrick;"><td>',string(datetime),...
        '</td><td>Calculations has been completed without succes. For the chosen fuel and geometry', ...
        {' '}, num2str(geometry_number), ', the rocket would not fit in the training ground.</td></tr>');
    app.HTML.HTMLSource = strcat (HTML_1,HTML_2{1,1},HTML_3);
    if height(ResultsForGUITable) == 0
        ResultsForGUITable = table({date_and_time{1,1}}, {input_json_OPT.Geometry{geometry_number, 1}.type}, ...
            {input_json_OPT.Geometry{geometry_number, 1}.filename}, ...
            {input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension}, ...
            {'Unsuccesful calculation'}, {'Unsuccesful calculation'}, {'Unsuccesful calculation'});
    else
        ResultsForGUITable = [ResultsForGUITable; ...
            table({date_and_time{1,1}}, {input_json_OPT.Geometry{geometry_number, 1}.type}, ...
            {input_json_OPT.Geometry{geometry_number, 1}.filename}, ...
            {input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension}, ...
            {'Unsuccesful calculation'}, {'Unsuccesful calculation'}, {'Unsuccesful calculation'})];
    end
    if run_by_GUI
        if height(app.UITableResults.Data) == 0
            % date_and_time, geometry_type, name, opt_dim, opt_dim_value, geometry_path, geoplot_path
            app.UITableResults.Data = table({date_and_time{1,1}}, {input_json_OPT.Geometry{geometry_number, 1}.type}, ...
                {input_json_OPT.Geometry{geometry_number, 1}.filename}, ...
                {input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension}, ...
                {'Unsuccesful calculation'}, {'Unsuccesful calculation'}, {'Unsuccesful calculation'});
        else
            app.UITableResults.Data = [app.UITableResults.Data; ...
                table({date_and_time{1,1}}, {input_json_OPT.Geometry{geometry_number, 1}.type}, ...
                {input_json_OPT.Geometry{geometry_number, 1}.filename}, ...
                {input_json_OPT.Geometry{geometry_number, 1}.optimised_dimension}, ...
                {'Unsuccesful calculation'}, {'Unsuccesful calculation'}, {'Unsuccesful calculation'})];
        end
    end
end



end
ResultsForGUITable.Properties.VariableNames = ["Date and time","Geometry type","Name","Optimised dimension",...
    "Optimised dimension final value","Final geometry path","Final geoplot path"];
save(fullfile(output_path_name, [output_folder_or_file_name '_ResultsSummary.mat']),'ResultsForGUITable');
FinalHtml = strcat (HTML_1,HTML_2{1,1},HTML_3);
save(fullfile(output_path_name, [output_folder_or_file_name '_Messages.mat']),'FinalHtml');
diary off;
end


%% left to do:
% test in RFS for all wind-cases                                                V
    % front and no wind case has problem in object of stg1, not stg1&2&3
    % problem was empty mu XD
% geoplot                                                                       V
% messages in command window and .log file                                      V
% GUI                                                                           V
% modified MainOPT to make running this function in GUI if possible             V
% test in OPT for other RFS and RPAT setting (better calculation precision?)    .
% Optional:
% beautiful names in GUI instead of variable names                              V
% descriptions of functions in files                                            .
% auto-turn off after calculations, also in GUI as check box                    .
% change all '\' on '/'                                                         .
% change all 'yes' in Geometry on true                                          .
% sprawdzenie i usunięcie 'NOTE'                                                .