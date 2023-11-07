function preprocessing_postBCG(folderpath, foldername, subfolder, resample_512, select_comps, blink_channel, chanlocs_name)
    % folderpath = The folder where all the folders for all participants are stored. E.g., 'Users/User/MATLAB/LCT'
    % foldername = The common denominator in the subject folder naming convention. E.g., 'sub'
    % subfolder = The subfolder for non_cv_data
    % resample_512 = do you want to resample to 512? YES/NO
    % select_comps = do you want to select components manually after ICA? YES/NO
    % blink_channel = channel to be used for blink component. Either VEOG or Fp1/Fp2
    % chanlocs_name = name of channel locations file. must be in MATLAB path. e.g.: 'bvchan.ced', 'standard-10-5-cap385.elp'
    % THIS FUNCTION WILL PREPROCESS ALL VHDR FILES IN THE FOLDER WHOSE PATH HAS BEEN PROVIDED
    
    clc;

    % Convert all inputs to characters
    if ~ischar(folderpath)
        folderpath = convertStringsToChars(folderpath);
        fprintf('Converted folderpath from string to character.\n')
    end

    if ~ischar(foldername)
        foldername = convertStringsToChars(foldername);
        fprintf('Converted foldername from string to character.\n')
    end

    if ~ischar(subfolder)
        subfolder = convertStringsToChars(subfolder);
        fprintf('Converted subfolder from string to character.\n')
    end

    if ~ischar(resample_512)
        resample_512 = convertStringsToChars(resample_512);
        fprintf('Converted resample_512 from string to character.\n')
    end

    if ~ischar(select_comps)
        select_comps = convertStringsToChars(select_comps);
        fprintf('Converted select_comps from string to character.\n')
    end

    if ~ischar(blink_channel)
        blink_channel = convertStringsToChars(blink_channel);
        fprintf('Converted blink_channel from string to character.\n')
    end

    if ~ischar(chanlocs_name)
        chanlocs_name = convertStringsToChars(chanlocs_name);
        fprintf('Converted chanlocs_name from string to character.\n')
    end

    chanlocs_name = char(which(chanlocs_name));
    
    % MAKE SURE WE ARE IN FILEPATH PROVIDED
    cd(folderpath);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SET UP FOLDER ARRAY TO LOOP THROUGH
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % CREATE ARRAY OF ALL FOLDERS WITHIN OUR CURRENT DIRECTORY
    fprintf('Getting all folders in path...\n')

    substring = convertStringsToChars(strcat(foldername, '*'));
    all_files = dir(substring);
    
    % GET INDEX OF ALL FILES FLAGGED AS DIRECTORY (AKA, FOLDER)
    folder_index = [all_files.isdir];
    % USE INDEX TO SUBSET ALL_FILES
    sub_files = all_files(folder_index); 
    
    % SAVE FOLDER NAMES TO ARRAY
    folders = {sub_files.name};

    clear substring all_files folder_index sub_files

    % LOOP THROUGH FOLDERS TO CHECK WHICH ONES HAVE POST-BCG FILES IN THEM
    fprintf('Getting all folders with un-preprocessed post-BCG files in path...\n')
    
    folders_with_data = {};
    index = 1;
    for folder=1:length(folders)
        cd(folders{folder});
        if isfolder(subfolder)
            cd(subfolder)
            if ~isempty(dir('*.mat'))
                folders_with_data{index} = folders{folder};
                index = index + 1;
            end
            cd ..
        end
        cd ..
    end

    clear folder index folders
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREPROCESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % LOOP THROUGH ARRAY OF FOLDERS TO LOAD DATASET
    for folder=1:length(folders_with_data)

        % CHANGE DIRECTORY TO THE SUBJECT FOLDER
        cd(folders_with_data{folder});
        
        % GET NAME OF THE RAW FILE FOR BCGNET
        files = dir('*_raw.set');
        files = {files.name};

        for file=1:length(files)
            setname = erase(files{file},'_raw.set');

            % LOAD EEGLAB
            eeglab;

            % LOAD THE RAW FILE USED IN BCGNET
            EEG = pop_loadset('filename', files{file}, 'filepath', pwd);
            EEG.setname = setname;
            EEG = eeg_checkset(EEG);
        
            eeglab redraw;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE EVENTS FOR EACH RUN
            
            eventfile = convertStringsToChars(strcat(setname, '.txt'));
            pop_expevents(EEG, eventfile, 'samples');
            eventfile = fullfile(pwd, eventfile);

            clear EEG;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESCALING
            % CD INTO THE NON_CV_DATA FOLDER
            cd(subfolder);

            % GET THE DATA FILE FOR THE RUN WE ARE IN
            dataname = fullfile(strcat(setname, '_bcgnet.mat'));

            load(dataname);
            data=data*1000000;

            dataoutput = erase(dataname,'.mat');
            dataoutput = convertStringsToChars(strcat('rescaled_', dataoutput));
            save(dataoutput,'data');

            clear data dataname setname;

            data_name = convertStringsToChars(strcat(dataoutput, '.mat'));

            EEG = pop_editset(eeg_emptyset, ...
                'data',data_name, ...
                'dataformat','matlab', ...
                'setname',dataoutput, ...
                'srate',500, ...
                'chanlocs',chanlocs_name);
            EEG = eeg_checkset(EEG);
            eeglab redraw;
            
            clear data_name
            cd ..
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CLEAN EVENTS
            % read in the eventfile.txt
            events = readtable(eventfile, ...
                'Format', '%u%f%f%u%f%u%u%s%s%u', ...
                'TextType','char');
            
            % Remove spaces
            events.type = erase(events.type,' ');
            
            % Delete events you are not interested in 
            remove_events = ["boundary", "SyncOn", "V1", "S255", "S155", "S27", "S127"];
            events_index = events.type == remove_events;
            events_index = sum(events_index,2);
            events = events(~events_index,:);

            clear remove_events events_index

            % Remove S
            events.type = erase(events.type,'S');

            % Separate important columns
            number = events.number;
            latency = events.latency;
            duration = events.duration;
            type = events.type;
            type = string(type);
            type = str2double(type);

            % Recode events of interest
            event = 223;
            event_index = type == event;
            event_index = find(event_index);
            type(event_index) = 95;

            clear event event_index

            event = 213;
            event_index = type == event;
            event_index = find(event_index);
            type(event_index) = 85;

            clear event event_index
            
            event = 215;
            event_index = type == event;
            event_index = find(event_index);
            type(event_index) = 87;

            clear event event_index
            
            event = 217;
            event_index = type == event;
            event_index = find(event_index);
            type(event_index) = 89;

            clear event event_index

            event = 219;
            event_index = type == event;
            event_index = find(event_index);
            type(event_index) = 91;

            clear event event_index

            event = 221;
            event_index = type == event;
            event_index = find(event_index);
            type(event_index) = 93;

            clear event event_index

            % Create new matrix
            events_new = table(number, latency, duration, type);
            
            clear events number latency duration type

            % SAVE FILE
            eventfile = strcat(erase(eventfile, '.txt'), '_new.txt');
            writetable(events_new,eventfile);

            clear events_new

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORT CLEANED EVENTS
            EEG = pop_importevent(EEG, ...
                'event',eventfile, ...
                'fields',{'number','latency','duration','type'}, ...
                'skipline', 1, ...
                'timeunit',NaN);
            EEG = eeg_checkset(EEG);
            eeglab redraw;

            % SAVE DATA FILE
            % NAMING CONVENTION IS Projectname_P##_R##_BCGNETclean
            dataoutput = split(dataoutput, "_");
            subject = erase(dataoutput{2}, 'sub');
            run = erase(dataoutput{3}, 'r');
            outfile = strcat("ARL1_", subject, "_", run, "_BCGNETclean");
            if ~ischar(outfile)
                outfile = convertStringsToChars(outfile);
                fprintf('Converted outfile from string to character.\n')
            end

            outputpath = fullfile(folderpath, folders_with_data{folder});
            if ~ischar(outputpath)
                outputpath = convertStringsToChars(outputpath);
                fprintf('Converted outputpath from string to character.\n')
            end

            EEG = pop_saveset(EEG, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
            
            clear dataoutput run subject
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FILTERING IIR BUTTERWORTH
            chanArray = 1:64; % number of channels
        
            % Notch Filter (Not required but a good sanity check nonetheless):
            EEG  = pop_basicfilter(EEG, chanArray, ...
                'Boundary', 'boundary', ...
                'Cutoff',  60, ...
                'Design', 'notch', ...
                'Filter', 'PMnotch', ...
                'Order', 180);
            eeglab redraw;
            
            % Butterworth Filter:
            EEG  = pop_basicfilter(EEG, chanArray, ...
                'Boundary', 'boundary', ...
                'Cutoff', [ 0.1 30], ...
                'Design', 'butter', ...
                'Filter', 'bandpass', ...
                'Order', 2, ...
                'RemoveDC', 'on'); 
            eeglab redraw;
            
            clear chanArray
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESAMPLE TO 512
            if strcmp(resample_512, 'YES')
                EEG = pop_resample(EEG, 512);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHANNEL LOCATIONS
            
            EEG = pop_chanedit(EEG, 'lookup', chanlocs_name);
            EEG = eeg_checkset(EEG);
            eeglab redraw;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INTERPOLATE CHANNELS
            % Interpolate channel(s) specified in Excel file Interpolate_Channels_RSEEG.xls; 
            % any channels without channel locations (e.g., the eye channels) should be excluded 
            % and are listed in ignored channels
            % EEG channels that will later be used for measurement of the ERPs should not be interpolated
            % The ignored channels should be correct for Brainvision but it might be worth triple checking
            ignored_channels = [1, 2, 17, 18, 19]; % these should NEVER be messed with % 32 is ECG channel
            pop_eegplot(EEG);
            x = input("Enter bad channel numbers (NOT labels) separated by commas. \nDo NOT enter 1, 2, 17, 18, or 19. \nIf there are none, please enter 'None'. ");
            x = string(x);
            if x ~= "None"
                x = split(x, ",");
                badchans = [];
                for i=1:length(x)
                    badchans(i) = str2num(x{i});
                end
                EEG  = pop_erplabInterpolateElectrodes( EEG , ...
                    'displayEEG',  0, ...
                    'ignoreChannels',  ignored_channels, ...
                    'interpolationMethod', 'spherical', ...
                    'replaceChannels', badchans);
                EEG = eeg_checkset(EEG);
                eeglab redraw;
            end
            clear i x badchans ignored_channels;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ICA 

            EEG = pop_runica(EEG, ...
                'icatype', 'runica', ...
                'extended',1, ...
                'interrupt','on');
            EEG = eeg_checkset(EEG);
            eeglab redraw;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ICLABEL
        
            thresh = [0 0; 0.9 1; 0.9 1; 0.9 1; 0.9 1; 0.9 1; 0.9 1];
            % LABEL ARTEFACTS
            EEG = iclabel(EEG, 'default');
            % FLAGGED ARTEFACTS FOR REJECTION
            EEG = pop_icflag(EEG, thresh);
            % REMOVE FLAGGED ARTEFACTS
            EEG = pop_subcomp(EEG, '' ,0 ,0);
            EEG = eeg_checkset(EEG);
            eeglab redraw;
            
            clear thresh
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ICA BLINK METRICS
            
            EEG.icaquant = icablinkmetrics(EEG, ...
                'ArtifactChannel', EEG.data(find(strcmp({EEG.chanlocs.labels},blink_channel)),:), ...
                'MetricThresholds',[0.001 0.001 0.001], ...
                'VisualizeData','True');
            [~,index] = sortrows([EEG.icaquant.metrics.convolution].'); %'
            
            EEG.icaquant.metrics = EEG.icaquant.metrics(index(end:-1:1)); 
            if strcmp(select_comps,'YES')
                pop_selectcomps(EEG)
                x = input(strcat("ICA has identified component(s) ", num2str(EEG.icaquant.identifiedcomponents), ". \nEnter additional bad components separated by commas. If there are none, please enter 'None'. "));
                x = string(x{1});
                if x ~= "None"
                    x = split(x, ",");
                    index = length(EEG.icaquant.identifiedcomponents) + 1;
                    for i=1:length(x)
                        EEG.icaquant.identifiedcomponents(index) = str2num(x{i});
                        index = index + 1;
                    end
                end
            end

            EEG = pop_subcomp(EEG, EEG.icaquant.identifiedcomponents, 0);
            EEG = eeg_checkset(EEG);
            eeglab redraw
            
            clear i index x

            % SAVE DATA
            % NAMING CONVENTION IS Projectname_P##_R##_ICAbeforereref
            outfile = strcat(erase(outfile, '_BCGNETclean'),'_ICAbeforereref');
            if ~ischar(outfile)
                outfile = convertStringsToChars(outfile);
                fprintf('Converted outfile from string to character.\n')
            end

            EEG = pop_saveset(EEG, 'filename', outfile, 'filepath', outputpath, 'savemode', 'twofiles', 'version', '7.3');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RE-REFERENCE DATASET 
            EEG = pop_reref(EEG, [], 'exclude', 32); % 32 is ECG channel
            EEG = eeg_checkset(EEG);
            eeglab redraw

            % SAVE DATA
            % NAMING CONVENTION IS Projectname_P##_R##_reref
            outfile = strcat(erase(outfile, '_ICAbeforereref'),'_reref');
            if ~ischar(outfile)
                outfile = convertStringsToChars(outfile);
                fprintf('Converted outfile from string to character.\n')
            end

            EEG = pop_saveset(EEG, 'filename', outfile, 'filepath', outputpath, 'savemode', 'twofiles', 'version', '7.3');
            clear outfile EEG ALLCOM ALLEEG ALLERP ALLERPCOM CURRENTERP CURRENTSET CURRENTSTUDY ERP LASTCOM plotset STUDY
        end
        cd ..
    end

