%% Top level script for running experiments.
%% Loads a list of experiment settings files and launches one.
%% After first use, experiment can be repeated without going through
%% menu with runexperiment.m

addpath([cd '/src']);
addpath([cd '/scripts']);
addpath([cd '/settings']);
addpath([cd '/data']);

globalconstants;
globalsettings;

if ~(exist('data')==1)
  load 15days.mat;
end

% load a list of all experiment settings files and allow user to choose one
globsettingsfile = which('globalsettings');
settingsdir = fileparts(globsettingsfile);
expfiles = dir([settingsdir '/exp*']);
for ifile = 1:length(expfiles)
  currsettings = expfiles(ifile).name(1:end-2);
  eval(currsettings);
  disp(['  ' num2str(ifile) ': ' settings.shortdesc]);
end
expchoice = input('Select experiment... ');
currsettings = expfiles(expchoice).name(1:end-2);
eval(currsettings);
disp(['Loaded settings for ' settings.expid ] );
runexperiment
