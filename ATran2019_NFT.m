Info.time = datestr(now,30); % 'dd-mmm-yyyy HH:MM:SS'
Info.date = date; % day, month, year

Info.electrode_locs = 'XXX'; %18 channel active electrodes
Info.chanlocs = readlocs(Info.electrode_locs,'filetype','autodetect');
%% Get channel indices
Info.n_elect = 1:32; %list of every electrode collecting brain data
Info.refelec = 10; %which electrode do you want to re-reference to?
%//////////////////////////////////////////////////////////////////////////

dirChange = 1;


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%%                        Open Data Streams
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% instantiate the library
disp('Loading the library...');
lib = lsl_loadlib();

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Resolve an EEG stream...
disp('Resolving an EEG stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); %find the EEG stream from BrainVision RDA
end
%create a new EEG inlet
disp('Good job! Opening a EEG inlet...');
inlet_EEG = lsl_inlet(result{1});

% Feedback drawing
delta = 720; 
baseRect = [0 delta screenX screenY]; %(left,top,right,bottom)
maxChange = 3; %change of feedback bar

% Make a base Rect to use for the base line marker 
baseRect2 = [0 0 12 12];
% Screen X positions of our baseline squares
squareXpos = (screenX * 0.0):30:(screenX * 1.0);
numSqaures = length(squareXpos);
squareYpos = screenY * 0.5; % not sure this is currently doing anything 

% Make our rectangle coordinates --> not a clue what this does yet
allRects = nan(4, 3);
for i = 1:numSqaures
    allRects(:, i) = CenterRectOnPointd(baseRect2, squareXpos(i), squareYpos); 
end


% HideCursor; %comment out when debugging

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%%                     Data Acquisition Parameters
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

srate        = 500; %1000
srate_Amp    = 500; %1000 sampling rate of the amplifier
nfft         = 2^10; %srate = 500 then 0.5 Hz resolution
windowSize   = 500; % 1 sec; 1/2 second
windowInc    = 125; % 1/4; update every 1/2 second
chans        = Info.n_elect; % channel streaming data from
dataBuffer   = zeros(length(chans),(windowSize*6)/srate*srate_Amp);
dataBufferPointer = 1;

% Frequencies for spectral decomposition
freqband  = [8 13]; % alpha
freqs     = linspace(0, srate/2, floor(nfft/2)+1);
freqs     = freqs(2:end); % remove DC (match the output of PSD)
freqRange = intersect(find(freqs >= freqband(1)), find(freqs <= freqband(2)));
freqall   = [0.5 30]; % for EEG amplitude
freqRangeall = intersect(find(freqs >= freqall(1)), find(freqs <= freqall(2)));

% Selects electrode for feedback
selchan1 = 7; %F3
selchan2 = 8; %F4
mask = zeros(length(chans),1)';
mask(selchan1) = 1; %select F3
mask(selchan2) = 1; %select F4


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% #########################################################################
%%                    Deal with Incoming EEG Data
% #########################################################################
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Fill the EEG data structure (for eeglab)
EEG          = eeg_emptyset; 
EEG.nbchan   = length(chans);
EEG.srate    = srate;
EEG.xmin     = 0;
EEG.chanlocs = Info.chanlocs;
state = []; %for use with BCILab functions 

winPerSec = windowSize/windowInc;
chunkSize = windowInc*srate_Amp/srate; % at 500 so every 1/4 second is 125 samples

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sessionDuration = 60*5; % in seconds  60*5 = 5 mins
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% figure %open new figure

% Save processed data
chunkPower    = zeros(1, sessionDuration*10);
chunkAmp2     = zeros(1, sessionDuration*10);

amp1          = {};
amp_mean      = zeros(1, sessionDuration*10);
pxx           = {};
f             = {};
PSD           = {};
fq            = {};
PSD2          = {};
fq2           = {};
amp_mean_all  = zeros(1, sessionDuration*10);
Rel_Amp       = zeros(1, sessionDuration*10);
chunkMarker   = zeros(1, sessionDuration*10);
all_dirChange = zeros(1, sessionDuration*10);

dataAccu = zeros(length(chans),(sessionDuration+3)*srate);    
dataAccuPointer = 1; 

chunkCount = 1; % Keep track of number of data chunks

tic; % start timer

%% ========================================================================
                        %%%%%%%%%%%%%%%%%%%%%%
                        % Neurofeedback loop %
                        %%%%%%%%%%%%%%%%%%%%%%
% =========================================================================
while toc < sessionDuration
    
    % Get chunk from the EEG inlet
    [chunk,stamps] = inlet_EEG.pull_chunk();
    
    % Fill buffer
    if ~isempty(chunk) && size(chunk,2) > 1
        
%         chunk = filter(B,1,chunk,srate,2);
        
        if dataBufferPointer + size(chunk,2) > size(dataBuffer,2)
            disp('Buffer overrun');
            dataBuffer(:,dataBufferPointer:end) = chunk(chans,1:(size(dataBuffer,2)-dataBufferPointer+1));
            dataBufferPointer = size(dataBuffer,2);
        else
            dataBuffer(:,dataBufferPointer:dataBufferPointer+size(chunk,2)-1) = chunk(chans,:);
            dataBufferPointer = dataBufferPointer+size(chunk,2);
        end
        
    end
    
    
    % Fill EEG.data
    if dataBufferPointer > chunkSize*winPerSec
        
        % empty buffer based on specified sample rate
        if srate_Amp == srate
                EEG.data = dataBuffer(:,1:chunkSize*winPerSec);   
            elseif srate_Amp == 2*srate
                EEG.data = dataBuffer(:,1:2:chunkSize*winPerSec);
            elseif srate_Amp == 4*srate
                EEG.data = dataBuffer(:,1:4:chunkSize*winPerSec);
            elseif srate_Amp == 8*srate
                EEG.data = dataBuffer(:,1:8:chunkSize*winPerSec);
        else
            error('Cannot convert sampling rate')
        end
        
        % Shift buffer 1 block
        dataBuffer(:,1:chunkSize*(winPerSec-1)) = dataBuffer(:,chunkSize+1:chunkSize*winPerSec);
        dataBufferPointer = dataBufferPointer-chunkSize;
        
        
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % Processing Streaming Data
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
        % Arithmetically rereference to linked mastoid (M1 + M2)/2
        for x = 1:size(EEG.data,1)-2 % excluding EOGs
            EEG.data(x,:) = (EEG.data(x,:)-((EEG.data(Info.refelec,:))*.5));
        end
        clear x

%         % Correct for EOG artifacts
%         EEG = online_filt_EOG(EEG);
        
        % Filter data
        EEG.pnts = size(EEG.data,2);
        EEG.nchan = size(EEG.data,1);
        EEG.xmax = EEG.pnts/srate;
%         EEG.data = filter(B,1,EEG.data,srate,2); %band-pass filter
%         [EEG,state] = exp_eval(flt_fir('signal',EEG,'fspec',[0.5 1],'fmode','highpass','ftype','minimum-phase','state',state));
        [EEG_temp, state] = hlp_scope({'disable_expressions',true},@flt_fir,'signal',EEG,'fspec',[0.5 1],'fmode','highpass','ftype','minimum-phase', 'state', state);
        EEG = EEG_temp.parts{1,2}; %put filtered data back into EEG structure
        clear EEG_temp
        
%         
%         % apply ASR and update state
%         [EEG.data stateASR]= asr_process(EEG.data, EEG.srate, stateASR);
        
        % accumulate data to save it
        dataAccu(:, dataAccuPointer:dataAccuPointer+size(EEG.data,2)-1) = EEG.data;
        dataAccuPointer = dataAccuPointer + size(EEG.data,2);
        chunkMarker(chunkCount) = dataAccuPointer;

        
        % ------- Get measure of alpha power ------
        
        % Apply linear transformation (get channel Pz at that point)
        ICAact1 = mask1*EEG.data;
        ICAact2 = mask2*EEG.data;
        % Perform spectral decomposition
        X1data = fft(ICAact1, nfft);
        X2data = fft(ICAact2, nfft);
        % extract amplitude F3 using Pythagorian theorem
        amp1{chunkCount} = 2*(sqrt( imag(X1data/nfft).^2 + real(X1data/nfft).^2 ));
        amp1_tmp = amp1{chunkCount}(freqRange);
        amp1_mean(chunkCount) = mean(amp1_tmp); %mean alpha amp
        X1=mean(amp1_tmp);
        % extract amplitude F4 using Pythagorian theorem
        amp2{chunkCount} = 2*(sqrt( imag(X2data/nfft).^2 + real(X2data/nfft).^2 ));
        amp2_tmp = amp2{chunkCount}(freqRange);
        amp2_mean(chunkCount) = mean(amp2_tmp); %mean alpha amp
        X1=mean(amp2_tmp);


        FalphR(chunkCount) = X1;
        FalphL(chunkCount) = X2;
       
               
        % ---------------------------------------------------------
        
        
        %%%%%%%% Feedback %%%%%%%%%%%%%%
        alphaR = FalphR(chunkCount);
        alphaL = FalphL(chunkCount);
            if alphaR > alphaL
                delta = delta - maxChange;
                if delta > maxChange %not at top of screen
                    baseRect = [0 delta 2160 1440];
                    dirChange = 1;
                else
                    delta = delta + maxChange;
                    baseRect = [0 maxChange 2160 1440];
                    dirChange = 0;
                end
            elseif alphaL < alphaR 
                delta = delta + maxChange;
                if delta < screenY %not at bottom of screen
                    baseRect = [0 delta 2160 1440];
                    dirChange = 2;
                else
                    delta = delta - maxChange;
                    baseRect = [0 delta 2160 1440];
                    dirChange = 0;
                end
            else
                delta = delta;
                baseRect = [0 delta 2160 1440];
                dirChange = 0;
            end
        clear alphaR
        clear alphaL
        
        
        % set the fill color to blue
%         fillColor = orange.*255;
        fillColor = white;
        baselineColor = blue.*255;
        % center the square (middle of the screen)
        CenterRectOnPointd(baseRect, xCenter, yCenter);

        % Draw the rect to the screen
        Screen('FillRect', nwind, fillColor, baseRect);
        Screen('FillRect', nwind, baselineColor, allRects);
                
        Screen('Flip', onScreen); % Flip to the screen

        all_dirChange(chunkCount) = dirChange; %save direction of change
        
%         WaitSecs(0.1) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Plot processed data
%         gcf; plot(f{chunkCount},10*log10(pxx{chunkCount}))
%         grid
%         xlim([0 30])
%         drawnow % update figure
        
        WaitSecs(0.005);
        
        chunkCount = chunkCount + 1; %keep track of number of data chunks
        
   
    
end
% =========================================================================
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% =========================================================================

Screen('FillRect', nwind, grey);
%IOPort_Trigger
Screen('Flip', nwind); %flip it to the screen

Screen('FillRect',nwind,grey);
Screen('TextSize',nwind,fontsize);
DrawFormattedText(nwind, ['You have completed the neurofeedback training session.'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  WaitSecs(2);
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen

WaitSecs(0.5) 
KbStrokeWait; %wait for subject to press button

ShowCursor;
Screen('Close',nwind);

% /////////////////////////////////////////////////////////////////////////
%% Close EEG stream
lsl_close_inlet(inlet_EEG);
% lsl_close_inlet(inlet_marker);
% /////////////////////////////////////////////////////////////////////////
%% Save data
NF_FileName = fullfile(['XXX' Info.subjID], [date '_NFTraining_Session' Info.train '_cond' Info.condition '.mat']);
save(NF_FileName);
% /////////////////////////////////////////////////////////////////////////



















