function outputpathname = CreateOutputFolderMod(SimulationTitle, SimulationOutputPathName, iteration)

outputfoldername = datestr(now,'yyyymmdd_HHMMSS');

if isempty(SimulationOutputPathName)
    if ~isempty(SimulationTitle)
        outputfoldername = [outputfoldername,' ',SimulationTitle];
    end
else
    outputfoldername = ['Case ', num2str(iteration)];
end

if isempty(SimulationOutputPathName)
    outputpathname = strcat('./main/OutputData/', outputfoldername);
else
    % outputpathname = strcat(SimulationOutputPathName, '/', outputfoldername);
    outputpathname = SimulationOutputPathName;
end

if exist(outputpathname,'dir')
    % error(['Output folder ''' outputpathname ''' already exists!']);
    warning(['Output folder ''' outputpathname ''' already exists!']);
else
    mkdir(outputpathname);
end

end