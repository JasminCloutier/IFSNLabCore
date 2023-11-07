SUB = {'S2', 'S3', 'S4', 'S8','S9', 'S10','S11', 'S12', 'S13', 'S14', 'S15', 'S16', 'S17', 'S18', 'S19','S20','S21','S22','S23','S24','S25','S26','S27','S28','S29','S30','S31','S32','S33','S34','S35','S36','S37','S38','S39','S40','S41','S42'};
numsubjects = length(SUB);  
parentfolder = 'C:\Users\Sam\Documents\MATLAB\RS-EEG_ReRun';

for i=1:numsubjects
   [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    Subject_Path = [parentfolder filesep SUB{i} filesep];
    
     EEG = pop_loadset( 'filename', [SUB{i} '_filt_ds_trimmed_interpolated.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', [SUB{i} '_filt_ds_trimmed_interpolated.set'], 'gui', 'off'); 

EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on','pca',135);
EEG = eeg_checkset(EEG);
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', [SUB{i} '_PostICA'], 'savenew', [Subject_Path SUB{i} '_PostICA.set'], 'gui', 'off'); 


%Load in Post-ICA sets if needed
%     EEG = pop_loadset( 'filename', [SUB{i} '_PostICA.set'], 'filepath', Subject_Path);
%    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', [SUB{i} '_PostICA.set'], 'gui', 'off'); 



% Noisey component identification and removal

EEG = pop_iclabel(EEG, 'default');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
eeglab redraw

% icablinkmetrics implementation
% Find Eye Blink Component(s)

EEG.icaquant = icablinkmetrics(EEG,'ArtifactChannel', ...
 EEG.data(find(strcmp({EEG.chanlocs.labels},'IO1')),:),'VisualizeData','True');
disp('ICA Metrics are located in: EEG.icaquant.metrics')
disp('Selected ICA component(s) are located in: EEG.icaquant.identifiedcomponents')
[~,index] = sortrows([EEG.icaquant.metrics.convolution].');
EEG.icaquant.metrics = EEG.icaquant.metrics(index(end:-1:1)); clear index
% Remove Artifact ICA component(s)
EEG = pop_subcomp(EEG,EEG.icaquant.identifiedcomponents,0);

%Flag and remove remaining bad components
EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;0.9 1;0.9 1;0.9 1;NaN NaN]);
EEG = pop_subcomp(EEG, '' ,0 ,0);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3, 'setname', [SUB{i} '_filt_ds_trimmed_interpolated_noblinks'], 'savenew', [Subject_Path SUB{i} '_filt_ds_trimmed_interpolated_noblinks.set'], 'gui', 'off'); 



end;