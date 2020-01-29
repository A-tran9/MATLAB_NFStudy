
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
Screen('TextSize',nwind, 30);

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

%%For-Loop that processes image files and puts them into a cell%%

q=1;%number of pages in debrief

%name of debrief files

for i=1:q
     dbffile(i)= sprintf("D (%d).jpg",i); %Change prefix to be
     dbfchar=char(dbffile(1,i));
     dbo=imread(dbfchar);
     dbfimg{1,i}=imresize(dbo,0.45);
end

%%For-Loop that processes presents each page with a button press%%

for i=1:q
dbfbuffer=Screen('MakeTexture', nwind, dbfimg{1,i});
Screen('DrawTexture', nwind, dbfbuffer, [], [], 0);
DrawFormattedText(nwind,'Press any key for the next page.', ['center'],[v_res-100]);
Screen('Flip',nwind);
KbWait;
WaitSecs(0.5);
end
sca;
