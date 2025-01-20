function [geometryy]=GeometryTube(length_cyl,diameter,diameter_inner,resolution)
    if (exist("resolution",'var'))&&~isnan(resolution)
        angle=linspace(0,2*pi,resolution)';
    else
        angle=linspace(0,2*pi)';
    end
    angle(end)=[];
    geometryy.Points=[zeros(length(angle),1),diameter/2*sin(angle),diameter/2*cos(angle);length_cyl*ones(length(angle),1),diameter/2*sin(angle),diameter/2*cos(angle)];
    geometry1=[zeros(length(angle),1),diameter_inner/2*sin(angle),diameter_inner/2*cos(angle);length_cyl*ones(length(angle),1),diameter_inner/2*sin(angle),diameter_inner/2*cos(angle)];
    geometryy.Points=[geometryy.Points;geometry1];
    geometryy.edge = {1:length(angle);(length(angle)+1):(2*length(angle));(2*length(angle)+1):(3*length(angle));(3*length(angle)+1):(4*length(angle))};
    geometryy.surface = {[1,3];[1,2];[2,4];[3,4]};
    geometryy = ConnectivityListCreation(geometryy);
end