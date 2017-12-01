%step6_commIndivCentrality centrality of users in their corresponding communities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file extracts the user centrality of all adjacency matrices in  %
% between timeslots using the pagerank algorithm.                         %
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function lines below accordingly                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s3_usr_centrality(folder_name) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stand alone script %%comment the following 2 lines if you need the fn
% folder_name=uigetdir;
% timeSeg=1800;% Change the value of timeSeg in respect to the desired time sampling interval (seconds)
%%%Sampling time values {600 1800 3600 21600 43200 86400};%%%%%%%%%

CommDir=dir([folder_name,'data/matlab/adj-mats/', '/adj-mat-*.mat']);
lDir=length(CommDir);
adjMatCentr=cell(lDir,1);
commUsrCentr=cell(lDir,1);
if isempty(gcp('nocreate'))
    parpool;
end
for i=1:lDir
    load([folder_name,'data/matlab/adj-mats', '/adj-mat-',num2str(i),'.mat']);
    tempAdjMatCentr=mypagerank(adjMat,0.85,0.001); %These values are the ones proposed by most PageRank using algorithms
    %tempAdjMatCentr=mypagerank(adj,0.85,0.001); %These values are the ones proposed by most PageRank using algorithms
    adjMatCentr{i}=tempAdjMatCentr;
    load([folder_name,'data/matlab/temp-users', '/temp-users-',num2str(i),'.mat']);
    load([folder_name,'data/matlab/str-comms', '/str-comms-',num2str(i),'.mat']);
    strComms=strComms;tempUsers=tempUsers;
    parfor k=1:length(strComms)
        [~,tempNumUsrs]=ismember(table2array(strComms{k}),tempUsers(:,1));
        commUsrCentr{i,k}=tempAdjMatCentr(tempNumUsrs);
    end    
end
if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
save([folder_name,'data/matlab/other', '/adj-mat-centr.mat'],'adjMatCentr');
save([folder_name,'data/matlab/other', '/comm-usr-centr.mat'],'commUsrCentr');
%%%%%%%%%%%%%%%%%%%%%%%% normalize by max of centrality for each timestep
maxCentr=cellfun(@max,adjMatCentr);
usrCentrMax=cell(lDir,1);

for i=1:lDir
    tempUsrCentrMax=cellfun(@(x) x/maxCentr(i),commUsrCentr(i,:),'UniformOutput',0);
    usrCentrMax(i,(1:length(tempUsrCentrMax)))=tempUsrCentrMax;%(1:length(tempUsrCentrMax));
    clear tempUsrCentrMax    
end
save([folder_name,'data/matlab/other', '/usr-centr-max.mat'],'usrCentrMax');


