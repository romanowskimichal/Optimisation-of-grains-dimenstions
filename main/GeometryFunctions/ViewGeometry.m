function ViewGeometry(geometry,transparency_surfaces,scale_normals)
    %central points of triangulation matrix
    CP=(geometry.Points(geometry.ConnectivityList(:,1),:)+geometry.Points(geometry.ConnectivityList(:,2),:)+...
            geometry.Points(geometry.ConnectivityList(:,3),:))/3;
    %normal vectors matrix
    V1=geometry.Points(geometry.ConnectivityList(:,1),:)-geometry.Points(geometry.ConnectivityList(:,2),:);
    V2=geometry.Points(geometry.ConnectivityList(:,1),:)-geometry.Points(geometry.ConnectivityList(:,3),:);
    NV=cross(V1,V2,2);
    NV=NV./sqrt((NV(:,1).^2+NV(:,2).^2+NV(:,3).^2));
    figure;
    trisurf(geometry.ConnectivityList,geometry.Points(:,1),geometry.Points(:,2),geometry.Points(:,3),...
        'FaceColor','cyan','FaceAlpha',transparency_surfaces);
    axis equal
    if (exist('scale_normals', 'var'))
        hold on
        quiver3(CP(:,1),CP(:,2),CP(:,3),NV(:,1),NV(:,2),NV(:,3),scale_normals,'color','r');
    end
end