function [geometryy]=GeometryCylinder(length_cyl,diameter,resolution)
    if (exist("resolution",'var'))&&~isnan(resolution)
        angle=linspace(0,2*pi,resolution)';
    else
        angle=linspace(0,2*pi)';
    end
    angle(end)=[];
    geometryy.Points=[zeros(length(angle),1),diameter/2*sin(angle),diameter/2*cos(angle);length_cyl*ones(length(angle),1),diameter/2*sin(angle),diameter/2*cos(angle)];
    geometryy.edge = {1:length(angle);(length(angle)+1):(2*length(angle))};
    geometryy.surface = {1;[1,2];2};
    geometryy = ConnectivityListCreation(geometryy);
end