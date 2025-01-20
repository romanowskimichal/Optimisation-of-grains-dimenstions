function Simulation_Results = MainRFSMod(session_string, Modified_Rocket, Modified_Session, ...
    filtered_results, output_path_name, simulation_title)
% MAIN Execute multiobject rocket flight simulation

%% Perform tasks essential for correct operation of the program
% Clear all variables in the workspace with some exceptions
% Close all windows
close all; clearvars -except session_string Modified_Rocket Modified_Session filtered_results output_path_name simulation_title

% % Add folders needed by the program to work
% path_folders = {genpath('main')};
% 
% path_folders = split(path_folders, ';'); %Do not add subfolders of OutputData to path
% path_folders = path_folders(~contains(path_folders,'OutputData') | endsWith(path_folders,'OutputData')); 
% 
% current_file_name = mfilename('fullpath');
% [path_string, ~, ~] = fileparts(current_file_name);
% 
% for i = 1:numel(path_folders)
%     addpath(fullfile(path_string, path_folders{i}));
% end

% Check if the simulation was run using a script
if exist('Modified_Rocket', 'var') || exist('Modified_Session', 'var')
    simulations_in_a_loop = true;
else
    simulations_in_a_loop = false;
    number_of_iterations = 1;
    Modified_Rocket = []; %% these fields have to exist for parfor to not throw an error
    Modified_Session = [];
    main_simulation_output_folder=[];
end
if ~exist('filtered_results', 'var')
    filtered_results={};
end

% Read session file if session_string does not exist or is empty
if ~exist('session_string', 'var') || isempty(session_string)
    [sessionFileName, sessionPath, ~] = uigetfile(fullfile('main/InputData/Sessions','*.RFSsession'),...
        'Select session file');
    sessionFullFilename = fullfile(sessionPath,sessionFileName);
    [~, session_name, ~] = fileparts(sessionFullFilename);
    session_string = fileread(sessionFullFilename);
end

% Create empty structures for compatibility
% Display a warning if structures passed as an input have different size
if simulations_in_a_loop
    if ~exist('Modified_Rocket', 'var')
        Modified_Rocket = [];
    end
    if ~exist('Modified_Session', 'var')
        Modified_Session = [];
    end


    number_of_iterations = max(size(Modified_Rocket, 2), size(Modified_Session, 2));
    if ~isempty(Modified_Rocket) && ~isempty(Modified_Session)
        if size(Modified_Rocket, 2) ~= size(Modified_Session, 2)
            warning('Modified structures have different size');
        end
    end
end

%    if ~exist('filtered_results', 'var')
%         filtered_results = [];
%     end
%% Load data, copy and save files and perform simulation(s)
% Load session data
[Loaded_Objects, Loaded_Environment, Loaded_Simulation, Loaded_Settings] = LoadSession(session_string,...
    [], [], []);

if ~exist('session_name', 'var')
    Loaded_Settings.session_name = simulation_title;
    session_name = Loaded_Settings.session_name;
end

% Create output folder
% Copy input files to corresponding output subfolder
% Save data of multiple cases if Main was run from a script

if Loaded_Settings.generate_txt_files == true || Loaded_Settings.generate_mat_files == true
    if exist('sessionFullFilename', 'var')
        Loaded_Simulation.session_file_path = sessionFullFilename;
    else
        Loaded_Simulation.session_name = session_name;
        Loaded_Simulation.session_string = session_string;
    end
    % simulation_title = AskForSimulationTitle(session_name);
    if simulations_in_a_loop == false
        Loaded_Simulation.SimulationOutputPathName = CreateOutputFolder(simulation_title, [], []);
        CopyInputData(Loaded_Simulation, Loaded_Environment, Loaded_Objects);
    else
        % main_simulation_output_folder = CreateOutputFolder(simulation_title, output_path_name, []);
        main_simulation_output_folder = CreateOutputFolderMod(simulation_title, output_path_name, []);
        Loaded_Simulation.SimulationOutputPathName = main_simulation_output_folder;
        CopyInputData(Loaded_Simulation, Loaded_Environment, Loaded_Objects);
    end
    if simulations_in_a_loop
        if ~isempty(Modified_Rocket)
            save(fullfile(main_simulation_output_folder,'Modified_Rocket.mat'), 'Modified_Rocket');
        end
        if ~isempty(Modified_Session)
            save(fullfile(main_simulation_output_folder,'Modified_Session.mat'), 'Modified_Session');
        end
    end
end

% create diary file
if simulation_title == ""
    diary(fullfile(Loaded_Simulation.SimulationOutputPathName,[session_name '.log']));
else
    diary(fullfile(Loaded_Simulation.SimulationOutputPathName, [simulation_title '.log']));
end

% WYWAL TEN KOMENTARZ I ZAKOMENTOWANIE PONIŻEJ
% %Start parallel pool
% [Parallel_Pool,number_of_workers] = StartParallelPool(Loaded_Settings);


% Prealocate memory for the results cell array
Simulation_Results = cell(number_of_iterations, 1);

% Loop in which variables get replaced with corresponding values (if Main
% was run from a script) and simulation is performed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To conduct simulations in parallel:
% - specify the number of cores in session file by adding: "number_of_workers":n
%   - to conduct in series set it to 0
% - specify the number of iterations in script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% WYWAL TEN KOMENTARZ I ZAKOMENTOWANIE PONIŻEJ
% if number_of_workers>0
%     display_events=false;
% else
    display_events=true;
% end

starting_time=tic();
iteration_starting_time=uint64.empty(0,number_of_iterations);
% WYWAL TEN KOMENTARZ I ZAKOMENTOWANIE PONIŻEJ
% parfor (iteration = 1:number_of_iterations, Parallel_Pool)
for iteration = 1:number_of_iterations
    iteration_starting_time(iteration)=tic();
    if simulations_in_a_loop==true
        [Objects, Environment, Simulation, Settings] = LoadSession(session_string,...
            Modified_Rocket, Modified_Session, iteration);
        fprintf('Starting case %d/%d\n', iteration, number_of_iterations);
        Simulation.SimulationOutputPathName = CreateOutputFolder(simulation_title,...
            main_simulation_output_folder, iteration);
    else
        Objects=Loaded_Objects;
        Environment=Loaded_Environment;
        Simulation=Loaded_Simulation;
        Settings=Loaded_Settings;
    end


    Settings.filtered_results=filtered_results;
    Settings.display_events=display_events;
    [Simulation_Results{iteration}, OutputFilesList] = ExecuteRFS(Objects, Environment,...
        Simulation, Settings);
    Simulation.OutputFilesList = OutputFilesList;
    iteration_simulation_duration = toc(iteration_starting_time(iteration));
    total_simulation_time = toc(starting_time);

    fprintf('Iteration %d took %f seconds. Total simulation time is %f seconds.\n', iteration,iteration_simulation_duration,total_simulation_time);
     if Settings.generate_txt_files == true || Settings.generate_mat_files==true
        post_process_start_time=tic;
        fprintf("Starting postprocessing of case %d\n",iteration);

        PostprocessOutput(Objects, Simulation, Settings, simulation_title);
        fprintf("Postprocessing of case %d took %f seconds\n",iteration,toc(post_process_start_time));
    end
    fprintf("Postprocessing of case %d/%d has completed simulating and processing\n",iteration,number_of_iterations);
end

% WYWAL TEN KOMENTARZ I ZAKOMENTOWANIE PONIŻEJ
% Parallel_Pool=gcp('nocreate');
% delete(Parallel_Pool);

rfs_execution_time = toc(starting_time);
fprintf('Elapsed RFS execution time is %f seconds.\n', rfs_execution_time);

%% Shut down the computer if corresponding option was chosen in the GUI
if Loaded_Settings.computer_shutdown == true
    archstr = computer('arch');
    if strcmp(archstr, 'win64') %Windows
        system('shutdown -s');
    elseif strcmp(archstr, 'glnxa64') %Linux
        system('shutdown');
    end
end

diary off;
end