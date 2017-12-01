% step4_comm_evol_detect
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file detects the evolution of the communities between timeslots.%
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function lines below accordingly                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s1_comm_evol_detect(folder_name) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir; %%select the directory of interest
% timeSeg=1800; % Change the value of timeSeg in respect to the desired time sampling interval (seconds)
%%%Sampling time values {600 1800 3600 21600 43200 86400};%%%%%%%%%

%CommDir=dir([folder_name,'/home/andrej/Documents/dev/medline/test', '/test*.mat']);
CommDir=dir([folder_name, '/data/matlab/str-comms/str-comms*.mat']);
lDir=length(CommDir);

numCommBags=cell(lDir,1);
strCommBags=cell(lDir,1);
lC=zeros(lDir,1);
%load communities and make community bags with communities of size 2 and larger
%load([folder_name,'/home/andrej/Documents/dev/medline/test', '/commSizes.mat'],'commSizes');
load([folder_name, '/data/matlab/other', '/comm-sizes.mat'],'commSizes');
% For each snapshot, how many communities are larger that 2
for i=1:lDir
    lC(i)=length(find(commSizes(i,:)>2));
end
% Max number of communities over snapshots
maxlC=max(lC);
clear commSizes
for i=1:lDir
    % Load matrix with members for each commmunity
    load([folder_name, 'data/matlab/str-comms', '/str-comms-',num2str(i),'.mat'],'strComms');
    % Load matrix with ids for each community
    load([folder_name, 'data/matlab/num-comms', '/num-comms-',num2str(i),'.mat'],'numComms');
    % Community ids for communities > 2
    numCommBags(i,1:lC(i))=numComms(1:lC(i));
    % Community members for communities > 2
    strCommBags(i,1:lC(i))=strComms(1:lC(i));
end
save([folder_name, 'data/matlab/other', '/num-comm-bags.mat'],'numCommBags');
save([folder_name, 'data/matlab/other', '/comm-lengths.mat'],'lC');
save([folder_name, 'data/matlab/other', '/str-comm-bags.mat'],'strCommBags');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find similar communities in previous snapshots
clear CommDir numComms i place commSizes
if isempty(gcp('nocreate'))
    parpool;
end
tic
% Rows = snapshots, columns = communities
maxCommSimPercentage=zeros((lDir),max(lC));
% Start with 2nd snapshot
for i=2:lDir
    % Create tempmaxLike for each snapshot
    tempmaxLike=cell(1,lC(i));
    for j=1:lC(i)
        % Community IDs for 1st community (in 2nd snapshot)
        bag1=numCommBags{i,j};
        % Size of community
        tempcommSize=numel(bag1);
        % Select threshold
        if tempcommSize>9999
            thres=.05;
        elseif tempcommSize>999
            thres=.1;
        elseif tempcommSize>99
            thres=.15;
        elseif tempcommSize>29
            thres=.2;
        elseif tempcommSize>7
            thres=.3;
        else
            thres=.41;
        end
        mytemp=zeros(i-1,maxlC);
        for ltmemp=1:3
            l=i-ltmemp;
            if l>0
                % Number of communities in timeslot
                templC=lC(l);
                % For each community
                parfor k=1:templC
                    % Number of community members
                     tmp=numel(numCommBags{l,k});
                     if  (tmp/tempcommSize)>thres && tempcommSize>tmp
                         % intercept / number of unique element between 1st and 2nd snapshot
                         mytemp(l,k)=sum(ismembc(numCommBags{l,k},bag1))/numel(unique([bag1;numCommBags{l,k}]));
                     elseif (tempcommSize/tmp)>thres && tempcommSize<tmp
                         mytemp(l,k)=sum(ismembc(bag1,numCommBags{l,k}))/numel(unique([bag1;numCommBags{l,k}]));
                     else
                        continue
                     end
                end
                % If a similar community is detected in previous timeslots, the search continues to the next community
                if max(mytemp(l,:))>=thres
                    break
                end
            end % if l > 0
        end % for ltmemp 1:3
        if max(max(mytemp))>0
            tempmaxLike{j}=sparse(mytemp);
        end
    end    
    % Find maximum similarity between communities to speed up the process
    parfor k=1:lC(i)
        if ~isempty(tempmaxLike{k});
            maxCommSimPercentage(i,k)=full(max(max(tempmaxLike{k})));
        end
    end
    save([folder_name, 'data/matlab/temp-max-like', '/temp-max-like-',num2str(i),'.mat'],'tempmaxLike');
    clear tempmaxLike
    toc
end

% save maximum similarity between communities
save([folder_name, 'data/matlab/other', '/num-max-comm-sim-percentage-jacc.mat'],'maxCommSimPercentage');
if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end