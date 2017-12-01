% step9_commRank_persist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file provides an analysis of the communities in respect to their%
% evolution in terms of persistence.                                      %
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function lines below accordingly                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function signifComms_prsst = s6_comm_rank_persist(folder_name, top) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir;
% timeSeg=1800; % Change the value of timeSeg in respect to the desired time sampling interval (seconds)
% top=20;%number of top evolving communities to show
%%%Sampling time values {600 1800 3600 21600 43200 86400};%%%%%%%%%

load([folder_name,'data/matlab/other', '/num-comm-bags.mat'],'numCommBags');
load([folder_name,'data/matlab/other', '/num-evol-comm-ids.mat'],'commIds');
load([folder_name,'data/matlab/other', '/num-evol-uni-comm-ids.mat'],'uniCommIds');
load([folder_name,'data/matlab/other', '/comm-evol-ones.mat'],'commEvolOnes');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[evols,~]=size(commEvolOnes);
%%%%%persistence
prsist=sum(commEvolOnes);%/h;
prsist=prsist/evols;
%%%%%most significant evolutional comms
frstTry=prsist;
[~,idx]=sort(frstTry,'descend');
signifComms_prsst=cell(top,1);
load([folder_name,'data/matlab/other', '/str-comm-bags.mat'],'strCommBags')
load([folder_name,'data/matlab/other', '/usr-centr-max.mat'],'usrCentrMax');
for i=1:top
    [a,b]=find(strcmp(uniCommIds{idx(i)},commIds));
    for k=1:length(a)
        signifComms_prsst{i,k}=strCommBags{a(k),b(k)};
        tmpCommPrst=num2cell(prsist(idx(i)));
        signifComms_prsst{i,k}(:,2)=tmpCommPrst;
        tmpUsrCentr=num2cell(usrCentrMax{a(k),b(k)});
        signifComms_prsst{i,k}(:,3)=tmpUsrCentr;
    end
end
save([folder_name,'data/matlab/other', '/signif-comms-persist.mat'],'signifComms_prsst')


