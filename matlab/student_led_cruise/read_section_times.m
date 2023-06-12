function tbl = read_section_times
%read_section_times - Read section start and end times from csv
%
% Syntax: tbl = read_section_times
%
% Table with UTC and local section start and end times.
% N.B. All datetimes are timezone unaware.
% A display time string defined using Aries' local section start time
% is also given.

% arguments (Output)
%     tbl table
% end

    % filepath relative to this file
    relative_filepath = "../../metadata/section_times.csv";
    % get directory of this function
    [directory,~,~] = fileparts(mfilename('fullpath'));
    % construct full filepath
    filepath = fullfile(directory,relative_filepath);

    tbl = readtable(filepath,Format='%s%D%D%D%D%D%D%D%D%D%D%D%D%D%D%D%D%D%s',TextType="string");
    tbl.direction = categorical(tbl.direction);
end