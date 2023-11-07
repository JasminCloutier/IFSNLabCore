function fmri_analyze(directory)
    % directory = pwd;
    % AIHSamb.txt onset missing for s13_02
    cd(directory)
    % GET ALL FILES IN RAW FOLDER
    all_raw = dir(strcat(directory,"/raw/s*"));
    % GET INDEX OF ALL FILES FLAGGED AS DIRECTORY (AKA, FOLDER)
    folder_index = [all_raw.isdir];
    % USE INDEX TO SUBSET ALL_FILES
    all_raw = all_raw(folder_index); 
    % SAVE FOLDER NAMES TO ARRAY
    all_raw = {all_raw.name};

    for i=1:length(all_raw)
        sid = all_raw{i};
        % Specify GLM file name
        glm_file_name = strcat('scripts/glm_file_', sid, '.m'); % 'scripts/glm_file.m';
        if ~exist(glm_file_name, "file")
            % Make params file
            glm_file = fopen(glm_file_name,'w');
            
            % User name
            fprintf(glm_file, strcat("glm.username = 'Richa';\n"));
    
            % GLM input/output directory
            fprintf(glm_file, strcat("glm.prep_name = 'epi_norm';\n"));
            fprintf(glm_file, strcat("glm.glm_name = 'glm_LCT';\n"));
            
            % GLM onsets directory name
            fprintf(glm_file, strcat("glm.ons_dir = '", sid, "';\n"));
            
            % GLM Conditions (cell arrays seperated by commas)
            fprintf(glm_file, strcat("glm.events = {'AIHSamb', 'AIHSunamb', 'AILSamb', 'AILSunamb', 'SHSamb', 'SHSunamb', 'SLSamb', 'SLSunamb', 'HHSamb', 'HHSunamb', 'HLSamb', 'HLSunamb', 'Feedback'};\n"));
            fprintf(glm_file, strcat("glm.blocks = {};\n"));
            fprintf(glm_file, strcat("glm.regressors = {};\n"));
            
            % GLM parameters
            fprintf(glm_file, strcat("glm.move = 0;\n"));
            fprintf(glm_file, strcat("glm.trends = 0;\n"));
            fprintf(glm_file, strcat("glm.hpf = 128;\n"));
            fprintf(glm_file, strcat("glm.autocorr = 'none';\n"));
            fprintf(glm_file, strcat("glm.hrf = 'hrf';\n"));         % Set to Finite Impulse Response for MIXED designs.
            fprintf(glm_file, strcat("glm.duration = 5.05;\n"));     % Event/Block Duration (same units as glm.time). 
            
            % GLM Parametric modualtors - Special keyword: 'allthethings'
            % fprintf(glm_file, strcat("glm.parametrics = {'Feedback'};\n")); 
    
            % GLM Contrasts - Numeric contrasts should sum to zero unless vs. baseline
            %               - String contrasts must match Condition names.
            %               - String contrast direction determine by the placement of 'vs.'
            %               - Special keywords: 'housewine' | 'fir_bins' | 'fir_hrf'
            
            fprintf(glm_file, strcat("glm.con.all_VS_baseline = [1 1 1 1 1 1 1 1 1 1 1 1 1 1];\n"));
            fprintf(glm_file, strcat("glm.con.highstatus_VS_baseline = [1 1 0 0 1 1 0 0 1 1 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.lowstatus_VS_baseline = [0 0 1 1 0 0 1 1 0 0 1 1 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.AI_VS_baseline = [1 1 1 1 0 0 0 0 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.symbol_VS_baseline = [0 0 0 0 1 1 1 1 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.human_VS_baseline = [0 0 0 0 0 0 0 0 1 1 1 1 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.nonhuman_VS_baseline = [1 1 1 1 1 1 1 1 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSAI_VS_baseline = [1 1 0 0 0 0 0 0 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.LSAI_VS_baseline = [0 0 1 1 0 0 0 0 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSS_VS_baseline = [0 0 0 0 1 1 0 0 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.LSS_VS_baseline = [0 0 0 0 0 0 1 1 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSH_VS_baseline = [0 0 0 0 0 0 0 0 1 1 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.LSH_VS_baseline = [0 0 0 0 0 0 0 0 0 0 1 1 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSAIamb_VS_baseline = [1 0 0 0 0 0 0 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSAIunamb_VS_baseline = [0 1 0 0 0 0 0 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.LSAIamb_VS_baseline = [0 0 1 0 0 0 0 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.LSAIunamb_VS_baseline = [0 0 0 1 0 0 0 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSSamb_VS_baseline = [0 0 0 0 1 0 0 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSSunamb_VS_baseline = [0 0 0 0 0 1 0 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.LSSamb_VS_baseline = [0 0 0 0 0 0 1 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.LSSunamb_VS_baseline = [0 0 0 0 0 0 0 1 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSHamb_VS_baseline = [0 0 0 0 0 0 0 0 1 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSHunamb_VS_baseline = [0 0 0 0 0 0 0 0 0 1 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.LSHamb_VS_baseline = [0 0 0 0 0 0 0 0 0 0 1 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.LSHunamb_VS_baseline = [0 0 0 0 0 0 0 0 0 0 0 1 0];\n"));
            fprintf(glm_file, strcat("glm.con.Feedback_VS_baseline = [0 0 0 0 0 0 0 0 0 0 0 0 1];\n"));
    
            % here are two ways to generate pmod contrasts
            % glm.con.feedback = 'Feedback'; % name of onset file for regressor modeled with parametric modulator
            % glm.con.humlike   = [0 1]; % can also enter pmod using array
            
            fprintf(glm_file, strcat("glm.con.amb_VS_unamb = [-0.5 0.5 -0.5 0.5 -0.5 0.5 -0.5 0.5 -0.5 0.5 -0.5 0.5 0];\n"));
            fprintf(glm_file, strcat("glm.con.human_VS_nonhuman = [-0.25 -0.25 -0.25 -0.25 -0.25 -0.25 -0.25 -0.25 0.5 0.5 0.5 0.5 0];\n"));
            fprintf(glm_file, strcat("glm.con.human_VS_AI = [-0.5 -0.5 -0.5 -0.5 0 0 0 0 0.5 0.5 0.5 0.5 0];\n"));
            fprintf(glm_file, strcat("glm.con.human_VS_symbol = [0 0 0 0 -0.5 -0.5 -0.5 -0.5 0.5 0.5 0.5 0.5 0];\n"));

            fprintf(glm_file, strcat("glm.con.highstatus_VS_lowstatus = [0.5 0.5 -0.5 -0.5 0.5 0.5 -0.5 -0.5 0.5 0.5 -0.5 -0.5 0];\n"));
            fprintf(glm_file, strcat("glm.con.AI_VS_symbol = [0.5 0.5 0.5 0.5 -0.5 -0.5 -0.5 -0.5 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSH_VS_LSH = [0 0 0 0 0 0 0 0 0.5 0.5 -0.5 -0.5 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSAI_VS_LSAI = [0.5 0.5 -0.5 -0.5 0 0 0 0 0 0 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSS_VS_LSS = [0 0 0 0 0.5 0.5 -0.5 -0.5 0 0 0 0 0];\n"));

            fprintf(glm_file, strcat("glm.con.HSH_VS_HSnonhuman = [-0.25 -0.25 0 0 -0.25 -0.25 0 0 0.5 0.5 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.LSH_VS_LSnonhuman = [0 0 -0.25 -0.25 0 0 -0.25 -0.25 0 0 0.5 0.5 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSH_VS_LSnonhuman = [0 0 -0.25 -0.25 0 0 -0.25 -0.25 0.5 0.5 0 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.LSH_VS_HSnonhuman = [-0.25 -0.25 0 0 -0.25 -0.25 0 0 0 0 0.5 0.5 0];\n"));

            fprintf(glm_file, strcat("glm.con.HSHamb_VS_LSHamb = [0 0 0 0 0 0 0 0 0.5 0 -0.5 0 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSHunamb_VS_LSHunamb = [0 0 0 0 0 0 0 0 0 0.5 0 -0.5 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSHamb_VS_LSHunamb = [0 0 0 0 0 0 0 0 0.5 0 0 -0.5 0];\n"));
            fprintf(glm_file, strcat("glm.con.HSHunamb_VS_LSHamb = [0 0 0 0 0 0 0 0 0 0.5 -0.5 0 0];\n"));

            % RFX Specification
            % Note that we "should" put the rfx specifications in a seperate file from the
            % glm, however to cut down on the number of parameter files and for historical
            % reasons (e.g., spm2w, spm8w) we tack the rfx specifications here.
            
            % The assignments below will run seperate random effects one-sample t-tests
            % on the conditions allVSbaseline and humVSall.
            fprintf(glm_file, strcat("glm.rfx_name = 'rfx';\n"));
            fprintf(glm_file, strcat("glm.rfx_conds = {'all_VS_baseline', 'highstatus_VS_baseline', 'lowstatus_VS_baseline', 'human_VS_baseline', 'nonhuman_VS_baseline', 'HSH_VS_baseline', 'LSH_VS_baseline', 'amb_VS_unamb', 'human_VS_nonhuman', 'highstatus_VS_lowstatus', 'HSH_VS_HSnonhuman', 'LSH_VS_LSnonhuman', 'HSH_VS_LSnonhuman', 'LSH_VS_HSnonhuman', 'HSH_VS_LSH', 'HSHamb_VS_LSHamb', 'HSHunamb_VS_LSHunamb', 'HSHamb_VS_LSHunamb', 'HSHunamb_VS_LSHamb'};\n"));
            fclose(glm_file);
    
            % Run GLM
            spm12w_glm_compute('sid', sid, ...
                'glm_file', fullfile(which(glm_file_name)))
        end
    end

    spm12w_glm_contrast('sid',sid, ...
    'glm_file',fullfile(which(glm_file_name)));
