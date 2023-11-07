function preprocessing_preBCG(folderpath, foldername, fileext, TR_duration, total_TRs)
    % folderpath = The folder where all the folders for all participants are stored. E.g., 'Users/User/MATLAB'
    % foldername = The common denominator in the subject folder naming convention. E.g., 'ARL1'
    % outputfolder = The name of the folder where results should be outputfolder
    % fileext = The extension of files for your task. Eg., "LCT", "IF", etc. This will also be used for output folder name.
    % total_TRs = OPTIONAL. Number of TRs in task. Will be used to calculate number of runs in one file.
    % TR_duration = OPTIONAL. Total duration of a TR in ms.
    
    % THIS FUNCTION WILL PREPROCESS ALL VHDR FILES IN THE FOLDER WHOSE PATH HAS BEEN PROVIDED

    fprintf('Checking inputs...\n')
    
    % Convert all inputs to characters
    if ~ischar(folderpath)
        folderpath = convertStringsToChars(folderpath);
        fprintf('Converted folderpath from string to character.\n')
    end

    if ~ischar(foldername)
        foldername = convertStringsToChars(foldername);
        fprintf('Converted foldername from string to character.\n')
    end

    if ~ischar(fileext)
        fileext = convertStringsToChars(fileext);
        fprintf('Converted fileext from string to character.\n')
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SET UP FOLDER ARRAY TO LOOP THROUGH
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Creating arrays to loop through...\n')

    % MAKE SURE YOU'RE IN DIRECTORY PROVIDED
    % cd(folderpath);

    % CREATE ARRAY OF ALL FOLDERS WITHIN OUR CURRENT DIRECTORY
    substring = strcat(foldername, '*');
    
    if ~ischar(substring)
        substring = convertStringsToChars(substring);
    end

    fprintf('Getting all folders in path...\n')

    all_files = dir(substring);
    % GET INDEX OF ALL FILES FLAGGED AS DIRECTORY (AKA, FOLDER)
    folder_index = [all_files.isdir];
    % USE INDEX TO SUBSET ALL_FILES
    sub_files = all_files(folder_index); 
    % SAVE FOLDER NAMES TO ARRAY
    folders = {sub_files.name};

    clear substring all_files folder_index sub_files

    fprintf('Getting all folders with .vhdr files in path...\n')

    % LOOP THROUGH FOLDERS TO CHECK WHICH ONES HAVE .VHDR FILES IN THEM
    folders_with_vhdr = {};
    index = 1;
    substring = strcat("*", fileext, ".vhdr");
    if ~ischar(substring)
        substring = convertStringsToChars(substring);
    end
    for folder=1:length(folders)
        cd(folders{folder});
        if ~isempty(dir(substring))
            folders_with_vhdr{index} = folders{folder};
            index = index + 1;
        end
        cd ..
    end

    disp(folders_with_vhdr);
    disp(length(folders_with_vhdr));

    clear index folder substring

    fprintf('Creating output folder...\n')

    % CREATE FOLDERS FOR SAVING PREPROCESSED FILES IF NOT PRESENT
    if ~exist(fileext, 'dir')
        mkdir(fileext);
    end
    
    % CREATE ARRAY OF ALL FOLDERS WITHIN OUTPUT FOLDER
    outputfolderpath = strcat(folderpath, '/', fileext);

    if ~ischar(outputfolderpath)
        outputfolderpath = convertStringsToChars(outputfolderpath);
    end

    % ADD NEW FOLDERS TO PATH
    addpath(outputfolderpath);

    fprintf('Creating array of folders already processed...\n')

    % GET LIST OF SUBJECT FOLDERS ALREADY IN OUTPUT FOLDER
    cd(outputfolderpath);
    all_files = dir('sub*');
    if ~isempty(all_files)
        % GET INDEX OF ALL FILES FLAGGED AS DIRECTORY (AKA, FOLDER)
        folder_index = [all_files.isdir];
        % USE INDEX TO SUBSET ALL_FILES
        sub_files = all_files(folder_index); 
        % SAVE FOLDER NAMES TO ARRAY
        folders_lct = {sub_files.name};
    else
        folders_lct = {};
    end
    cd ..

    clear all_files folder outputfolderpath sub_files;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREPROCESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Starting preprocessing loop...\n');
    
    % LOOP THROUGH ARRAY OF FOLDERS THAT HAVE .VHDR FILES TO LOAD DATASET
    for folder=1:length(folders_with_vhdr)
        disp(folder);
        disp(folders_with_vhdr{folder});
        
        % MAKE SURE YOU'RE IN DIRECTORY PROVIDED
        cd(folderpath);
        
        % ISOLATE SUBJECT NUMBER
        split_string = split(folders_with_vhdr{folder},"_");
        % SUBJECT NUMBER
        subject = split_string{2};
        % SUBJECT FOLDER
        subfolder = strcat('sub', subject);
        % OUTPUT FOLDER PATH
        outputpath = strcat(folderpath,'/', fileext, '/',subfolder);
        if ~ischar(outputpath)
            outputpath = convertStringsToChars(outputpath);
        end

        % ONLY RUN SUBJECTS WHO DON'T HAVE OUTPUT FOLDERS YET
        if ~isempty(folders_lct)
            if ~ismember(subfolder, string(folders_lct))
                % PUT IN TRY-CATCH
                try
                    fprintf(strcat('Starting processing for ', folders_with_vhdr{folder}, '...\n'))
                    
                    % RUN NUMBER
                    run = split_string{3};

                    if ~ischar(subject)
                        subject = convertStringsToChars(subject);
                    end
                    if ~ischar(subfolder)
                        subfolder = convertStringsToChars(subfolder);
                    end
                    if ~ischar(run)
                        run = convertStringsToChars(run);
                    end
            
                    mkdir(outputpath);

                    % CHANGE DIRECTORY TO THE ARL FOLDER
                    cd(folders_with_vhdr{folder});

                    % SAVE ARRAY OF VHDR FILES IN DIRECTORY
                    substring = strcat("*", fileext, ".vhdr");
                    if ~ischar(substring)
                        substring = convertStringsToChars(substring);
                    end
                    hdrfile = {dir(substring).name};
                    
                    clear substring
                    
                    for hdr=1:length(hdrfile)

                        fprintf(strcat('Processing ', hdrfile{hdr}, '...'))

                        % LOAD EEGLAB
                        [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

                        % LOAD FILE
                        [EEG, com] = pop_loadbv(pwd, hdrfile{hdr});
                        eeglab redraw;
                        pause(1);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHECK FOR FALSE STARTS

                        % CALCULATE PEAK REFERENCES USING MARKER
                        Peak_references = UseMarker(EEG, 'V  1');
                        % CALCULATE TR DURATION IF NOT PROVIDED
                        if ~exist('TR_duration','var')
                            TR_duration = round((Peak_references(3)-Peak_references(2))/EEG.srate*1000);
                        end

                        % CALCULATE DIFFERENCES BETWEEN THE PEAK REFERENCES
                        % THESE DIFFERENCES SHOULD ALWAYS EQUAL THE TR DURATION
                        index = 1;
                        non_TR_peaks = {};
                        for peak=1:length(Peak_references) - 1
                            peak_diff = round((Peak_references(peak+1) - Peak_references(peak))/EEG.srate*1000);
                            if peak_diff ~= TR_duration
                                non_TR_peaks{index} = peak;
                                index = index+1;
                            end
                        end
                        clear index peak;

                        % IF THERE ARE NON-TR PEAKS
                        if ~isempty(non_TR_peaks)
                            fprintf('Pauses found. Separating full runs...\n')
                        
                            % SOME OF THESE MAY BE PAUSES BETWEEN RUNS
                            % GET THE NUMBER OF TRS BETWEEN PAUSES
                            index = 1;
                            duration_between_non_TR_peaks = {};
                            for peak=0:length(non_TR_peaks) - 1
                                if peak == 0
                                    peak_diff = non_TR_peaks{peak+1} - 0;
                                    duration_between_non_TR_peaks{index} = peak_diff;
                                else
                                    peak_diff = non_TR_peaks{peak+1} - non_TR_peaks{peak};
                                    duration_between_non_TR_peaks{index} = peak_diff;
                                end
                                index = index+1;
                            end
                            duration_between_non_TR_peaks{index} = length(Peak_references) - non_TR_peaks{length(non_TR_peaks)};
                            clear index peak;

                            % IF THE PAUSE IS NOT A FALSE START, ITS PEAK WILL BE DIVISIBLE BY THE NUMBER OF TRS IN THE TASK
                            % IF NUMBER OF TRS IS NOT PROVIDED, IT IS THE LARGEST VALUE IN THE DURATION ARRAY
                            if ~exist('total_TRs','var')
                                total_TRs = max(cell2mat(duration_between_non_TR_peaks));
                            end
                            
                            % CUT THE EEG INTO SEGMENTS BASED ON TR DURATION
                            segments = {};
                            index = 1;
                            for peak = 1:length(duration_between_non_TR_peaks)
                                if duration_between_non_TR_peaks{peak} == total_TRs
                                    if peak == 1
                                        segments{index} = [0.0001, Peak_references(non_TR_peaks{peak})/EEG.srate];
                                    elseif peak == length(duration_between_non_TR_peaks)
                                        segments{index} = [Peak_references(non_TR_peaks{peak-1})/EEG.srate, Peak_references(length(Peak_references))/EEG.srate];
                                    else
                                        segments{index} = [Peak_references(non_TR_peaks{peak-1})/EEG.srate, Peak_references(non_TR_peaks{peak})/EEG.srate];
                                    end
                                    index = index + 1;
                                end
                            end
                            clear index peak;

                            % SEPARATE THE RUNS AND PROCESS EACH SEGMENT
                            for segment = 1:length(segments)
                                % CHANGE RUN TO REFLECT SEGMENT
                                run = sprintf('%02d', segment);
        
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CUT THE EEG
                                EEG_segment = pop_select(EEG, 'notime', segments{segment});
                                eeglab redraw;
                            
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GRADIENT ARTIFACT CORRECTION
                                outfile = strcat(foldername, '_', subject, '_', run, '_', fileext, '_GA');
                                if ~ischar(outfile)
                                    outfile = convertStringsToChars(outfile);
                                end

                                % RECALCULATE PEAK REFERENCES USING MARKER
                                Peak_references_segment = UseMarker(EEG_segment, 'V  1');
        
                                % CALCULATE START OF FMRI RECORDING FROM FIRST PEAK REFERENCE
                                start_of_fmri = Peak_references_segment(1)/EEG_segment.srate;
                            
                                % GET WEIGHTING MATRIX FROM MOVING AVERAGE
                                n_fmri = length(Peak_references_segment);
                                k = 25;
                                weighting_matrix = m_moving_average(n_fmri,k);
        
                                % USE BASELINE CORRECTION WITH MEAN OF ARTIFACT PERIOD ITSELF
                                baseline_method = 1;
                                extra_data = 1;
                                onset_value = 0;
                                offset_value = EEG_segment.srate*(TR_duration/1000);
                                ref_start = 0;
                                ref_end = 0;
                                [EEG_segment] = BaselineCorrectScript(EEG_segment, Peak_references_segment, weighting_matrix, baseline_method, onset_value, offset_value, ref_start, ref_end, extra_data);
        
                                % APPLY CORRECTION MATRIX
                                [EEG_segment, message] = CorrectionMatrix(EEG_segment, weighting_matrix, Peak_references_segment, onset_value, offset_value);
                                eeglab redraw;
                                pause(1);
        
                                % SAVE DATASET
                                EEG_segment = pop_saveset(EEG_segment, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
        
                                clear Peak_references_segment n_fmri k onset_value offset_value baseline_method extra_data outfile; 
                                
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TRIMMING
                                outfile = strcat(foldername, '_', subject, '_', run, '_', fileext, '_GA_trimmed');
                                if ~ischar(outfile)
                                    outfile = convertStringsToChars(outfile);
                                end
                                
                                % REMOVE PRE-TASK DATA
                                % INSERT BOUNDARY AT [0.0001, start_of_fmri]
                                EEG_segment = eeg_checkset(EEG_segment);
                                EEG_segment = pop_select(EEG_segment, 'notime', [0.0001, start_of_fmri]);
                                EEG_segment = eeg_checkset(EEG_segment);
                                eeglab redraw;
                                pause(1);
        
                                % SAVE DATASET
                                EEG_segment = pop_saveset(EEG_segment, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
                                
                                clear outfile;
                                
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESAMPLING
                                outfile = strcat('sub', subject, '_r', run, '_raw');
                                if ~ischar(outfile)
                                    outfile = convertStringsToChars(outfile);
                                end
                                
                                % RESAMPLE DATASET AT 500 Hz SO DATA IS SMALLER AND ANALYSIS IS QUICKER
                                freq = 500;
                                EEG_segment = pop_resample(EEG_segment, freq);
                                eeglab redraw;
                                pause(1);
        
                                clear freq; 
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FILTERING
        
                                % FILTER LOADED DATASET. LOWPASS AT 70 Hz, HIGHPASS AT .25 HZ cutoff
                                [EEG_segment, com, b] = pop_eegfiltnew(EEG_segment, 70, 0.25);
                                eeglab redraw;
                                pause(1);
        
                                % SAVE DATASET
                                % NAMING CONVENTION IS subNo_runNo_raw (e.g., sub07_r01_raw, sub07_r02_raw, etc.)
                                EEG_segment = pop_saveset(EEG_segment, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
                                
                                clear outfile;
                                
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FMRIB
                                outfile = strcat('sub', subject, '_r', run, '_eval');
                                if ~ischar(outfile)
                                    outfile = convertStringsToChars(outfile);
                                end
        
                                % RUN FMRIB FOR BCGNET COMPARISON
                                ecgchan = 32;
                                [EEG_segment, COM] = pop_fmrib_qrsdetect(EEG_segment, ecgchan, 'qrs', 'no');
                                eeglab redraw;
                                pause(1);
                            
                                [EEG_segment, COM] = pop_fmrib_pas(EEG_segment, 'qrs', 'obs', 3);
                                eeglab redraw;
                                pause(1);
        
                                % SAVE DATASET IF ALL LOOKS GOOD
                                % NAMING CONVENTION IS subNo_runNo_raw_eval (e.g., sub07_r01_raw_eval, sub07_r02_raw_eval, etc.)
                                EEG_segment = pop_saveset(EEG_segment, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
        
                                clear EEG_segment ecgchan outfile; 
                            end 
                        else  % IF SEGMENTS ARE EMPTY THE FILE IS CLEAN AND CONTAINS ONLY ONE RUN
                            fprintf("No pauses found. Processing...")
                        
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GRADIENT ARTIFACT CORRECTION
                            outfile = strcat(foldername, '_', subject, '_', run, '_', fileext, '_GA');
                            if ~ischar(outfile)
                                outfile = convertStringsToChars(outfile);
                            end

                            % CALCULATE START OF FMRI RECORDING FROM FIRST PEAK REFERENCE
                            start_of_fmri = Peak_references(1)/EEG.srate;
                        
                            % GET WEIGHTING MATRIX FROM MOVING AVERAGE
                            n_fmri = length(Peak_references);
                            k = 25;
                            weighting_matrix = m_moving_average(n_fmri,k);

                            % USE BASELINE CORRECTION WITH MEAN OF ARTIFACT PERIOD ITSELF
                            baseline_method = 1;
                            extra_data = 1;
                            onset_value = 0;
                            offset_value = EEG.srate*(TR_duration/1000);
                            ref_start = 0;
                            ref_end = 0;
                            [EEG] = BaselineCorrectScript(EEG, Peak_references, weighting_matrix, baseline_method, onset_value, offset_value, ref_start, ref_end, extra_data);
                            
                            % APPLY CORRECTION MATRIX
                            [EEG, message] = CorrectionMatrix(EEG, weighting_matrix, Peak_references, onset_value, offset_value);
                            eeglab redraw;
                            pause(1);

                            % SAVE DATASET
                            % NAMING CONVENTION IS participantID_task_GA (e.g., ARL1_7_IF_GA, ARL1_7_LCT_GA, etc.)
                            EEG = pop_saveset(EEG, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
        
                            clear n_fmri k onset_value offset_value baseline_method extra_data outfile; 

                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TRIMMING
                            outfile = strcat(foldername, '_', subject, '_', run, '_', fileext, '_GA_trimmed');
                            if ~ischar(outfile)
                                outfile = convertStringsToChars(outfile);
                            end
                                
                            % REMOVE PRE-TASK DATA
                            % INSERT BOUNDARY AT [0.0001, start_of_fmri]
                            EEG = eeg_checkset(EEG);
                            EEG = pop_select(EEG, 'notime', [0.0001, round(start_of_fmri-2)]);
                            EEG = eeg_checkset(EEG);
                            eeglab redraw;
                            pause(1);
        
                            % SAVE DATASET. NAMING CONVENTION IS participantID_task_GA_trimmed (e.g., ARL1_7_IF_GA_trimmed)
                            EEG = pop_saveset(EEG, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
                            
                            clear outfile;
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESAMPLING
                            outfile = strcat('sub', subject, '_r', run, '_raw');
                            if ~ischar(outfile)
                                outfile = convertStringsToChars(outfile);
                            end
                            
                            % RESAMPLE DATASET AT 500 Hz SO DATA IS SMALLER AND ANALYSIS IS QUICKER
                            freq = 500;
                            EEG = pop_resample(EEG, freq);
                            eeglab redraw;
                            pause(1);
        
                            clear freq; 
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FILTERING
        
                            % FILTER LOADED DATASET. LOWPASS AT 70 Hz, HIGHPASS AT .25 HZ cutoff
                            [EEG, com, b] = pop_eegfiltnew(EEG, 70, 0.25);
                            eeglab redraw;
                            pause(1);
        
                            % SAVE DATASET
                            % NAMING CONVENTION IS subNo_runNo_raw (e.g., sub07_r01_raw, sub07_r02_raw, etc.)
                            EEG = pop_saveset(EEG, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
                            
                            clear outfile;
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FMRIB
                            outfile = strcat('sub', subject, '_r', run, '_eval');
                            if ~ischar(outfile)
                                outfile = convertStringsToChars(outfile);
                            end
        
                            % RUN FMRIB FOR BCGNET COMPARISON
                            ecgchan = 32;
                            [EEG, COM] = pop_fmrib_qrsdetect(EEG, ecgchan, 'qrs', 'no');
                            eeglab redraw;
                            pause(1);
                        
                            [EEG, COM] = pop_fmrib_pas(EEG, 'qrs', 'obs', 3);
                            eeglab redraw;
                            pause(1);
        
                            % SAVE DATASET IF ALL LOOKS GOOD
                            % NAMING CONVENTION IS subNo_runNo_raw_eval (e.g., sub07_r01_raw_eval, sub07_r02_raw_eval, etc.)
                            EEG = pop_saveset(EEG, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
        
                            clear ecgchan outfile;
                        end 
                    end
                    cd ..
                catch error

                    % Output the error message that describes the error:
                    fprintf(1,'There was an error! The message was:\n%s', error.message);
                end
            end
        else % THERE ARE NO SUBJECT FOLDERS YET
            try
                fprintf(strcat('Starting processing for ', folders_with_vhdr{folder}, '...\n'))
                
                % RUN NUMBER
                run = split_string{3};

                if ~ischar(subject)
                    subject = convertStringsToChars(subject);
                end
                if ~ischar(subfolder)
                    subfolder = convertStringsToChars(subfolder);
                end
                if ~ischar(run)
                    run = convertStringsToChars(run);
                end
        
                mkdir(outputpath);

                % CHANGE DIRECTORY TO THE ARL FOLDER
                cd(folders_with_vhdr{folder});

                % SAVE ARRAY OF VHDR FILES IN DIRECTORY
                substring = strcat("*", fileext, ".vhdr");
                if ~ischar(substring)
                    substring = convertStringsToChars(substring);
                end
                hdrfile = {dir(substring).name};
                
                clear substring
                
                for hdr=1:length(hdrfile)

                    fprintf(strcat('Processing ', hdrfile{hdr}, '...'))

                    % LOAD EEGLAB
                    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

                    % LOAD FILE
                    [EEG, com] = pop_loadbv(pwd, hdrfile{hdr});
                    eeglab redraw;
                    pause(1);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHECK FOR FALSE STARTS

                    % CALCULATE PEAK REFERENCES USING MARKER
                    Peak_references = UseMarker(EEG, 'V  1');
                    % CALCULATE TR DURATION IF NOT PROVIDED
                    if ~exist('TR_duration','var')
                        TR_duration = round((Peak_references(3)-Peak_references(2))/EEG.srate*1000);
                    end

                    % CALCULATE DIFFERENCES BETWEEN THE PEAK REFERENCES
                    % THESE DIFFERENCES SHOULD ALWAYS EQUAL THE TR DURATION
                    index = 1;
                    non_TR_peaks = {};
                    for peak=1:length(Peak_references) - 1
                        peak_diff = round((Peak_references(peak+1) - Peak_references(peak))/EEG.srate*1000);
                        if peak_diff ~= TR_duration
                            non_TR_peaks{index} = peak;
                            index = index+1;
                        end
                    end
                    clear index peak;

                    % IF THERE ARE NON-TR PEAKS
                    if ~isempty(non_TR_peaks)
                        fprintf('Pauses found. Separating full runs...')
                    
                        % SOME OF THESE MAY BE PAUSES BETWEEN RUNS
                        % GET THE NUMBER OF TRS BETWEEN PAUSES
                        index = 1;
                        duration_between_non_TR_peaks = {};
                        for peak=0:length(non_TR_peaks) - 1
                            if peak == 0
                                peak_diff = non_TR_peaks{peak+1} - 0;
                                duration_between_non_TR_peaks{index} = peak_diff;
                            else
                                peak_diff = non_TR_peaks{peak+1} - non_TR_peaks{peak};
                                duration_between_non_TR_peaks{index} = peak_diff;
                            end
                            index = index+1;
                        end
                        duration_between_non_TR_peaks{index} = length(Peak_references) - non_TR_peaks{length(non_TR_peaks)};
                        clear index peak;

                        % IF THE PAUSE IS NOT A FALSE START, ITS PEAK WILL BE DIVISIBLE BY THE NUMBER OF TRS IN THE TASK
                        % IF NUMBER OF TRS IS NOT PROVIDED, IT IS THE LARGEST VALUE IN THE DURATION ARRAY
                        if ~exist('total_TRs','var')
                            total_TRs = max(cell2mat(duration_between_non_TR_peaks));
                        end
                        
                        % CUT THE EEG INTO SEGMENTS BASED ON TR DURATION
                        segments = {};
                        index = 1;
                        for peak = 1:length(duration_between_non_TR_peaks)
                            if duration_between_non_TR_peaks{peak} == total_TRs
                                if peak == 1
                                    segments{index} = [0.0001, Peak_references(non_TR_peaks{peak})/EEG.srate];
                                elseif peak == length(duration_between_non_TR_peaks)
                                    segments{index} = [Peak_references(non_TR_peaks{peak-1})/EEG.srate, Peak_references(length(Peak_references))/EEG.srate];
                                else
                                    segments{index} = [Peak_references(non_TR_peaks{peak-1})/EEG.srate, Peak_references(non_TR_peaks{peak})/EEG.srate];
                                end
                                index = index + 1;
                            end
                        end
                        clear index peak;

                        % SEPARATE THE RUNS AND PROCESS EACH SEGMENT
                        for segment = 1:length(segments)
                            % CHANGE RUN TO REFLECT SEGMENT
                            run = sprintf('%02d', segment);
    
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CUT THE EEG
                            EEG_segment = pop_select(EEG, 'notime', segments{segment});
                            eeglab redraw;
                        
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GRADIENT ARTIFACT CORRECTION
                            outfile = strcat(foldername, '_', subject, '_', run, '_', fileext, '_GA');
                            if ~ischar(outfile)
                                outfile = convertStringsToChars(outfile);
                            end

                            % RECALCULATE PEAK REFERENCES USING MARKER
                            Peak_references_segment = UseMarker(EEG_segment, 'V  1');
    
                            % CALCULATE START OF FMRI RECORDING FROM FIRST PEAK REFERENCE
                            start_of_fmri = Peak_references_segment(1)/EEG_segment.srate;
                        
                            % GET WEIGHTING MATRIX FROM MOVING AVERAGE
                            n_fmri = length(Peak_references_segment);
                            k = 25;
                            weighting_matrix = m_moving_average(n_fmri,k);
    
                            % USE BASELINE CORRECTION WITH MEAN OF ARTIFACT PERIOD ITSELF
                            baseline_method = 1;
                            extra_data = 1;
                            onset_value = 0;
                            offset_value = EEG_segment.srate*(TR_duration/1000);
                            ref_start = 0;
                            ref_end = 0;
                            [EEG_segment] = BaselineCorrectScript(EEG_segment, Peak_references_segment, weighting_matrix, baseline_method, onset_value, offset_value, ref_start, ref_end, extra_data);
    
                            % APPLY CORRECTION MATRIX
                            [EEG_segment, message] = CorrectionMatrix(EEG_segment, weighting_matrix, Peak_references_segment, onset_value, offset_value);
                            eeglab redraw;
                            pause(1);
    
                            % SAVE DATASET
                            EEG_segment = pop_saveset(EEG_segment, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
    
                            clear Peak_references_segment n_fmri k onset_value offset_value baseline_method extra_data outfile; 
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TRIMMING
                            outfile = strcat(foldername, '_', subject, '_', run, '_', fileext, '_GA_trimmed');
                            if ~ischar(outfile)
                                outfile = convertStringsToChars(outfile);
                            end
                            
                            % REMOVE PRE-TASK DATA
                            % INSERT BOUNDARY AT [0.0001, start_of_fmri]
                            EEG_segment = eeg_checkset(EEG_segment);
                            EEG_segment = pop_select(EEG_segment, 'notime', [0.0001, start_of_fmri]);
                            EEG_segment = eeg_checkset(EEG_segment);
                            eeglab redraw;
                            pause(1);
    
                            % SAVE DATASET
                            EEG_segment = pop_saveset(EEG_segment, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
                            
                            clear outfile;
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESAMPLING
                            outfile = strcat('sub', subject, '_r', run, '_raw');
                            if ~ischar(outfile)
                                outfile = convertStringsToChars(outfile);
                            end
                            
                            % RESAMPLE DATASET AT 500 Hz SO DATA IS SMALLER AND ANALYSIS IS QUICKER
                            freq = 500;
                            EEG_segment = pop_resample(EEG_segment, freq);
                            eeglab redraw;
                            pause(1);
    
                            clear freq; 
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FILTERING
    
                            % FILTER LOADED DATASET. LOWPASS AT 70 Hz, HIGHPASS AT .25 HZ cutoff
                            [EEG_segment, com, b] = pop_eegfiltnew(EEG_segment, 70, 0.25);
                            eeglab redraw;
                            pause(1);
    
                            % SAVE DATASET
                            % NAMING CONVENTION IS subNo_runNo_raw (e.g., sub07_r01_raw, sub07_r02_raw, etc.)
                            EEG_segment = pop_saveset(EEG_segment, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
                            
                            clear outfile;
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FMRIB
                            outfile = strcat('sub', subject, '_r', run, '_eval');
                            if ~ischar(outfile)
                                outfile = convertStringsToChars(outfile);
                            end
    
                            % RUN FMRIB FOR BCGNET COMPARISON
                            ecgchan = 32;
                            [EEG_segment, COM] = pop_fmrib_qrsdetect(EEG_segment, ecgchan, 'qrs', 'no');
                            eeglab redraw;
                            pause(1);
                        
                            [EEG_segment, COM] = pop_fmrib_pas(EEG_segment, 'qrs', 'obs', 3);
                            eeglab redraw;
                            pause(1);
    
                            % SAVE DATASET IF ALL LOOKS GOOD
                            % NAMING CONVENTION IS subNo_runNo_raw_eval (e.g., sub07_r01_raw_eval, sub07_r02_raw_eval, etc.)
                            EEG_segment = pop_saveset(EEG_segment, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
    
                            clear EEG_segment ecgchan outfile; 
                        end 
                    else  % IF SEGMENTS ARE EMPTY THE FILE IS CLEAN AND CONTAINS ONLY ONE RUN
                        fprintf("No pauses found. Processing...")
                    
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GRADIENT ARTIFACT CORRECTION
                        outfile = strcat(foldername, '_', subject, '_', run, '_', fileext, '_GA');
                        if ~ischar(outfile)
                            outfile = convertStringsToChars(outfile);
                        end

                        % CALCULATE START OF FMRI RECORDING FROM FIRST PEAK REFERENCE
                        start_of_fmri = Peak_references(1)/EEG.srate;
                    
                        % GET WEIGHTING MATRIX FROM MOVING AVERAGE
                        n_fmri = length(Peak_references);
                        k = 25;
                        weighting_matrix = m_moving_average(n_fmri,k);

                        % USE BASELINE CORRECTION WITH MEAN OF ARTIFACT PERIOD ITSELF
                        baseline_method = 1;
                        extra_data = 1;
                        onset_value = 0;
                        offset_value = EEG.srate*(TR_duration/1000);
                        ref_start = 0;
                        ref_end = 0;
                        [EEG] = BaselineCorrectScript(EEG, Peak_references, weighting_matrix, baseline_method, onset_value, offset_value, ref_start, ref_end, extra_data);
                        
                        % APPLY CORRECTION MATRIX
                        [EEG, message] = CorrectionMatrix(EEG, weighting_matrix, Peak_references, onset_value, offset_value);
                        eeglab redraw;
                        pause(1);

                        % SAVE DATASET
                        % NAMING CONVENTION IS participantID_task_GA (e.g., ARL1_7_IF_GA, ARL1_7_LCT_GA, etc.)
                        EEG = pop_saveset(EEG, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
    
                        clear n_fmri k onset_value offset_value baseline_method extra_data outfile; 

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TRIMMING
                        outfile = strcat(foldername, '_', subject, '_', run, '_', fileext, '_GA_trimmed');
                        if ~ischar(outfile)
                            outfile = convertStringsToChars(outfile);
                        end
                            
                        % REMOVE PRE-TASK DATA
                        % INSERT BOUNDARY AT [0.0001, start_of_fmri]
                        EEG = eeg_checkset(EEG);
                        EEG = pop_select(EEG, 'notime', [0.0001, round(start_of_fmri-2)]);
                        EEG = eeg_checkset(EEG);
                        eeglab redraw;
                        pause(1);
    
                        % SAVE DATASET. NAMING CONVENTION IS participantID_task_GA_trimmed (e.g., ARL1_7_IF_GA_trimmed)
                        EEG = pop_saveset(EEG, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
                        
                        clear outfile;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESAMPLING
                        outfile = strcat('sub', subject, '_r', run, '_raw');
                        if ~ischar(outfile)
                            outfile = convertStringsToChars(outfile);
                        end
                        
                        % RESAMPLE DATASET AT 500 Hz SO DATA IS SMALLER AND ANALYSIS IS QUICKER
                        freq = 500;
                        EEG = pop_resample(EEG, freq);
                        eeglab redraw;
                        pause(1);
    
                        clear freq; 
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FILTERING
    
                        % FILTER LOADED DATASET. LOWPASS AT 70 Hz, HIGHPASS AT .25 HZ cutoff
                        [EEG, com, b] = pop_eegfiltnew(EEG, 70, 0.25);
                        eeglab redraw;
                        pause(1);
    
                        % SAVE DATASET
                        % NAMING CONVENTION IS subNo_runNo_raw (e.g., sub07_r01_raw, sub07_r02_raw, etc.)
                        EEG = pop_saveset(EEG, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
                        
                        clear outfile;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FMRIB
                        outfile = strcat('sub', subject, '_r', run, '_eval');
                        if ~ischar(outfile)
                            outfile = convertStringsToChars(outfile);
                        end
    
                        % RUN FMRIB FOR BCGNET COMPARISON
                        ecgchan = 32;
                        [EEG, COM] = pop_fmrib_qrsdetect(EEG, ecgchan, 'qrs', 'no');
                        eeglab redraw;
                        pause(1);
                    
                        [EEG, COM] = pop_fmrib_pas(EEG, 'qrs', 'obs', 3);
                        eeglab redraw;
                        pause(1);
    
                        % SAVE DATASET IF ALL LOOKS GOOD
                        % NAMING CONVENTION IS subNo_runNo_raw_eval (e.g., sub07_r01_raw_eval, sub07_r02_raw_eval, etc.)
                        EEG = pop_saveset(EEG, outfile, outputpath, 'savemode', 'twofiles', 'version', '7.3');
    
                        clear ecgchan outfile;
                    end 
                end
                cd ..
            catch error

                % Output the error message that describes the error:
                fprintf(1,'There was an error! The message was:\n%s', error.message);
            end
        end
    end
    
    clear all;


