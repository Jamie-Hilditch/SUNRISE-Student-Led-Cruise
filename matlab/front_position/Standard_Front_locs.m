%% PS Load in point Sur data and split by section
PS_das_file = '/Users/Devon/Library/CloudStorage/GoogleDrive-dnorthco@ucsd.edu/Shared drives/NIW_GoM/field_2022/data/PointSur/Platform/PS/ShipDas/met.nc';
ctd = struct();
ctd.lon = ncread(PS_das_file,'lon');
ctd.lat = ncread(PS_das_file,'lat');
ctd.time = ncread(PS_das_file,'t')/86400+datenum(1970,1,1);
ctd.temp = ncread(PS_das_file,'Temp');
ctd.sal = ncread(PS_das_file,'SP');
fid = fopen('/Users/Devon/Library/CloudStorage/GoogleDrive-dnorthco@ucsd.edu/Shared drives/NIW_GoM/field_2022/data/PointSur/code/section/PS_section_definition.csv');
C = textscan(fid,'%s %s %s %s %s %s %s %s','Delimiter',',','HeaderLines',1);
fclose(fid);

% Get section start and end times
startdate = datenum(C{4}(1:end-1),'yyyy-mm-dd HH:MM');
enddate = datenum(C{5}(1:end-1),'yyyy-mm-dd HH:MM');
type = C{2};inds = find(contains(type,'Student Cruise'));

% Calulate along and cross track distance using Jamie's formula and the PS
% track
lon_sections = ctd.lon(ctd.time>startdate(inds(1)) & ctd.time<enddate(inds(end-3)));
lat_sections = ctd.lat(ctd.time>startdate(inds(1)) & ctd.time<enddate(inds(end-3)));
p = polyfit(lon_sections,lat_sections,1);
lon0 = -92.3;
lat0 = p(2) + p(1)*lon0;
lat2km = 111000;lon2km = 111000*cosd(lat0);
theta = atan(p(1)*lat2km/lon2km);
ctd.x = (ctd.lon-lon0)*lon2km;ctd.y=(ctd.lat-lat0)*lat2km;
ctd.xt = ctd.x*cos(theta) + ctd.y*sin(theta);
ctd.yt = -ctd.x*sin(theta) + ctd.y*cos(theta);

% calulate salinity derivitive
ctd.d_sal = smoothdata((diffdiff(ctd.sal,1)./diffdiff(ctd.xt,1)),'gaussian',250);

% Split flowthrough data by transect
ctd_split = struct();fn = fieldnames(ctd);i=1;
for n = inds'
    mask = ctd.time>startdate(n) & ctd.time<enddate(n);
    ctd_split(i).starttime = startdate(n);
    ctd_split(i).endtime = enddate(n);

    for m = 1:length(fn)
        ctd_split(i).(fn{m}) = ctd.(fn{m})(mask);
    end
    
    % Find salinity closest to 28.97 psu, corresponds to front salinity
    % for the first half of the student cruise
    front_sal = abs(smoothdata(ctd_split(i).sal,'gaussian',200)-28.97);
    [~,ctd_split(i).psu29_inds] = findpeaks(-front_sal,'MinPeakHeight',-0.005);
    
    % Find largest negative and positive salinity gradient in each section,
    % this corresponds to the location of the two fronts
    front_check_sal = ctd_split(i).d_sal;
    front_check_sal(1:200) = NaN;front_check_sal(end-200:end)=NaN;
    [~,ctd_split(i).front_ind_neg] = min(front_check_sal);
    [~,ctd_split(i).front_ind_pos] = max(front_check_sal);

    i=i+1;
end

% save ctd_split varible
save_name = ['ctd_split_PS'];
eval([save_name '=ctd_split;']);
ctd_PS = ctd;

%% PE Load in Pelican data and split by section
PE_das_file = '/Users/Devon/Library/CloudStorage/GoogleDrive-dnorthco@ucsd.edu/Shared drives/NIW_GoM/field_2022/data/Pelican/PE22_31_Shearman/data/Platform/PE/ShipDas/met.nc';
ctd = struct();
ctd.lon = ncread(PE_das_file,'lon');
ctd.lat = ncread(PE_das_file,'lat');
ctd.time = ncread(PE_das_file,'t')/86400+datenum(1970,1,1);
ctd.temp = ncread(PE_das_file,'Temp');
ctd.sal = ncread(PE_das_file,'SP');

% Calulate along and cross track distance using Jamie's formula and the PS
% track
ctd.x = (ctd.lon-lon0)*lon2km;ctd.y=(ctd.lat-lat0)*lat2km;
ctd.xt = ctd.x*cos(theta) + ctd.y*sin(theta);
ctd.yt = -ctd.x*sin(theta) + ctd.y*cos(theta);

% calulate salinity derivitive
ctd.d_sal = smoothdata((diffdiff(ctd.sal,1)./diffdiff(ctd.xt,1)),'gaussian',250);

% Split flowthrough data by transect
ctd_split = struct();fn = fieldnames(ctd);i=1;
for n = inds'
    mask = ctd.time>startdate(n) & ctd.time<enddate(n);
    ctd_split(i).starttime = startdate(n);
    ctd_split(i).endtime = enddate(n);

    for m = 1:length(fn)
        ctd_split(i).(fn{m}) = ctd.(fn{m})(mask);
    end
    
    % Find salinity closest to 28.97 psu, corresponds to front salinity
    % for the first half of the student cruise
    front_sal = abs(smoothdata(ctd_split(i).sal,'gaussian',200)-28.97);
    [~,ctd_split(i).front_inds] = findpeaks(-front_sal,'MinPeakHeight',-0.005);
    
    % Find largest negative and positive salinity gradient in each section,
    % this corresponds to the location of the two fronts
    front_check_sal = ctd_split(i).d_sal;
    front_check_sal(1:200) = NaN;front_check_sal(end-200:end)=NaN;
    [~,ctd_split(i).front_ind_neg] = min(front_check_sal);
    [~,ctd_split(i).front_ind_pos] = max(front_check_sal);
    
    i=i+1;
end

save_name = 'ctd_split_PE';
eval([save_name '=ctd_split;']);
ctd_PE = ctd;

%% Rhibs Load in rhib data and split by section
rhibs = {'Aries','Polly'};
for rhib=rhibs;rhib=rhib{:};
    load(['/Users/Devon/Documents/GradSchool/SunrisePaper/' rhib 'Flowthrough.mat'])
    ctd.salinity = [nan(50,1);ctd.salinity;nan(49,1)];
    
    % Calulate along and cross track distance using Jamie's formula and the PS
    % track
    ctd.x = (ctd.lon-lon0)*lon2km;ctd.y=(ctd.lat-lat0)*lat2km;
    ctd.xt = ctd.x*cos(theta) + ctd.y*sin(theta);
    ctd.yt = -ctd.x*sin(theta) + ctd.y*cos(theta);
    
    % take salinity derivitive
    ctd.d_sal = smoothdata((diffdiff(ctd.salinity,1)./diffdiff(ctd.xt,1)),'gaussian',1500);

    ctd_split = struct();fn = fieldnames(ctd);i=1;
    for n = inds'
        mask = datenum(ctd.time)>startdate(n) & datenum(ctd.time)<enddate(n);
        ctd_split(i).starttime = startdate(n);
        ctd_split(i).endtime = enddate(n);
        
        for m = 1:length(fn)
            ctd_split(i).(fn{m}) = ctd.(fn{m})(mask);
        end
        
        % Find salinity closest to 28.97 psu, corresponds to front salinity
        % for the first half of the student cruise
        front_sal = abs(smoothdata(ctd_split(i).salinity,'gaussian',1200)-28.97);
        if ~isempty(front_sal)
            [~,ctd_split(i).front_inds] = findpeaks(-front_sal,'MinPeakHeight',-0.005);
        else
            ctd_split(i).front_inds = [];
        end
        
        % Find largest negative and positive salinity gradient in each section,
        % this corresponds to the location of the two fronts
        front_check_sal = ctd_split(i).d_sal;
        front_check_sal(1:1500) = NaN;front_check_sal(end-1499:end)=NaN;
        [~,ctd_split(i).front_ind_neg] = min(front_check_sal);
        [~,ctd_split(i).front_ind_pos] = max(front_check_sal);
    
        i=i+1;
    end

    save_name = ['ctd_split_' rhib];
    eval([save_name '=ctd_split;']);
    save_name = ['ctd_' rhib];
    eval([save_name '=ctd;']);
end

% Manually defined list of good front locations
fit_inds_pos = cell(15,1);
fit_inds_neg = cell(15,1);
fit_inds_pos{15}=[];fit_inds_pos{14}=[1,4];fit_inds_pos{13}=[1,3,4];fit_inds_pos{12}=[1,3,4];
fit_inds_pos{11}=[];fit_inds_pos{10}=[1,3,4];fit_inds_pos{9}=[1,3,4];fit_inds_pos{8}=[1,3,4];
fit_inds_pos{7}=[1,2,3,4];fit_inds_pos{6}=[1,2,3,4];fit_inds_pos{5}=[1,2,3,4];fit_inds_pos{4}=[1,2,3];
fit_inds_pos{3}=[2,3,4];fit_inds_pos{2}=[];fit_inds_pos{1}=[];

fit_inds_neg{15}=[];fit_inds_neg{14}=[1,3];fit_inds_neg{13}=[1,3,4];fit_inds_neg{12}=[1,4];
fit_inds_neg{11}=[1,4];fit_inds_neg{10}=[1,3,4];fit_inds_neg{9}=[1,3,4];fit_inds_neg{8}=[1,2,3,4];
fit_inds_neg{7}=[1,2,3,4];fit_inds_neg{6}=[1,2,3,4];fit_inds_neg{5}=[1,2,4];fit_inds_neg{4}=[1,2,3];
fit_inds_neg{3}=[1,2,3,4];fit_inds_neg{2}=[1,2,3];fit_inds_neg{1}=[1,2,3,4];

% Sort into a structre. Each row is a front crossing, columns are as
% follows:
% [time,along track position,cross track position,longitude,latitude,good location mask]
front_position = struct();
assets = {'PS','PE','Aries','Polly'};
for n = 1:15
    a_num = 1;
    for a=assets;a=a{:};
        eval(['front_position.(a).positive(n,:) =' ...
              '[datenum(ctd_split_' a '(n).time(ctd_split_' a '(n).front_ind_pos)),'...
               'ctd_split_' a '(n).xt(ctd_split_' a '(n).front_ind_pos),'...
               'ctd_split_' a '(n).yt(ctd_split_' a '(n).front_ind_pos),'...
               'ctd_split_' a '(n).lon(ctd_split_' a '(n).front_ind_pos),'...
               'ctd_split_' a '(n).lat(ctd_split_' a '(n).front_ind_pos),0];']);
        eval(['front_position.(a).negative(n,:) =' ...
              '[datenum(ctd_split_' a '(n).time(ctd_split_' a '(n).front_ind_neg)),'...
               'ctd_split_' a '(n).xt(ctd_split_' a '(n).front_ind_neg),'...
               'ctd_split_' a '(n).yt(ctd_split_' a '(n).front_ind_neg),'...
               'ctd_split_' a '(n).lon(ctd_split_' a '(n).front_ind_neg),'...
               'ctd_split_' a '(n).lat(ctd_split_' a '(n).front_ind_neg),0];']);
       if sum(fit_inds_pos{n}==a_num)~=0
            front_position.(a).positive(n,6) = 1;
       end
       if sum(fit_inds_neg{n}==a_num)~=0
            front_position.(a).negative(n,6) = 1;
       end
       
       a_num = a_num+1;
    end
end


