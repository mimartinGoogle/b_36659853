% This code processes data collected for b/36659853
% written by:   Michael Martin (mimartin@)
% date:         5/5/2017


clear all;
close all;
clc;

% Enter pre-amble information
root_path       = pwd;
devices         = {'Pixel XL','Pixel'};
device_apps     = {'youtube','vr.home.welcome','dreambench','gunjack'};
device_logs     = 'Device Logs';
chamber_logs    = 'Chamber Logs';
temperatures    = {'20C','30C','35C'};

% Create looping constants from pre-amble information
num_of_devices  = length(devices);
num_of_apps     = length(device_apps);
num_of_temps    = length(temperatures);

% begin main loop
for i = 1:num_of_devices
    for j = 1:num_of_temps
        % get to the folder of the device logs
        filepath = fullfile(root_path,devices{i},device_logs,temperatures{j});

        % check to see if the file path is a directory and add to path if so
        if isdir(filepath) ~= 1
            disp('your input filepath is NOT a working directory')
            return
        else
            addpath(filepath)
        end
        
        % begin looping through output files in current 'filepath'
        for k = 1:num_of_apps
        % selecting the file 
            app_data_files  = dir(fullfile(filepath,strcat('*',device_apps{k},'*.csv')));
            if isempty(app_data_files) == 1
                disp(strcat('You are missing data for',devices{i},', ',...
                    temperatures{j},', ',device_apps{k}))
                continue
            else
            app_data_file   = app_data_files.name;
            app_file_path   = fullfile(filepath,app_data_file);
            end
            
            % read data from file, write to memory, in a cell
            raw_data = readtable(app_data_file);
            raw_data = table2cell(raw_data);
            
            % create empty arrays for "ts" and "tskin_temp" data
            [rows cols] = size(raw_data);
            data        = zeros(rows-1,2);
            crash_data  = zeros(rows-1,1);
            
            % copy timestamp (ts) and skin temperture (tskin_temp) data to 
            % a new array and convert timestampvalues from seconds to 
            % minutes.
            for ii = 2:rows
                % loops through one row at a time, updating "data" array
                data(ii-1,1) = raw_data{ii,1};
                data(ii-1,2) = raw_data{ii,6};
                
                % determining if device crashed during test
                if strcmp(raw_data{ii,23},'False') == 1 % no crash
                    crash_data(ii-1,1) = 0;
                    crash = 0;
                elseif strcmp(raw_data{ii,23},'False') == 0 % crash
                    crash_data(ii-1,1) = 1;
                    crash = 1;
                    crash_temp = data(end,2);
                    crash_time = data(end,1)/60;
                else
                    crash_data(ii-1,1) = 999;
                end
            end
            % convert the timestamp column to minute units
            data(:,1)   = data(:,1)/60;
            max_temp    = max(data(:,2));
            
            % Determine if the test failed or not

            % plotting
            figure_num = strcat(num2str(i),num2str(j),num2str(k));
            figure_num = str2num(figure_num);
            figure(figure_num)
            set(findall(gcf,'type','text'),'FontSize',8)
            plot(data(:,1),data(:,2),'LineWidth',3)
            title([devices{i},' : ',temperatures{j},' : ',device_apps{k}])
            xlabel('time (minutes)')
            ylabel('tskin\_temp (deg-C)')
            if crash == 1
                
                msg = {sprintf('Time Until Crash (mins) = %.2f',crash_time),...
                    sprintf('Last Recorded Temp (C) = %d',crash_temp)};
                annotation('textbox',[.4 .3 .3 .3],'String',msg,...
                'HorizontalAlignment','center',...
                'VerticalAlignment','middle',...
                'BackgroundColor','red','FitBoxToText','on')
            else
                msg = {'Test Passed',...
                    sprintf('Highest Recorded Temp (C) = %d',max_temp)};
                annotation('textbox',[.4 .3 .3 .3],'String',msg,...
                'HorizontalAlignment','center',...
                'VerticalAlignment','middle',...
                'BackgroundColor','green','FitBoxToText','on')
            end
            hold on
            saveas(figure_num,sprintf('%s - %s - %s.png',devices{i},temperatures{j},device_apps{k}'))
         end


        
       


    end
end
hold off

% TO DO
% - make script loop through folders, plotting data each time (DONE)
% - hold each plot (DONE)
% - update plot titles each time (DONE)
% - update time stamps to me in minutes (DONE)

% TO DO
% - decide where to check in code 
% - include comment in plot for highest reported temp (DONE)
% - have code determine if the test failed or not (DONE)
% - if failures occurred, determine last recorded temp (DONE)
% - print error message for data that is missing (DONE)

% TODO
% - save plots to disk