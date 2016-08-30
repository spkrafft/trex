function save_setupX(h)
%%
disp('TREX-RT>> Saving setupX.mat data...');

setupWrite = h.setupWrite;

filename = [h.now,'_setupX.mat'];
save(fullfile(h.export.project_path,'Log',filename),'-struct','setupWrite')

%%
remove_doseX(h.export.project_path)

%%
remove_textureX(h.export.project_path)

%%
disp(['TREX-RT>> setupX.mat saved to project log directory: ',filename]);

%%
clearvars
