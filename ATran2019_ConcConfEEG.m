clear all

close all

%% Operating Initializations for: Keyboard responses, Sounds, IOPort, Screen %%
%Setting up basic operations for MATLAB EEG Experiment
%Coded by Alex Tran, PhD, (c) 2018
%Questions? 9trana@gmail.com, a_tran@hotmail.com

%****Keyboard****%

%Sets the default numerical codes for each key button-press on the keyboard; 
KbName('UnifyKeyNames');

%Defines the 3 variables for: checking if the key is down, the time at 
%keyboard check, and numerical code of the key that was pressed
[keyIsDown,keysecs,keyCode]=KbCheck;
KbQueueCreate; 
KbQueueStart;


%****Sound****%

%Sound card preparation
InitializePsychSound;

%Sets a call-able handle 'audhand' to the audio operations
audhand = PsychPortAudio('Open', [], [], 0, 22050, 2);

%****IOPort****%

%Creates a virtual serial port with call-able handle 'TPort' based on COM3 
% (check in Device Manager what the identity of the serial port is when 
% connecting the trigger box to confirm)
[TPort]=IOPort('OpenSerialPort','COM3','FlowControl=Hardware(RTS/CTS lines) SendTimeout=1.0 StopBits=1');

%****Screen****%
%Defines the basic colours of the screen: white, grey and black
%Other colours MUST BE DEFINED if you would like to use them
white = WhiteIndex(0);
grey = white / 2;
black = BlackIndex(0);

%Initializes the screen, gives the screen the call-able handle 'nwind' and
%sets the variable 'rect' to be the screen resolution.
%rect is a 4-column variable with the 3rd-column being the width, and the 
%4th-column is the height it also fills the screen white (which was defined above)
[nwind, rect]=Screen('OpenWindow',0,white);

%Sets default text size for the 'nwind' screen handle
Screen('TextSize',nwind, 40);

%These variables determine the center of the screen based on the 'rect'
%variable and names them as v_res (vertical resolution) and h_res
%(horizontal), it also determines the center point of vertical and
%horizontal
v_res = rect(4);
h_res = rect(3);
v_center = v_res/2;
h_center = h_res/2;

%Assigns 'fixation' to be a variable representing the center of the screen
fixation = [h_center-10 v_center-10];

%% Pre-stimulus development of: Sounds, Triggers, Keyboard assignment, and Stroop Matrix %%
%Setting up P3a sound stimuli and Stroop keys
%Coded by Alex Tran, PhD, (c) 2018
%Questions? 9trana@gmail.com, a_tran@hotmail.com

%Read's .wav files, assigns them to a two-column variable, 'stndy' and
%'stly' and takes the frequency from the startle wave file
[stndy, ~] = psychwavread('Stim_eyesclosed.wav');
[stly, freq] = psychwavread('Stim_eyesopen.wav');

%Transposes the variables to a two-row variable to be read by the
%PsychAudioPort, as a two-column variable cannot be played as a sound
stnd=stndy';
stl=stly';

%Naming and assigning values to our triggers stimuli (they must be 8-bit 
%integers) for more help search the 'uint8' function; 
%Note: it creates an 8-bit value from the number you put in, however because 
%it only has a max of 8-bits, the triggers number inputs will not be the
%number you get as a trigger output (e.g., uint8(17) will not appear as the 
%trigger number 17)
trig1=uint8(1);
trig2=uint8(2);
trig3=uint8(5);
trig4=uint8(6);
trig5=uint8(10);
trig6=uint8(11);
trig7=uint8(15);
trig8=uint8(16);
trig9=uint8(3);
trig10=uint(4);
%% Actual Experiment %%

%Records when the experiment begins
studystarttime=Screen('Flip',nwind);

%Flushes and keyboard presses just in case, but should be none

%Sets the volume for this experiment for the audio handle 'audhand'
PsychPortAudio('Volume', audhand, 1);

m=3;%number of pages in consent form
%name of consent files

for i=1:m 
    icffile(i) = sprintf("C (%d).jpg",i);
    icfchar=char(icffile(1,i));
    icfo=imread(icfchar);
    icfimg{1,i}=imresize(icfo,0.45);
end

%%For-Loop that processes presents each page with a button press%%

DrawFormattedText(nwind,'Welcome to the Motivation and EEG Signals Experiment. \n \n If you have not already, please carefully read the consent form \n\n so that you fully understand your rights and role in this experiment.','center','center',black);
Screen('Flip', nwind);
KbStrokeWait;
Screen('DrawText',nwind,'When you are ready to begin, press any button.',fixation(1)-400,fixation(2)-100,black);
Screen('Flip', nwind);
KbStrokeWait;
% 
for i=1:m
    icfbuffer=Screen('MakeTexture', nwind, icfimg{1,i});
    Screen('DrawTexture', nwind, icfbuffer, [], [], 0);
    DrawFormattedText(nwind,'Press any key for the next page.', ['center'],[v_res-50]);
    Screen('Flip',nwind);
    KbStrokeWait;
    WaitSecs(0.5);
end

consent = BinaryQuestion(nwind, black, grey, 'I, the participant, consent to participate in this study.', 'Yes', 'No');
if consent == 2;
    sca;
end

%LFA BLOCK
%Draws text instructions on to the screen buffer (not yet shown)
DrawFormattedText(nwind, 'First we will begin with a resting EEG measure. \n \n You will be given a fixation cross, please keep your eyes fixed on the central cross the entire time.',  'center'  ,'center', black)
Screen('DrawText',nwind,'When you are ready to begin, press any button.',fixation(1)-410,fixation(2)+125,black);
Screen('Flip', nwind);
KbStrokeWait;
%IOPort('Write',TPort,uint8(0));
%Draws a fixation cross using our text size specifications on
%initialization on to the screen buffer (not yet shown)
DrawFormattedText(nwind, '+',  'center'  ,'center', black);
Screen('Flip', nwind);
%IOPort('Write',TPort,trig1);
WaitSecs(120);
%IOPort('Write',TPort,uint8(0));
Screen('FillRect', nwind, white, rect);
Screen('Flip', nwind,[],0); % clear screen
DrawFormattedText(nwind, 'You''ve completed an ''eyes open'' baseline measure. \n Press any button to continue to an ''eyes closed'' baseline measure.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbStrokeWait();
PsychPortAudio('FillBuffer', audhand, stnd);  
PsychPortAudio('Start', audhand, 1, 0, 1);
%IOPort('Write',TPort,trig2);
WaitSecs(120);
PsychPortAudio('FillBuffer', audhand, stl);  
PsychPortAudio('Start', audhand, 1, 0, 1);
%IOPort('Write',TPort,uint8(0));
Screen('FillRect', nwind, white, rect);
Screen('Flip', nwind,[],0); % clear screen
DrawFormattedText(nwind, 'You''ve completed the baseline calibration measure. \n Press any button to continue the experiment.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbStrokeWait();


%%Demographics

% Age, Gender, ethnicity
age = OpenResponseQuestion(nwind, black, white, 'What is your age?', 1);
Screen('Flip', nwind,[],1); % clear screen

gender = Likert(nwind, black,'What is your gender?', 'Male', 'Other', ...
    grey, 3, 'Female', black,[]);
    if gender == 3;
    genderoth = OpenResponseQuestion(nwind, black, white, 'What gender do you identify with?', 1);
    Screen('Flip', nwind,[],1); % clear screen
    end
ethnicity = OpenResponseQuestion(nwind, black, white, 'Please describe your ethnicity (e.g., Caucasian, African American, East Asian[Chinese Japanese etc.]). | If you are unsure, just type unknown.', 1);
Screen('Flip', nwind,[],1); % clear screen

%SC Habits
gradeavg = OpenResponseQuestion(nwind, black, white, 'On a scale of 0 to 100, on average what were your grades like in high school or University/college?', 1);
Screen('Flip', nwind,[],1); % clear screen
excurr = BinaryQuestion(nwind, black, grey, 'Have you engaged in extra-curricular activities outside of your primary career | (e.g., recreational sports teams, volunteering, addtional schooling or course work)?', 'Yes', 'No');
Screen('Flip', nwind,[],1); % clear screen
if excurr == 1;
    % yes extra curricular
    hrsexcurr = OpenResponseQuestion(nwind, black, white, 'How many hours a week do you commit to these activities on average?', 1);
    Screen('Flip', nwind,[],1); % clear screen
end
DrawFormattedText(nwind,'You will now answer some questions about your personality, attitudes and behaviours. \n \n Read each item carefully but do not over think your response \n\n just go with your gut reaction to each item. \n\n Press any key to continue.','center','center',black);
Screen('Flip', nwind);
KbStrokeWait;
 Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
    
    scspend{1} = 'I regularly put aside money for my future.';
    scspend{2} = 'Even if I don''t have an income, I enjoy spending money.';
    scspend{3} = 'I like to spend money on impulse.';
    scspend{4} = 'I carefully monitor my spending.';
    scspend{5} = 'I can sometimes overspend without thinking.';

i=1;


for i=1:5
    Likert(nwind, black, scspend{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    dvspnd{1,i}=['scspend' num2str(i)];
    dvspnd{2,i}=ans;
end


    
    scclean{1} = 'I sometimes procrastinate chores to engage in leisure activities.';
    scclean{2} = 'I spend at least an hour of my free-time time each day doing chores.';
    scclean{3} = 'I often ''binge''-clean large portions of my space in a single day.';
    scclean{4} = 'I prefer to incrementally clean.';
    scclean{5} = 'I have a hard time focusing on mundane tasks.';

i=1;



for i=1:5
    Likert(nwind, black, scclean{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    dvsccln{1,i}=['scclean' num2str(i)];    
    dvsccln{2,i}=ans;
end

%General Health Items
nutrition = Likert(nwind, black,'How satisfied are you with your current nutrition (eating well, drinking lots of water, etc.)?', 'Extremely dissatisfied', 'Extremely satisfied', ...
    grey, 5, 'Neither satisfied nor dissatisfied', black,[]);

satisfit = Likert(nwind, black,'How satisfied are you with your current level of fitness?', 'Extremely dissatisfied', 'Extremely satisfied', ...
    grey, 5, 'Neither satisfied nor dissatisfied', black,[]);

fit = Likert(nwind, black,'How ''fit'' would you say you are right now?', 'Extremely unfit', 'Extremely fit', ...
    grey, 5, 'Neither fit nor unfit', black,[]);

ex_week = Likert(nwind, black,'In a typical week for you, how many days do you engage in some form of exercise?', 'Once a week or less', '4 or more times a week', ...
    grey, 3, '2-3 times a week', black,[]);

ex_sess = OpenResponseQuestion(nwind, black, white, 'In a typical exercise session, how many minutes do you exercise for?', 1);
    Screen('Flip', nwind,[],1); % clear screen

%ex_intens = Likert(nwind, black,'When you do exercise, what is your average intensity?', 'Light - Minimal Effort(e.g., yoga, archery, fishing, bowling, horseshoes, golf, snow-mobiling, easy walking)', 'Strenuous - Rapid heart beat(e.g., running, jogging, hockey, football, soccer, squash, basketball, cross country skiing, judo, roller skating, vigorous swimming, vigorous long distance bicycling, skating)', ...
    %grey, 3, 'Moderate - Not Exhausting(e.g., fast walking, weight-training, baseball, tennis, easy bicycling, volleyball, badminton, easy swimming, alpine skiing, dancing)', black,[]);

%Scheduling SE

DrawFormattedText(nwind, ['The following items reflect situations that are listed as common reasons for preventing \n \n individuals from participating in exercise sessions or in some cases, \n \n dropping out. ' ...
'Using the scales below, please indicate \n \n how confident you are that you would exercise in the event \n \n that any of the following circumstances were to occur. \n \n'...
'Press any key to being. \n \n I believe that I could exercise 3 times per week for the next 3 months if:'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  KbStrokeWait();
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
  
   
    scheSE{1} = 'I believe that I could exercise 3 times per week for the next 3 months if: | The weather was very bad (hot, humid, rainy, cold, snowy).';
    scheSE{2} = 'I believe that I could exercise 3 times per week for the next 3 months if: | I was bored by the exercise program or activity.';
    scheSE{3} = 'I believe that I could exercise 3 times per week for the next 3 months if: | I was on vacation.';
    scheSE{4} = 'I believe that I could exercise 3 times per week for the next 3 months if: | I was not interested in the exercise program or activity.';
    scheSE{5} = 'I believe that I could exercise 3 times per week for the next 3 months if: | I felt pain or discomfort when exercising.';
    scheSE{6} = 'I believe that I could exercise 3 times per week for the next 3 months if: | I had to exercise alone.';
    scheSE{7} = 'I believe that I could exercise 3 times per week for the next 3 months if: | It was not fun or enjoyable.';
    scheSE{8} = 'I believe that I could exercise 3 times per week for the next 3 months if: | It became difficult to get to the exercise location.';
    scheSE{9} = 'I believe that I could exercise 3 times per week for the next 3 months if: | I didn''t like the particular activity program that I was involved in.';
    scheSE{10} = 'I believe that I could exercise 3 times per week for the next 3 months if: | My schedule conflicted with my exercise session.';
    scheSE{11} = 'I believe that I could exercise 3 times per week for the next 3 months if: | I felt self-conscious about my appearance when I exercised.';
    scheSE{12} = 'I believe that I could exercise 3 times per week for the next 3 months if: | An instructor or trainer does not offer me any encouragement.';
    scheSE{13} = 'I believe that I could exercise 3 times per week for the next 3 months if: | I was under personal stress of some kind.';
    
i=1;


for i=1:13
    Likert(nwind, black, scheSE{i}, 'Not At All Confident', 'Highly Confident', ...
    grey, 5, 'Moderately Confident', black,[]);
    P_scheSE{1,i}=['scheSE' num2str(i)];
    P_scheSE{2,i}=ans;
end


%Exercise as a habit
DrawFormattedText(nwind, ['Please rate the extent to which you agree with the following statements:'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  WaitSecs(2);
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
   
    schab{1} = 'Choosing to go exercise is something that... | I do frequently.';
    schab{2} = 'Choosing to go exercise is something that...| I do automatically';
    schab{3} = 'Choosing to go exercise is something that...| I do without having to consciously remember.';
    schab{4} = 'Choosing to go exercise is something that...| makes me feel weird or uncomfortable if I do not do it.';
    schab{5} = 'Choosing to go exercise is something that...| I do without thinking.';
    schab{6} = 'Choosing to go exercise is something that...| would require effort to not do it.';
    schab{7} = 'Choosing to go exercise is something that...| belongs to my (daily, weekly, monthly) routine.';
    schab{8} = 'Choosing to go exercise is something that...| I start doing before I realize I''m doing it.';
    schab{9} = 'Choosing to go exercise is something that...| I would find hard not to do.';
    schab{10} = 'Choosing to go exercise is something that...| I have no need to think about doing.';
    schab{11} = 'Choosing to go exercise is something that...| is typically a ''me'' thing to do.';
    schab{12} = 'Choosing to go exercise is something that...| I have been doing for a long time.';
    
    
i=1;


for i=1:12
    Likert(nwind, black, schab{i},'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    p_schab{1,i}=['schab' num2str(i)];
    p_schab{2,i}=ans;
end

%Depletion Sensitivity
DrawFormattedText(nwind, ['Please rate the extent to which you agree with the following statements:'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  WaitSecs(2);
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
   
    depsens{1} = 'After I have worked very hard at something, I am not good at ''reloading'' to start a new task.';
    depsens{2} = 'I get mentally fatigued easily.'; 
    depsens{3} = 'After I have made a couple of difficult decisions, I can be truly mentally ''depleted''.';
    depsens{4} = 'After I have exerted a lot of mental effort, I need to take a rest first before I can do another complicated task.';
    depsens{5} = 'It is hard for me to persist with a difficult task.';
    depsens{6} = 'When I''m tired, I have difficulties to suppress my emotion whenever that''s necessary (for example: not falling out with someone you''re angry with).';
        
    
i=1;


for i=1:6
    Likert(nwind, black, depsens{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    p_depsens{1,i}=['depsens' num2str(i)];
    p_depsens{2,i}=ans;
end

%Implicit Theories of Willpower
DrawFormattedText(nwind, ['Please rate the extent to which you agree with the following statements:'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  WaitSecs(2);
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
   
    impwill{1} = 'Strenuous mental activity sometimes exhausts your resources, which you need to refuel afterwards (e.g. through breaks, doing nothing, watching television, eating...).';
    impwill{2} = 'After strenuous activity, your willpower is depleted and you must rest to get it refueled again.';
    impwill{3} = 'When you have been working on a strenuous mental task, you feel energized and you are able to immediately start with another demanding activity.';
    impwill{4} = 'Your mental stamina fuels itself. Even after strenuous mental exertion you can continue doing more of it.';
    impwill{5} = 'When you have completed a strenuous mental activity, you cannot start immediately with the same concentration because you have to recover your mental energy again.';
    impwill{6} = 'After a strenuous mental activity, you feel energized for further challenging activities.';
    impwill{7} = 'After strenuous activity, your willpower is depleted and you must rest to get it refueled again.';
    impwill{8} = 'After physical exertion, you need something pleasant (e.g., a break, food, television) before you can continue with another task.';
    impwill{9} = 'When you have exhausted yourself physically, your energy is used up and you have to recover to "recharge your batteries".';
    impwill{10} = 'After strenuous physical activity, you feel energetic and can immediately continue with something demanding.';
    impwill{11} = 'Activities in which you have to exert yourself physically will strengthen your willpower and you are able to tackle another challenge immediately.';
    impwill{12} = 'People can improve their willpower with practice.';
    impwill{13} = 'People have a certain amount of willpower and they can''t really do much to change it.';
    
    
        
    
i=1;

for i=1:13
    Likert(nwind, black, impwill{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    p_impwill{1,i}=['impwill' num2str(i)];
    p_impwill{2,i}=ans;
end

%Self-compassion scale
DrawFormattedText(nwind, ['Please rate the extent to which you agree with the following statements:'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  WaitSecs(2);
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
   
    selfcomp{1} = 'When I fail at something important to me, I become consumed by feelings of inadequacy.';
    selfcomp{2} = 'I try to be understanding and patient towards those aspects of my personality I don''t like.';
    selfcomp{3} = 'When something painful happens I try to take a balanced view of the situation.';
    selfcomp{4} = 'When I''m feeling down, I tend to feel like most other people are probably happier than I am.';
    selfcomp{5} = 'Honestly, I try to see my failings as part of the human condition.';
    selfcomp{6} = 'When I''m going through a very hard time, I make sure to give myself the caring I need.';
    selfcomp{7} = 'When something upsets me, I try to keep my emotions in balance.';
    selfcomp{8} = 'When I fail at something that''s important to me, I tend to feel alone in my failure.';
    selfcomp{9} = 'When I''m feeling down, I tend to obsess and fixate on everything that''s wrong.';
    selfcomp{10} = 'When I feel inadequate in some way, I try to remind myself that feelings of inadequacy are shared by most people.';
    selfcomp{11} = 'I''m disapproving and judgmental about my own flaws and inadequacies.';
    selfcomp{12} = 'I''m intolerant and impatient towards those aspects of myself I dislike.';
    
    
        
    
i=1;

for i=1:12
    Likert(nwind, black, selfcomp{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    p_selfcomp{1,i}=['selfcomp' num2str(i)];
    p_selfcomp{2,i}=ans;
end

%BIS-BAS scale
DrawFormattedText(nwind, ['Please rate the extent to which you agree with the following statements:'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  WaitSecs(2);
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
   
    BISBAS{1} = 'Even if something bad is about to happen to me, I rarely experience fear or nervousness.';
    BISBAS{2} = 'I go out of my way to get things I want.';
    BISBAS{3} = 'When I''m doing well at something I love to keep at it.';
    BISBAS{4} = 'I''m always willing to try something new if I think it will be fun.';
    BISBAS{5} = 'Criticism or scolding hurts me quite a bit.';
    BISBAS{6} = 'When I want something I usually go all-out to get it.';
    BISBAS{7} = 'I will often do things for no other reason than that they might be fun.';
    BISBAS{8} = 'If I see a chance to get something I want I move on it right away.';
    BISBAS{9} = 'I feel pretty worried or upset when I think or know somebody is angry at me.';
    BISBAS{10} = 'When I see an opportunity for something I like I get excited right away.';
    BISBAS{11} = 'I often act on the spur of the moment.';
    BISBAS{12} = 'If I think something unpleasant is going to happen I usually get pretty "worked up."';
    BISBAS{13} = 'When good things happen to me, it affects me strongly.';
    BISBAS{14} = 'I feel worried when I think I have done poorly at something important.';
    BISBAS{15} = 'I crave excitement and new sensations.';
    BISBAS{16} = 'When I go after something I use a "no holds barred" approach.';
    BISBAS{17} = 'I have very few fears compared to my friends.';
    BISBAS{18} = 'It would excite me to win a contest.';
    BISBAS{19} = 'I worry about making mistakes';
    
        
    
i=1;


for i=1:19
    Likert(nwind, black,BISBAS{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    p_BISBAS{1,i}=['BISBAS' num2str(i)];
    p_BISBAS{2,i}=ans;
end

%Self-esteem scale
DrawFormattedText(nwind, ['Please rate the extent to which you agree with the following statements:'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  WaitSecs(2);
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
   
    selfest{1} = 'I feel that I''m a person of worth, at least on an equal basis with others.';
    selfest{2} = 'I feel that I have a number of good qualities.';
    selfest{3} = 'All in all, I am inclined to feel that I am a failure.';
    selfest{4} = 'I am able to do things as well as most other people.';
    selfest{5} = 'I feel I do not have much to be proud of.';
    selfest{6} = 'I take a positive attitude toward myself.';
    selfest{7} = 'On the whole, I am satisfied with myself.';
    selfest{8} = 'I wish I could have more respect for myself.';
    selfest{9} = 'I certainly feel useless at times.';
    selfest{10} = 'At times I think I am no good at all.';
    
        
    
i=1;

for i=1:10
    Likert(nwind, black,selfest{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    p_selfest{1,i}=['selfest' num2str(i)];
    p_selfest{2,i}=ans;
end
%Self-control scale
DrawFormattedText(nwind, ['Please rate the extent to which you agree with the following statements:'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  WaitSecs(2);
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
   
    selfcont{1} = 'I have a hard time breaking bad habits.';
    selfcont{2} = 'I get distracted easily.';
    selfcont{3} = 'I say inappropriate things.';
    selfcont{4} = 'I refuse things that are bad for me, even if they are fun.';
    selfcont{5} = 'I’m good at resisting temptation.';
    selfcont{6} = 'Pleasure and fun sometimes keep me from getting work done.';
    selfcont{7} = 'I do things that feel good in the moment but regret later on.';
    selfcont{8} = 'Sometimes I can’t stop myself from doing something, even if I know it is wrong.';
    selfcont{9} = 'I often act without thinking through all the alternatives.';
    selfcont{10} = 'At times I think I am no good at all.';
    selfcont{11} = 'I am lazy.';
    selfcont{12} = 'People would say that I have very strong self-discipline.';
    selfcont{13} = 'I have trouble concentrating.';
    
    
        
    
i=1;

for i=1:13
    Likert(nwind, black,selfcont{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    p_selfcont{1,i}=['selfcont' num2str(i)];
    p_selfcont{2,i}=ans;
end



%%Conflict-control manipulation block
rng('shuffle');
concond=round(rand(1));
if concond ==1;

       %Conflict

      DrawFormattedText(nwind, ['For the next task, we are interested in your life experiences. \n \n Please imagine yourself at the end of a long and challenging day. \n \n'...
        'In some of these moments, you might feel conflicted about wanting to go exercise \n \n  because it would conflict with other goals in your life. '...
        'On the next \n \n screens, please describe 3 other goals that exercise might conflict with in \n \n your life, and for EACH goal describe ONE way that it conflicts with exercise. \n \n  Press any key to continue.'],  'center', 'center', black)
      Screen('Flip', nwind,[],1); % clear screen
      KbStrokeWait;
      Screen('FillRect', nwind, white, rect);
      Screen('Flip', nwind,[],0); % clear screen

    conflmanip1 = OpenResponseQuestion(nwind, black, white, ['Please describe your FIRST goal that might conflict with exercise, describe ONE way in which this FIRST goal conflicts with the goal to exercise.'], 1);
    Screen('Flip', nwind,[],1); % clear screen
    conflmanip2 = OpenResponseQuestion(nwind, black, white, ['Please describe a SECOND goal that might conflict with exercise, describe ONE way in which this SECOND goal conflicts with the goal to exercise.'], 1);
    Screen('Flip', nwind,[],1); % clear screen
    conflmanip3 = OpenResponseQuestion(nwind, black, white, ['Please describe a THIRD goal that might conflict with exercise, describe ONE way in which this THIRD goal conflicts with the goal to exercise.'], 1);
    Screen('Flip', nwind,[],1); % clear screen

    posnegconfl= OpenResponseQuestion(nwind, black, white, ['Now, please write down 3 positive and 3 negative outcomes of pursuing your exercise goals.'], 1);
    Screen('Flip', nwind,[],1); % clear screen

else

    %Control

    DrawFormattedText(nwind, ['For the next task, we are interested in your life experiences. \n \n In the text box below please imagine yourself on a typical day \n \n'...
        ' and how you would feel throughout that day. Please list \n \n 4 different goal pursuits that are currently important in your life. \n \n Please SELECT ONE of those goals. On the following pages \n \n describe one way in which your SELECTED goal \n \n might conflict with each of the other 3 goals \n \n (i.e., one conflict of the SELECTED goal, with each of the UNSELECTED goals). \n \n Press any key to continue.'],  'center', 'center', black)
      Screen('Flip', nwind,[],1); % clear screen
      KbStrokeWait;
      Screen('FillRect', nwind, white, rect);
      Screen('Flip', nwind,[],0); % clear screen

    contmanip1 = OpenResponseQuestion(nwind, black, white, ['Please describe one of your three UNSELECTED goals, describe one way in which this first UNSELECTED goal conflicts with your SELECTED goal.'], 1);
    Screen('Flip', nwind,[],1); % clear screen
    contmanip2 = OpenResponseQuestion(nwind, black, white, ['Please describe another of your three UNSELECTED goals, describe one way in which this second UNSELECTED goal conflicts with your SELECTED goal.'], 1);
    Screen('Flip', nwind,[],1); % clear screen
    contmanip3 = OpenResponseQuestion(nwind, black, white, ['Please describe the last of your three UNSELECTED goals, describe one way in which this third UNSELECTED goal conflicts with your SELECTED goal.'], 1);
    Screen('Flip', nwind,[],1); % clear screen

    posnegcontr= OpenResponseQuestion(nwind, black, white, ['Now, please write down 3 positive and 3 negative outcomes of pursuing your SELECTED goal.'], 1);
    Screen('Flip', nwind,[],1); % clear screen

end

%Conflict task manipulation check

    confMC{1} = 'Please rate your commitment to exercising on the day that you imagined.';
    confMC{2} = 'Please rate the importance of your exercise goals on the day that you imagined.';
    confMC{3} = 'Please rate the likelihood you might exercise on the day that you imagined.';
    confMC{4} = 'Please rate the extent to which you might feel conflicted about the goal to exercise on the day that you imagined.';

confMC1= Likert(nwind, black,confMC{1}, 'Not At All Committed', 'Highly Committed', ...
    grey, 5, 'Moderately Committed', black,[]);
confMC2= Likert(nwind, black,confMC{2},'Not At All Important', 'Highly Important', ...
    grey, 5, 'Moderately Important', black,[]);
confMC3= Likert(nwind, black,confMC{3}, 'Not At All Likely', 'Highly Likely', ...
    grey, 5, 'Moderately Likely', black,[]);
confMC4= Likert(nwind, black,confMC{4}, 'Not At All Conflicted', 'Highly Conflicted', ...
    grey, 5, 'Moderately Conflicted', black,[]);

%LFA BLOCK
%Draws text instructions on to the screen buffer (not yet shown)
sca;
DrawFormattedText(nwind, 'Now we will begin with another EEG measure. \n \n You will be given a fixation cross, please keep your eyes fixed on the central cross.',  'center'  ,'center', black)
Screen('DrawText',nwind,'When you are ready to begin, press any button.',fixation(1)-410,fixation(2)+125,black);
Screen('Flip', nwind);
KbStrokeWait;
IOPort('Write',TPort,uint8(0));
%Draws a fixation cross using our text size specifications on
%initialization on to the screen buffer (not yet shown)
DrawFormattedText(nwind, '+',  'center'  ,'center', black);
Screen('Flip', nwind);
IOPort('Write',TPort,trig3);
WaitSecs(120);
IOPort('Write',TPort,uint8(0));
Screen('FillRect', nwind, white, rect);
Screen('Flip', nwind,[],0); % clear screen
DrawFormattedText(nwind, 'You''ve completed the ''eyes open'' baseline measure. \n Press any button to continue to the ''eyes closed'' baseline measure.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbStrokeWait();
PsychPortAudio('FillBuffer', audhand, stnd);  
PsychPortAudio('Start', audhand, 1, 0, 1);
IOPort('Write',TPort,trig4);
WaitSecs(120);
PsychPortAudio('FillBuffer', audhand, stl);  
PsychPortAudio('Start', audhand, 1, 0, 1);
IOPort('Write',TPort,uint8(0));
Screen('FillRect', nwind, white, rect);
Screen('Flip', nwind,[],0); % clear screen
DrawFormattedText(nwind, 'You''ve completed this EEG measure. \n Press any button to continue the experiment.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbStrokeWait();

%Felt Uncertainty Scale
DrawFormattedText(nwind, ['Please think about the day you just imagined. \n \n How strongly did you feel the following emotions as you thought about that day. \n \n Press any key to continue.'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  KbStrokeWait;
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
   
  felun{1} = 'I feel mixed.';
  felun{2} = 'I feel uneasy.';
  felun{3} = 'I feel torn.';
  felun{4} = 'I feel bothered.';
  felun{5} = 'I feel preoccupied.';
  felun{6} = 'I feel confused.';
  felun{7} = 'I feel unsure of self or goals.';
  felun{8} = 'I feel contradictory.';
  felun{9} = 'I feel distractible.';
  felun{10} = 'I feel unclear.';
  felun{11} = 'I feel of two minds.';
  felun{12} = 'I feel muddled.';
  felun{13} = 'I feel restless.';
  felun{14} = 'I feel confused about identity.';
  felun{15} = 'I feel jumbled.';
  felun{16} = 'I feel uncomfortable.';
  felun{17} = 'I feel conflicted.';
  felun{18} = 'I feel indecisive.';
  felun{19} = 'I feel chaotic.';
       
     
     i=1;


for i=1:19
    Likert(nwind, black,felun{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    dvfelun{1,i}=['felun' num2str(i)];
    dvfelun{2,i}=ans;
end

%Concreteness task
DrawFormattedText(nwind, ['Please unlock the phone and complete the next task on the device provided. \n \n When you are done with the task on the phone, \n \n press any button to continue to the next task.'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  KbStrokeWait;
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen

absconccond = BinaryQuestion(nwind, black, grey, 'Please select the option that was displayed to you on the phone.', 'A', 'C');


i=1;
for i=1:13
        navonfile(i)= sprintf("NvnF (%d).png",i); %Change prefix to be
        navonchar=char(navonfile(1,i));
        nvnimg{1,i}=imread(navonchar);        
end
i=1;
%practice
DrawFormattedText(nwind, ['For this next task, you will be presented with a series of letters. \n\n These letters will be made'...
    ' up of other letters and your task \n \n is to respond quickly with a button press.'...
    ' You will press \n\n the ''Z'' key if you saw the smaller letters more clearly, or \n\n the ''/?'' key'...
    ' if you saw the larger letter more clearly. \n\n You will see one example image, then perform 3 practice trials. \n\n Press any key to begin!'],  'center'  ,'center', black);
Screen('Flip', nwind,[],1);
KbStrokeWait;
        Screen('FillRect', nwind, white);
        Screen('Flip',nwind);
        nvnimgshow=Screen('MakeTexture', nwind, nvnimg{1,7});
        Screen('DrawTexture', nwind, nvnimgshow, [], [], 0);
        Screen('Flip',nwind);
        WaitSecs(.3);
        Screen('FillRect', nwind, white);
        Screen('Flip',nwind);
        DrawFormattedText(nwind, ['That was an example of the image you will see. \n\n If you saw the letter ''C'' more clearly '...
            ' then you should press the ''Z'' button. \n\n If you saw the ''Y'' more clearly'...
            ' then you should press the ''/?'' button. \n\n The window that allows you to respond will be very short.'...
            ' \n\n You will now have 3 practice'...
            ' trials. Press any button to begin.'],  'center'  ,'center', black);
             Screen('Flip',nwind);
             KbStrokeWait;

for i=1:3
        
        
        Screen('FillRect', nwind, white);
        DrawFormattedText(nwind, '+',  'center'  ,'center', black);
        Screen('Flip', nwind,[],1);
        WaitSecs(.5);
        nvnimgshow=Screen('MakeTexture', nwind, nvnimg{1,i});
        Screen('DrawTexture', nwind, nvnimgshow, [], [], 0);
        starttime=Screen('Flip',nwind);
%         IOPort('Write',TPort,trig8);
        WaitSecs(.3);
        Screen('FillRect', nwind, white);
        Screen('Flip',nwind);
        endtime=KbQueueWait(-1);
%         IOPort('Write',TPort,trig9);
        [keyIsDown,secs,keyCode]=KbCheck(-1);
         x=find(keyCode>0);
         timing=endtime-starttime;
         if timing > .8
             DrawFormattedText(nwind, ['Your response was a bit too slow. Go with your gut response!\n\n Press any button to continue.'],  'center'  ,'center', black);
             Screen('Flip',nwind);
             KbStrokeWait;
         else
            switch x
                case 90
                 nvnprac(1,i)=1;
                 DrawFormattedText(nwind, ['You saw the small letters more clearly. Press any key to continue.'],  'center'  ,'center', black);
                    Screen('Flip',nwind);
                    KbStrokeWait;
                case 191
                 nvnprac(1,i)=2;
                 DrawFormattedText(nwind, ['You saw the large letter more clearly. Press any key to continue.'],  'center'  ,'center', black);
                    Screen('Flip',nwind);
                    KbStrokeWait;
                otherwise
                    DrawFormattedText(nwind, ['Invalid Key!'],  'center'  ,'center', black);
                    Screen('Flip',nwind);
                    WaitSecs(2);
            end
                   
         end
         IOPort('Write',TPort,uint8(0)); 
end
DrawFormattedText(nwind, ['Now you will perform the real trials, press \n\n any button when you are ready to begin!'],  'center'  ,'center', black);
Screen('Flip', nwind,[],1);
KbStrokeWait;

for i=4:13
        
        Screen('FillRect', nwind, white);
        DrawFormattedText(nwind, '+',  'center'  ,'center', black);
        Screen('Flip', nwind,[],1);
        WaitSecs(.5);
        nvnimgshow=Screen('MakeTexture', nwind, nvnimg{1,i});
        Screen('DrawTexture', nwind, nvnimgshow, [], [], 0);
        starttime=Screen('Flip',nwind);
        IOPort('Write',TPort,trig9);
        WaitSecs(.5);
        Screen('FillRect', nwind, white);
        Screen('Flip',nwind);
        endtime=KbQueueWait(-1);
        IOPort('Write',TPort,trig10);
        [keyIsDown,secs,keyCode]=KbCheck(-1);
         x=find(keyCode>0);
         timing=endtime-starttime;
         if timing > .8
             DrawFormattedText(nwind, ['Too Slow! Press any button to continue.'],  'center'  ,'center', black);
             Screen('Flip',nwind);
             KbStrokeWait;
         else
            switch x
                case 90
                 nvnresp(1,i)=1;
                 DrawFormattedText(nwind, ['You saw the smaller letters more clearly. Press any key to continue.'],  'center'  ,'center', black);
                    Screen('Flip',nwind);
                    KbStrokeWait;
                case 191
                 nvnresp(1,i)=2;
                  DrawFormattedText(nwind, ['You saw the large letter more clearly. Press any key to continue.'],  'center'  ,'center', black);
                    Screen('Flip',nwind);
                    KbStrokeWait;
                otherwise
                    DrawFormattedText(nwind, ['Invalid Key!'],  'center'  ,'center', black);
                    Screen('Flip',nwind);
                    WaitSecs(3);
            end
                    
         end
         IOPort('Write',TPort,uint8(0)); 
end

%LFA BLOCK
%Draws text instructions on to the screen buffer (not yet shown)
DrawFormattedText(nwind, 'Now we will begin with another EEG measure. \n \n You will be given a fixation cross, please keep your eyes fixed on the central cross.',  'center'  ,'center', black)
Screen('DrawText',nwind,'When you are ready to begin, press any button.',fixation(1)-410,fixation(2)+125,black);
Screen('Flip', nwind);
KbStrokeWait;
IOPort('Write',TPort,uint8(0));
%Draws a fixation cross using our text size specifications on
%initialization on to the screen buffer (not yet shown)
DrawFormattedText(nwind, '+',  'center'  ,'center', black);
Screen('Flip', nwind);
IOPort('Write',TPort,trig5);
WaitSecs(120);
IOPort('Write',TPort,uint8(0));
Screen('FillRect', nwind, white, rect);
Screen('Flip', nwind,[],0); % clear screen
DrawFormattedText(nwind, 'You''ve completed the ''eyes open'' baseline measure. \n Press any button to continue to the ''eyes closed'' baseline measure.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbStrokeWait();
PsychPortAudio('FillBuffer', audhand, stnd);  
PsychPortAudio('Start', audhand, 1, 0, 1);
IOPort('Write',TPort,trig6);
WaitSecs(120);
PsychPortAudio('FillBuffer', audhand, stl);  
PsychPortAudio('Start', audhand, 1, 0, 1);
IOPort('Write',TPort,uint8(0));
Screen('FillRect', nwind, white, rect);
Screen('Flip', nwind,[],0); % clear screen
DrawFormattedText(nwind, 'You''ve completed this EEG measure. \n Press any button to continue the experiment.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbStrokeWait();


%State BIS-BAS
DrawFormattedText(nwind, ['To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT:'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  WaitSecs(2);
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
   
  stBISBAS{1} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Strong.';
  stBISBAS{2} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Like you want to quit or give up.';
  stBISBAS{3} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Energetic.';
  stBISBAS{4} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Confident.';
  stBISBAS{5} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | An urge to move toward something.';
  stBISBAS{6} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Frustrated.';
  stBISBAS{7} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Determined.';
  stBISBAS{8} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Prepared to go all-in to get something you want.';
  stBISBAS{9} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Bothered.';
  stBISBAS{10} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Confused.';
  stBISBAS{11} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Uncomfortable.';
  stBISBAS{12} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Mixed.';
  stBISBAS{13} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Uneasy.';
  stBISBAS{14} = 'To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT: | Torn.';
       
          
     i=1;

for i=1:14
    Likert(nwind, black,stBISBAS{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    dvstBISBAS{1,i}=['stBISBAS' num2str(i)];
    dvstBISBAS{2,i}=ans;
end

%Exercise related cognitions
DrawFormattedText(nwind, ['To what extent are you experiencing the following feelings, IN THIS PRESENT MOMENT:'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  WaitSecs(2);
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
   
  excog{1} = 'IN THIS PRESENT MOMENT: I feel prepared to exercise.';
  excog{2} = 'IN THIS PRESENT MOMENT: I am confident that I can meet my exercise goals.';
  excog{3} = 'IN THIS PRESENT MOMENT: I will not procrastinate my exercise goals.';
  excog{4} = 'IN THIS PRESENT MOMENT: I believe that my exercise goals are feasible.';
  excog{5} = 'IN THIS PRESENT MOMENT: I set realistic exercise goals for myself.';
  excog{6} = 'IN THIS PRESENT MOMENT: I will prioritize my exercise goals.';
  excog{7} = 'IN THIS PRESENT MOMENT: My exercise goals are desirable.';
  excog{8} = 'IN THIS PRESENT MOMENT: There are more pros than cons to exercising.';
  excog{9} = 'IN THIS PRESENT MOMENT: I prefer the idea of my exercise goals over the reality.';
  excog{10} = 'IN THIS PRESENT MOMENT: I would prefer to think about the end product of my exercise, rather than what I need to do next.';    
     
     i=1;

for i=1:10
    Likert(nwind, black,excog{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    dvexcog{1,i}=['excog' num2str(i)];
    dvexcog{2,i}=ans;
end

%Exercise intentions
exintent1 = OpenResponseQuestion(nwind, black, white, ['I intend to exercise ____ times next week.'], 1);
Screen('Flip', nwind,[],1); % clear screen

exintent2 = OpenResponseQuestion(nwind, black, white, ['I intend to exercise at least ____ times over the next month.'], 1);
Screen('Flip', nwind,[],1); % clear screen

exintent3 = Likert(nwind, black, 'Within the next two weeks, I will begin a regular program of exercise.', 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);

exintent4 = Likert(nwind, black, 'At the present time, I have no intention of beginning exercising regularly.', 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);

%Email

%PANAS
DrawFormattedText(nwind, ['Please rate the extent to which you agree with the following statements:'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
   WaitSecs(2);
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
   
    PANAS{1} = 'I feel interested.';
    PANAS{2} = 'I feel distressed.';
    PANAS{3} = 'I feel excited.';
    PANAS{4} = 'I feel upset.';
    PANAS{5} = 'I feel guilty.';
    PANAS{6} = 'I feel scared.';
    PANAS{7} = 'I feel hostile.';
    PANAS{8} = 'I feel enthusiastic.';
    PANAS{9} = 'I feel proud.';
    PANAS{10} = 'I feel irritable.';
    PANAS{11} = 'I feel alert.';
    PANAS{12} = 'I feel ashamed.';
    PANAS{13} = 'I feel inspired.';
    PANAS{14} = 'I feel nervous.';
    PANAS{15} = 'I feel attentive.';
    PANAS{16} = 'I feel jittery.';
    PANAS{17} = 'I feel active.';
    PANAS{18} = 'I feel afraid.';
       
    
i=1;


for i=1:18
    Likert(nwind, black,PANAS{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    dvPANAS{1,i}=['PANAS' num2str(i)];
    dvPANAS{2,i}=ans;
end

%LFA BLOCK
%Draws text instructions on to the screen buffer (not yet shown)
DrawFormattedText(nwind, 'Now we will begin with another EEG measure. \n \n You will be given a fixation cross, please keep your eyes fixed on the central cross.',  'center'  ,'center', black)
Screen('DrawText',nwind,'When you are ready to begin, press any button.',fixation(1)-410,fixation(2)+125,black);
Screen('Flip', nwind);
KbStrokeWait;
IOPort('Write',TPort,uint8(0));
%Draws a fixation cross using our text size specifications on
%initialization on to the screen buffer (not yet shown)
DrawFormattedText(nwind, '+',  'center'  ,'center', black);
Screen('Flip', nwind);
IOPort('Write',TPort,trig7);
WaitSecs(120);
IOPort('Write',TPort,uint8(0));
Screen('FillRect', nwind, white, rect);
Screen('Flip', nwind,[],0); % clear screen
DrawFormattedText(nwind, 'You''ve completed the ''eyes open'' baseline measure. \n Press any button to continue to the ''eyes closed'' baseline measure.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbStrokeWait();
PsychPortAudio('FillBuffer', audhand, stnd);  
PsychPortAudio('Start', audhand, 1, 0, 1);
IOPort('Write',TPort,trig8);
WaitSecs(120);
PsychPortAudio('FillBuffer', audhand, stl);  
PsychPortAudio('Start', audhand, 1, 0, 1);
IOPort('Write',TPort,uint8(0));
Screen('FillRect', nwind, white, rect);
Screen('Flip', nwind,[],0); % clear screen
DrawFormattedText(nwind, 'You''ve completed this EEG measure. \n Press any button to continue the experiment.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbStrokeWait();

%Compliance check
DrawFormattedText(nwind, ['Please be honest with your responses to the following questions. \n \n They will not affect the results of your survey. \n \n Press any key to continue.'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  KbStrokeWait;
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen
  
    compchk{1} = 'I tried my best to answer all of the questions honestly.';
    compchk{2} = 'I gave this survey my undivided attention while I was completing it.';
    compchk{3} = 'I sometimes just clicked random responses in order to get through this survey as quickly as possible.';
    compchk{4} = 'I conscientiously attempted to follow instructions to the best of my ability.';
    
    i=1;


for i=1:4
    Likert(nwind, black,compchk{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
    dvcompchk{1,i}=['compchk' num2str(i)];
    dvcompchk{2,i}=ans;
end

DrawFormattedText(nwind, ['That concludes this study. \n \n Next you will be given the debrief which explains the details, \n \n research hypotheses and purpose of the study. \n \n Press any key to continue.'],  'center'  ,'center', black)
  Screen('Flip', nwind,[],1); % clear screen
  KbStrokeWait;
  Screen('FillRect', nwind, white, rect);
  Screen('Flip', nwind,[],0); % clear screen

%Debrief

z=3;%number of pages in consent form
%name of consent files

for i=1:z
    dbffile(i) = sprintf("D (%d).jpg",i);
    dbfchar=char(dbffile(1,i));
    dbfo=imread(dbfchar);
    dbfimg{1,i}=imresize(dbfo,0.40);
end

%%For-Loop that processes presents each page with a button press%%


for i=1:z
    dbfbuffer=Screen('MakeTexture', nwind, dbfimg{1,i});
    Screen('DrawTexture', nwind, dbfbuffer, [], [], 0);
    DrawFormattedText(nwind,'Press any key for the next page.', ['center'],[v_res-50]);
    Screen('Flip',nwind);
    KbStrokeWait;
    WaitSecs(0.5);
end

ppdataLikert=[dvspnd dvsccln dvfelun dvPANAS dvstBISBAS p_BISBAS p_depsens p_impwill p_schab P_scheSE p_selfcomp p_selfcont p_selfest];
ppdataTyped={concond, absconccond, conflmanip1, conflmanip2, conflmanip3, contmanip1, contmanip2, contmanip3, age, ethnicity, ex_sess, ex_week, excurr, exintent1, exintent2, exintent3, exintent4, fit, gender, gradeavg, nutrition, posnegconfl, posnegcontr, satisfit};
save('ppdataLikert.mat', 'ppdataLikert');
save('ppdataTyped.mat', 'ppdataTyped');

sca;