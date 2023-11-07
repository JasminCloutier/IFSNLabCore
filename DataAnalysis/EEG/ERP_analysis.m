function erp_analysis(folderpath, foldername, components)

% LOAD DATASET

% ASSIGN EVENT CODES TO BINS
EEG  = pop_editeventlist(EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99}, 'BoundaryString', { 'boundary' }, 'List','F:\Sam_ARL_IF_QA\Eventlist.txt', 'SendEL2', 'EEG', 'UpdateEEG', 'askUser', 'Warning', 'on');

% CREATE EPOCHS
EEG = pop_epochbin( EEG , [-200.0  1000.0],  'pre');
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
eeglab redraw;

% TRIAL LEVEL INTERPOLATION
% FLAG ANY REMAINING NOISY TRIALS
[EEG, comrej] = pop_eegmaxmin(EEG,[1:16,21:31,33:58,61:64],[-200  998],100,200,100,0);
EEG = pop_TBT(EEG,EEG.reject.rejmaxminE,4,0.3,0);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

% MOVING WINDOW THRESHOLD
EEG  = pop_artmwppth( EEG , 'Channel',  [1:31,33:64], 'Flag',  1, 'Threshold',  100, 'Twindow', [ -200 1000], 'Windowsize',  200, 'Windowstep', 100 ); 
% SIMPLE VOLTAGE THRESHOLD
EEG  = pop_artextval( EEG , 'Channel', [1:31,33:64], 'Flag',  1, 'Threshold', [ -75 75], 'Twindow', [ -200 1000] );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 7, 'setname', [SUB{i} '_Cleaned'], 'savenew', [Subject_Path SUB{i} '_Cleaned.set'], 'gui', 'off'); 

% GENERATE AVERAGED ERPS
ERP = pop_averager(ALLEEG , 'Criterion', 'good', 'DQ_flag', 1, 'DSindex', [CURRENTSET], 'ExcludeBoundary', 'on', 'SEM', 'on' );
ERP = pop_savemyerp( ERP, 'erpname', [SUB{i} 'ERPs'], 'filename', [Subject_Path SUB{i} '.erp']);
ERP = pop_savemyerp( ERP, 'erpname', [SUB{i} 'ERPs'], 'filename', [parentfolder SUB{i} '.erp']);

% CREATE TXT FILE OF TRIALS SKIPPED DUE TO BAD DATA
% YOU WILL NOT BE ABLE TO SEE HOW MANY TRIALS WERE SKIPPED AT EACH STEP, ONLY THE TOTAL NUMBER OF TRIALS SKIPPED
EEG = pop_summary_AR_eeg_detection(EEG, [Subject_Path SUB{i} '_Total_Trials.txt']);

% MEASUREMENT PARAMETERES FOR EACH COMPONENT SPECIFIED
% P200
ALLERP = pop_geterpvalues( 'D:\RS-EEG\Data\EEGData\EEG_Data\GA26_Confirmatory_List.txt', [ 150 250],  1:8, [ 1 19 21 45 54 68 85:15:115] , 'Baseline', 'pre','Binlabel', 'on', 'FileFormat', 'long', 'Filename', 'D:\RS-EEG\Data\EEGData\EEG_Data\P200.xls', 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peakampbl', 'Mlabel', 'P200', 'Neighborhood',  5, 'PeakOnset',  1, 'Peakpolarity', 'positive', 'Peakreplace', 'absolute', 'Resolution', 3 );

% N200
ALLERP = pop_geterpvalues( 'D:\RS-EEG\Data\EEGData\EEG_Data\GA26_Confirmatory_List.txt', [ 170 270],  1:8, [ 1 19 21 45 54 68 85:15:115] , 'Baseline', 'pre','Binlabel', 'on', 'FileFormat', 'long', 'Filename', 'D:\RS-EEG\Data\EEGData\EEG_Data\N200.xls', 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'peakampbl', 'Mlabel', 'N200', 'Neighborhood',  5, 'PeakOnset',  1, 'Peakpolarity', 'negative', 'Peakreplace', 'absolute', 'Resolution', 3 );

% P300A
ALLERP = pop_geterpvalues( 'D:\RS-EEG\Data\EEGData\EEG_Data\GA26_Confirmatory_List.txt', [ 250 350],  1:8, [ 1 19 21 45 54 68 85:15:115] , 'Baseline', 'pre', 'Binlabel', 'on', 'FileFormat', 'long', 'Filename', 'D:\RS-EEG\Data\EEGData\EEG_Data\P300A.xls', 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'Mlabel', 'P300A', 'PeakOnset',  1, 'Resolution',  3 );

% P300B
ALLERP = pop_geterpvalues( 'D:\RS-EEG\Data\EEGData\EEG_Data\GA26_Confirmatory_List.txt', [ 360 660],  1:8, [ 1 19 21 45 54 68 85:15:115] , 'Baseline', 'pre', 'Binlabel', 'on', 'FileFormat', 'long', 'Filename', 'D:\RS-EEG\Data\EEGData\EEG_Data\P300B.xls', 'Fracreplace', 'NaN', 'InterpFactor', 1, 'Measure', 'meanbl', 'Mlabel', 'P300B', 'PeakOnset',  1, 'Resolution',  3 );
