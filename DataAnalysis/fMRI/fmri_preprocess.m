function fmri_preprocess(prep_name, username, unwarp, normalize, smoothing, ...
    slicetime, scans_or_secs)
    % directory = directory where all the zipped dicoms are
    % filename = common suffix in the name of the files. E.g., "LCT"
    % prep_name = name of folder for prepared files. E.g., 'epi_norm'
    % username = who is the user?
    % unwarp = correct field inhomogeneties yes (1) or no (0)
    % normalize = normalize type ('none','epi','spm12','dartel')
    % smoothing = smoothing no (0) or yes (provide size of smoothing kernel in FWHM)
    % slicetime = slicetime correction yes (1) or no (0)
    % scans_or_secs = 'scans' or 'sec'/'ms'
    % log = args of participants - run pairs that need to be excluded

    directory = pwd;

    % COLLECT ALL ZIPPED FOLDERS IN ZIP DIRECTORY
    all_targz = dir(strcat(directory,"/arch/dicom/*.tar.gz"));
    all_targz = {all_targz.name};

    % COLLECT ALL PREPPED FOLDERS IN PREP DIRECTORY
    prepped = dir(strcat(directory,"/prep/epi_norm/s*"));
    prepped = {prepped.name};

    % LOOP THROUGH EACH FILE TO PROCESS
    for zipfile=1:length(all_targz)
        scannerid = all_targz{zipfile};
        scannerid = erase(scannerid, ".tar.gz");
        scannerid = erase(scannerid, "dicom_");
        zipfile_parts = split(scannerid, '_');
        if length(zipfile_parts) < 3
            sid = convertStringsToChars(sprintf("s%02d", str2num(zipfile_parts{2})));
        else
            sid = convertStringsToChars(sprintf("s%02d_%02d", str2num(zipfile_parts{2}), str2num(zipfile_parts{3})));
        end
        
        if ~any(strcmp(prepped, sid))
           spm12w_prepare("scannerid", scannerid, "sid", sid, ...
            "rawformat", "dicom");

            % Make params file
            p_file_name = strcat('scripts/p_file_', sid, '.m');
            p_file = fopen(p_file_name,'w'); 
            fprintf(p_file, strcat("p.prep_name = '", prep_name, "';"));
            fprintf(p_file, "\n");
            fprintf(p_file, strcat("p.username = '", username, "';\n"));
            fprintf(p_file, 'p.unwarp = %d;', unwarp);
            fprintf(p_file, "\n");
            fprintf(p_file, strcat("p.normalize = '", normalize, "';\n"));
            fprintf(p_file, 'p.smoothing = %d;', smoothing);
            fprintf(p_file, "\n");
            fprintf(p_file, 'p.slicetime = %d;', slicetime);
            fprintf(p_file, "\n");
            fprintf(p_file, "p.sformula = 'regular';\n");
            fprintf(p_file, strcat("p.durtime = '", scans_or_secs, "';\n"));
            fprintf(p_file, strcat("p.time = '", scans_or_secs, "';\n"));
            fclose(p_file);
            
            % Preprocess
            spm12w('stage','prep', ...
            'sids',{sid}, ...
            'para_file',{fullfile(which(p_file_name))});
       end
    end

