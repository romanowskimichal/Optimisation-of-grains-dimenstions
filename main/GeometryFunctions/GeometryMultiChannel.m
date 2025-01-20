function [geometryy]=GeometryMultiChannel(length_cyl,diameter,channel_number,channel_diameter,channel_ring_diameter,resolution)
    if (exist("resolution",'var'))&&~isnan(resolution)
        angle=linspace(0,2*pi,resolution)';
    else
        angle=linspace(0,2*pi)';
    end
    angle(end)=[];
    geometryy.Points=[zeros(length(angle),1),diameter/2*sin(angle),diameter/2*cos(angle);length_cyl*ones(length(angle),1),diameter/2*sin(angle),diameter/2*cos(angle)];
    geometry1=[zeros(length(angle),1),channel_diameter/2*sin(angle),channel_diameter/2*cos(angle);length_cyl*ones(length(angle),1),channel_diameter/2*sin(angle),channel_diameter/2*cos(angle)];
    geometryy.edge{1,1} = 1:length(angle);
    geometryy.edge{2,1} = (length(angle)+1):(2*length(angle));
    geometryy.surface{1,1} = 1;
    geometryy.surface{2,1} = [1,2];
    geometryy.surface{3,1} = 2;
    for i=1:channel_number
        geometryy.Points=[geometryy.Points;geometry1+[0,channel_ring_diameter/2*sin(i*2*pi/channel_number),channel_ring_diameter/2*cos(i*2*pi/channel_number)]];
        geometryy.edge{height(geometryy.edge)+1,1} = ((2*i)*length(angle)+1):((2*i+1)*length(angle));
        geometryy.edge{height(geometryy.edge)+1,1} = ((2*i+1)*length(angle)+1):((2*i+2)*length(angle));
        geometryy.surface{1,1} = [geometryy.surface{1,1},2*i+1];
        geometryy.surface{3,1} = [geometryy.surface{3,1},2*i+2];
        geometryy.surface{height(geometryy.surface)+1,1} = [2*i+1,2*i+2];
    end
    geometryy = ConnectivityListCreation(geometryy);
end