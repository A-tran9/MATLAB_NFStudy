%Personality Questionnaire 5-Point-Likert
%Code by Scott Fraundorf; dependent on CogToolbox
%Requires Screen(); initialization and window handle
%Modified by Alex Tran, PhD, (c) 2019
%Questions? 9trana@gmail.com, a_tran@hotmail.com

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
[window, rect]=Screen('OpenWindow',0,white);

itemmatrix{1} = 'test';
itemmatrix{2} = 'test';
itemmatrix{3} = 'test';
itemmatrix{4} = 'test';
itemmatrix{5} = 'test';
itemmatrix{6} = 'test';
itemmatrix{7} = 'test';
itemmatrix{8} = 'test';
itemmatrix{9} = 'test';
itemmatrix{10} = 'test';


for i=1:10
    scaledatavar{1,i}=['scalenameitem' num2str(i)];
end

% Usage of the Likert function:
% Likert(window[name of screen window], textcolor[can be rgb value or variable],...
%        questiontext [nameofscale_variable], leftlabel [right side anchor], rightlabel [left side anchor],...
%        confirmcolor [rgb value for button colour change], numchoices [number of scale points], centerlabel [center anchor],...
%        numcolor [colour of numbers in the scale boxes], buttondelay [disable buttons], ydim [pixels of the screen to limit scale to]);

for i=1:10 %number of scale items; default is 10-item scale   
Likert(window, black,itemmatrix{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 5, 'Neither Agree nor Disagree', black,[]);
scaledatavar{2,i}=ans;
end
sca;