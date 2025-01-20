function [output_path_name, outputfoldername] = CreateOutputFolderOPT(simulation_title)
    outputfoldername = datestr(now,'yyyymmdd_HHMMSS');
    if ~strcmp(simulation_title,'')
        outputfoldername = [outputfoldername,'_',simulation_title];
    end
    output_path_name = strcat('main\Output\',outputfoldername);  
end