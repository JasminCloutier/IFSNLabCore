SUB = {'S2', 'S3', 'S4', 'S8','S9', 'S10','S11', 'S12', 'S13', 'S14', 'S15', 'S16', 'S17', 'S18', 'S19','S20','S21','S22','S23','S24','S25','S26','S27','S28','S29','S30','S31','S32','S33','S34','S35','S36','S37','S38','S39','S40','S41','S42'};
numsubjects = length(SUB);  
parentfolder = 'C:\Users\Sam\Documents\MATLAB\RS-EEG_ReRun';


for i=1:numsubjects
   [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    Subject_Path = [parentfolder filesep SUB{i} filesep];
    
    EEG = pop_loadset( 'filename', [SUB{i} '_filt_ds_trimmed_interpolated_noblinks.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', [SUB{i} '_filt_ds_trimmed_interpolated_noblinks.set'], 'gui', 'off'); 


    % Rereference to average across the scalp
EEG = pop_reref( EEG, [],'exclude',[129:136] );
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
eeglab redraw
%%Bin assignment and Epoching

EEG  = pop_editeventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99}, 'BoundaryString', { 'boundary' }, 'List', 'C:\Users\Sam\Documents\MATLAB\RS-EEG_ReRun\RSEEGEventlist_NewTest.txt', 'SendEL2', 'EEG', 'UpdateEEG', 'codelabel', 'Warning',...
 'off' ); 
%Epoch
EEG = pop_epochbin( EEG , [-200.0  1000.0],  'pre');
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
eeglab redraw

%Trial level interpolation and flagging remaining noisy trials
[EEG, comrej]    = pop_eegmaxmin(EEG,[2:18 20:44 46:53 55:63 65:84 86:99 101:114 116:124 126:128],[-199.2188      998.0469],100,200,100,0);EEG = pop_TBT(EEG,EEG.reject.rejmaxminE,8,0.4,0);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%Moving Window Threshold
EEG  = pop_artmwppth( EEG , 'Channel',  1:128, 'Flag',  1, 'Threshold',  100, 'Twindow', [ -199.2 1000], 'Windowsize',  200, 'Windowstep',...
  100 ); 
%Simple Voltage Threshold
EEG  = pop_artextval( EEG , 'Channel',  1:128, 'Flag',  1, 'Threshold', [ -75 75], 'Twindow', [ -199.2 1000] );

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', [SUB{i} '_Cleaned'], 'savenew', [Subject_Path SUB{i} '_Cleaned.set'], 'gui', 'off'); 

%Generate Averaged ERPs
ERP = pop_averager(ALLEEG , 'Criterion', 'good', 'DQ_flag', 1, 'DSindex', [CURRENTSET], 'ExcludeBoundary', 'on', 'SEM', 'on' );
ERP = pop_savemyerp( ERP, 'erpname', [SUB{i} 'ERPs'], 'filename', [Subject_Path SUB{i} '.erp']);
ERP = pop_savemyerp( ERP, 'erpname', [SUB{i} 'ERPs'], 'filename', [parentfolder SUB{i} '.erp']);
% Create Text file summarizing lost trials, you will not be able to distinguish how many trials were lost during each step using this. You will only see the total number of trials that were marked as bad.
EEG = pop_summary_AR_eeg_detection(EEG, [Subject_Path SUB{i} '_Total_Trials.txt']);

    end;