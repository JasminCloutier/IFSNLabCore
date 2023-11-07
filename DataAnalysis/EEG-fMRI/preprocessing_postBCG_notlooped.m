%Load in cleaned EEG .Mat file. Make sure the chanlocs file is in the
%active directory
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_importdata('dataformat','matlab','nbchan',0,'data','F:\\Sam_ARL_IF_QA\\BCGNetCleaned\\rescaled__sub40_r01_bcgnet.mat','srate',500,'pnts',0,'xmin',0,'chanlocs','F:\\Sam_ARL_IF_QA\\bvchan.ced');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','ARLTest','gui','off'); 
EEG = eeg_checkset( EEG );
eeglab redraw;

%Bcgnet rescaler
bcgnet_rescaler;

%Export events
pop_expevents(EEG, 'C:\Users\Sam\Desktop\Events\ARL1_40_event.txt', 'samples');

% I wasn't sure the best way to implement the R cleaning script since my
% loops are a bit different than the format we need to use

%Import cleaned events
EEG = pop_importevent( EEG, 'event','F:\\Sam_ARL_IF_QA\\ARL1_40\\Clean_ARL1_40_event.txt','fields',{'latency','duration','type'},'skipline',1,'timeunit',NaN);

%Save Dataset as Projectname_Ps#_ Task code_fmricleaned  
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', [SUB{i} 'LCT_fmricleaned '], 'savenew', [Subject_Path SUB{i} 'LCT_fmricleaned.set'], 'gui', 'off'); 

%%Filtering
%Notch Filter (Not required but a good sanity check nonetheless):
EEG  = pop_basicfilter( EEG,  1:64 , 'Boundary', 'boundary', 'Cutoff',  60, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',...
  180 );
%Butterworth Filter:
EEG  = pop_basicfilter( EEG,  1:64 , 'Boundary', 'boundary', 'Cutoff', [ 0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',...
  2 ); 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',[SUB{i} 'LCT_fmricleaned_filt'],'savenew',[Subject_Path SUB{i} 'LCT_fmricleaned_filt.set'] ,'gui','off'); 

%Channel level interpolation

  %Interpolate channel(s) specified in Excel file Interpolate_Channels_RSEEG.xls; any channels without channel locations (e.g., the eye channels) should not be included in the interpolation process and are listed in ignored channels
    %EEG channels that will later be used for measurement of the ERPs should not be interpolated
    %The ignored channels should be correct for Brainvision but it might be
    %worth triple checking
    ignored_channels = [17:20, 32,59:60];        
    DimensionsOfFile1 = size(alldata1);
    for j = 1:DimensionsOfFile1(1);
        if isequal(SUB{i},num2str(alldata1{j,1}));
           badchans = (alldata1{j,2});
           if ~isequal(badchans,'none') | ~isempty(badchans)
           	  if ~isnumeric(badchans)
                 badchans = str2num(badchans);
              end
              EEG  = pop_erplabInterpolateElectrodes( EEG , 'displayEEG',  0, 'ignoreChannels',  ignored_channels, 'interpolationMethod', 'spherical', 'replaceChannels', badchans);
           end
           [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4, 'setname', [SUB{i} 'channel_interpolated'], 'savenew', [Subject_Path SUB{i} 'channel_interpolated.set'], 'gui', 'off'); 
        end
    end

end;

%ICA Decomposition
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5, 'setname', [SUB{i} '_PostICA'], 'savenew', [Subject_Path SUB{i} '_PostICA.set'], 'gui', 'off'); 

% Noisey component identification and removal

EEG = pop_iclabel(EEG, 'default');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
eeglab redraw


% icablinkmetrics implementation
% Find Eye Blink Component(s)
%Can use Fp2 as well if needed but FP1 should be fine across all
%participants
EEG.icaquant = icablinkmetrics(EEG,'ArtifactChannel', ...
 EEG.data(find(strcmp({EEG.chanlocs.labels},'Fp1')),:),'VisualizeData','TRUE');
disp('ICA Metrics are located in: EEG.icaquant.metrics')
disp('Selected ICA component(s) are located in: EEG.icaquant.identifiedcomponents')
[~,index] = sortrows([EEG.icaquant.metrics.convolution].');
EEG.icaquant.metrics = EEG.icaquant.metrics(index(end:-1:1)); clear index
eeglab redraw

% Remove Artifact ICA component(s)
EEG = pop_subcomp(EEG,EEG.icaquant.identifiedcomponents,0);

%Flag and remove remaining bad components
EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;0.9 1;0.9 1;0.9 1;0.9 1]);
EEG = pop_subcomp(EEG, '' ,0 ,0);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6, 'setname', [SUB{i} '_ICARemoved'], 'savenew', [Subject_Path SUB{i} '_ICARemoved.set'], 'gui', 'off'); 

%Assign event codes to bins 
EEG  = pop_editeventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99}, 'BoundaryString', { 'boundary' }, 'List',...
 'F:\Sam_ARL_IF_QA\Eventlist.txt', 'SendEL2', 'EEG', 'UpdateEEG', 'askUser', 'Warning', 'on' ); % GUI: 25-May-2022 13:57:18

%Create epochs (Not sure if this will be different for the LCT)
EEG = pop_epochbin( EEG , [-200.0  1000.0],  'pre');
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
eeglab redraw

%Trial level interpolation and flagging remaining noisy trials
[EEG, comrej]    = pop_eegmaxmin(EEG,[1:16,21:31,33:58,61:64],[-200  998],100,200,100,0);EEG = pop_TBT(EEG,EEG.reject.rejmaxminE,4,0.3,0);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%Moving Window Threshold
EEG  = pop_artmwppth( EEG , 'Channel',  [1:31,33:64], 'Flag',  1, 'Threshold',  100, 'Twindow', [ -200 1000], 'Windowsize',  200, 'Windowstep',...
  100 ); 
%Simple Voltage Threshold
EEG  = pop_artextval( EEG , 'Channel', [1:31,33:64], 'Flag',  1, 'Threshold', [ -75 75], 'Twindow', [ -200 1000] );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 7, 'setname', [SUB{i} '_Cleaned'], 'savenew', [Subject_Path SUB{i} '_Cleaned.set'], 'gui', 'off'); 

%Generate Averaged ERPs-- change path:
ERP = pop_averager(ALLEEG , 'Criterion', 'good', 'DQ_flag', 1, 'DSindex', [CURRENTSET], 'ExcludeBoundary', 'on', 'SEM', 'on' );
ERP = pop_savemyerp( ERP, 'erpname', [SUB{i} 'ERPs'], 'filename', [Subject_Path SUB{i} '.erp']);
ERP = pop_savemyerp( ERP, 'erpname', [SUB{i} 'ERPs'], 'filename', [parentfolder SUB{i} '.erp']);
% Create Text file summarizing lost trials, you will not be able to distinguish how many trials were lost during each step using this. You will only see the total number of trials that were marked as bad.
EEG = pop_summary_AR_eeg_detection(EEG, [Subject_Path SUB{i} '_Total_Trials.txt']);

%Once the .ERP files are generated and are in the same folder, you can
%create the grand averages and then measure the specific ERPs of interest
%using commands similar to these:

%P200 Measurement Parameters
ALLERP = pop_geterpvalues( 'D:\RS-EEG\Data\EEGData\EEG_Data\GA26_Confirmatory_List.txt', [ 150 250],  1:8, [ 1 19 21 45 54 68 85:15:115] , 'Baseline',...
 'pre','Binlabel', 'on', 'FileFormat', 'long', 'Filename', 'D:\RS-EEG\Data\EEGData\EEG_Data\P200.xls', 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure',...
 'peakampbl', 'Mlabel', 'P200', 'Neighborhood',  5, 'PeakOnset',  1, 'Peakpolarity', 'positive', 'Peakreplace', 'absolute', 'Resolution',...
  3 );

%N200 Measurement Parameters
ALLERP = pop_geterpvalues( 'D:\RS-EEG\Data\EEGData\EEG_Data\GA26_Confirmatory_List.txt', [ 170 270],  1:8, [ 1 19 21 45 54 68 85:15:115] , 'Baseline',...
 'pre','Binlabel', 'on', 'FileFormat', 'long', 'Filename', 'D:\RS-EEG\Data\EEGData\EEG_Data\N200.xls', 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure',...
 'peakampbl', 'Mlabel', 'N200', 'Neighborhood',  5, 'PeakOnset',  1, 'Peakpolarity', 'negative', 'Peakreplace', 'absolute', 'Resolution',...
  3 );

%Exploratory P300A Parameters
ALLERP = pop_geterpvalues( 'D:\RS-EEG\Data\EEGData\EEG_Data\GA26_Confirmatory_List.txt', [ 250 350],  1:8, [ 1 19 21 45 54 68 85:15:115] , 'Baseline',...
 'pre', 'Binlabel', 'on', 'FileFormat', 'long', 'Filename', 'D:\RS-EEG\Data\EEGData\EEG_Data\P300A.xls', 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure',...
 'meanbl', 'Mlabel', 'P300A', 'PeakOnset',  1, 'Resolution',  3 );

%Confirmatory P300B Parameters
ALLERP = pop_geterpvalues( 'D:\RS-EEG\Data\EEGData\EEG_Data\GA26_Confirmatory_List.txt', [ 360 660],  1:8, [ 1 19 21 45 54 68 85:15:115] , 'Baseline',...
 'pre', 'Binlabel', 'on', 'FileFormat', 'long', 'Filename', 'D:\RS-EEG\Data\EEGData\EEG_Data\P300B.xls', 'Fracreplace', 'NaN', 'InterpFactor',...
  1, 'Measure', 'meanbl', 'Mlabel', 'P300B', 'PeakOnset',  1, 'Resolution',  3 );
