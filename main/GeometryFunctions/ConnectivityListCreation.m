function [geometryyy]=ConnectivityListCreation(geometryyy)
    geometryyy.ConnectivityList=[];    
    for i=1:height(geometryyy.surface)
        %memory allocation
        pointslist_height=0;
        for j=1:length(geometryyy.surface{i,1}) 
            pointslist_height=pointslist_height+length(geometryyy.edge{geometryyy.surface{i,1}(j),1});
        end
        pointslist=zeros(pointslist_height,4);
        edgeconnectionlist=zeros(pointslist_height,2);
        current_height=1;
        for j=1:length(geometryyy.surface{i,1}) 
            pointslist(current_height:current_height+length(geometryyy.edge{geometryyy.surface{i,1}(j),1})-1,:)=...
                [geometryyy.Points(geometryyy.edge{geometryyy.surface{i,1}(j),1},:),geometryyy.edge{geometryyy.surface{i,1}(j),1}'];
            edgeconnectionlist(current_height:current_height+length(geometryyy.edge{geometryyy.surface{i,1}(j),1})-1,:)=...
                [(current_height:current_height+length(geometryyy.edge{geometryyy.surface{i,1}(j),1})-2)',...
                (current_height+1:current_height+length(geometryyy.edge{geometryyy.surface{i,1}(j),1})-1)';...
                current_height+length(geometryyy.edge{geometryyy.surface{i,1}(j),1})-1, current_height];
            current_height=current_height+length(geometryyy.edge{geometryyy.surface{i,1}(j),1});
        end
        %without memory allocation
        % for j=1:length(geometryy.surface{i,1}) 
        %     pointslist=[pointslist;geometryyy.Points(geometryyy.edge{geometry.surface{i,1}(j),1}),geometryyy.edge{geometry.surface{i,1}(j),1}];
        % end
        %checking if surface is flat
        if (max(pointslist(:,1))==min(pointslist(:,1)) || max(pointslist(:,2))==min(pointslist(:,2)) || max(pointslist(:,3))==min(pointslist(:,3)))
            %flat surface
            if max(pointslist(:,1))==min(pointslist(:,1))
                CLtemp=delaunayTriangulation(pointslist(:,2:3),edgeconnectionlist); %tu muszę jakośdopisać listę numerów kolejnych krawedzi; nowy array?
                flat_height=max(pointslist(:,1));
                minimal_height=min(geometryyy.Points(:,1));
                flat_normal_direction=1;
            elseif max(pointslist(:,2))==min(pointslist(:,2))
                CLtemp=delaunayTriangulation(pointslist(:,1),pointslist(:,3),edgeconnectionlist);
                flat_height=max(pointslist(:,2));
                minimal_height=min(geometryyy.Points(:,2));
                flat_normal_direction=2;
            elseif max(pointslist(:,3))==min(pointslist(:,3))
                CLtemp=delaunayTriangulation(pointslist(:,1:2),edgeconnectionlist);
                flat_height=max(pointslist(:,3));
                minimal_height=min(geometryyy.Points(:,3));
                flat_normal_direction=3;
            end
            CLtempInt = isInterior(CLtemp);
            %changing local order numbers on global order numbers
            CLtemp2=zeros(height(CLtemp.ConnectivityList),3);
            for k=1:height(CLtemp.ConnectivityList)
                CLtemp2(k,:)=pointslist(CLtemp.ConnectivityList(k,:),4);
            end
            %changing columns for a proper triangles' normals (bottom flat surface)
            if (flat_height==minimal_height) 
                CLtempCopiedColumn=CLtemp2(:,2);
                CLtemp2(:,2)=CLtemp2(:,3);
                CLtemp2(:,3)=CLtempCopiedColumn;
            end
            geometryyy.ConnectivityList=[geometryyy.ConnectivityList;CLtemp2(CLtempInt,:)];
        % elseif i==2 for surfaces sorted in original order (1 - height=0, 2 - outer, 3 - height=length_cyl, ...)
        elseif (flat_normal_direction==1 && max(max(geometryyy.Points(:,2)),max(geometryyy.Points(:,3)))==sqrt(pointslist(1,2)^2+pointslist(1,3)^2) ||...
                flat_normal_direction==2 && max(max(geometryyy.Points(:,1)),max(geometryyy.Points(:,3)))==sqrt(pointslist(1,1)^2+pointslist(1,3)^2) ||...
                flat_normal_direction==3 && max(max(geometryyy.Points(:,1)),max(geometryyy.Points(:,2)))==sqrt(pointslist(1,1)^2+pointslist(1,2)^2))
            %on assumption that always points start from angle 0 deg, 90 deg... and so the condition is fulfilled
            %nonflat surface outer
            for k=1:height(pointslist)/2-1
                geometryyy.ConnectivityList=[geometryyy.ConnectivityList;...
                    pointslist(k,4), pointslist(k+height(pointslist)/2,4), pointslist(k+height(pointslist)/2+1,4);
                    pointslist(k,4), pointslist(k+height(pointslist)/2+1,4), pointslist(k+1,4)];
            end
            geometryyy.ConnectivityList=[geometryyy.ConnectivityList;...
                    pointslist(height(pointslist)/2,4), pointslist(height(pointslist),4), pointslist(height(pointslist)/2+1,4);
                    pointslist(height(pointslist)/2,4), pointslist(height(pointslist)/2+1,4), pointslist(1,4)];
        else
            %nonflat surface inner
            for k=1:height(pointslist)/2-1
                geometryyy.ConnectivityList=[geometryyy.ConnectivityList;...
                    pointslist(k,4), pointslist(k+height(pointslist)/2+1,4), pointslist(k+height(pointslist)/2,4);
                    pointslist(k,4), pointslist(k+1,4), pointslist(k+height(pointslist)/2+1,4)];
            end
            geometryyy.ConnectivityList=[geometryyy.ConnectivityList;...
                    pointslist(height(pointslist)/2,4), pointslist(height(pointslist)/2+1,4), pointslist(height(pointslist),4);
                    pointslist(height(pointslist)/2,4), pointslist(1,4), pointslist(height(pointslist)/2+1,4)];
        end
    end
end