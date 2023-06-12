function [ coordinate_transform, velocity_transform ] = transect_coordinates
%transect_coordinates - define coordinate transformation to rotate into along- 
% and across-track coordinates
%
% Syntax [ coordinate_transform, velocity_transform ] = transect_coordinates
%
% Defines a pair of functions to convert lon,lat to xt,yt, the along- and
% across-track coordinates in km, and rotate velocities into the same
% coordinate system. The along-track coordinate approximately follows 
% Aries' ship track.

arguments (Output)
    coordinate_transform function_handle
    velocity_transform function_handle
end

    % filepath relative to this file
    relative_filepath = "../../metadata/transect_coordinates.json";
    % get directory of this function
    [directory,~,~] = fileparts(mfilename('fullpath'));
    % construct full filepath
    filepath = fullfile(directory,relative_filepath);
    
    % read in transform parameters
    fid = fopen(filepath,'r','n','UTF-8'); 
    tp_char = fread(fid,[1,inf],'char=>char');
    fclose(fid);
    tp = jsondecode(tp_char);

    % define transform functions
    function [xt,yt] = coordinate_transform_function(lon,lat)

        x = (lon - tp.lon0).*tp.lon2km;
        y = (lat - tp.lat0).*tp.lat2km;
        xt = x.*cos(tp.theta) + y.*sin(tp.theta);
        yt = -x.*sin(tp.theta) + y.*cos(tp.theta);
    end

    function [ut,vt] = velocity_transform_function(u,v)

        ut = u.*cos(tp.theta) + v.*sin(tp.theta);
        vt = -u.*sin(tp.theta) + v.*cos(tp.theta);
    end

    coordinate_transform = @coordinate_transform_function;
    velocity_transform = @velocity_transform_function;
end