function prepare_data(folder_name)
CommDir=dir([folder_name,'data/matlab/adj-mats/adj-mat-*.mm']);
lDir=length(CommDir);
commSizes=zeros(lDir,1);
% Read 'mesh - community id' for each year
% Store into strComm(k) file
% Convert to arrays!!!
for k = 1:lDir
    adjMat = mmread([folder_name,'data/matlab/adj-mats/adj-mat-', num2str(k), '.mm']);
    adjMat = sparse(adjMat);
    save([folder_name, 'data/matlab/adj-mats/adj-mat-',num2str(k), '.mat'], 'adjMat');
    tbl = readtable([folder_name,'data/matlab/clu-tabs/clu-tbl-', num2str(k), '.txt']);
    cluTab = tabulate(tbl.cluster);
    freq = cluTab(:,2);
    commSizes(k,1:length(freq)) = freq;
    strComms = cell(1, max(tbl.cluster));
    numComms = cell(1, max(tbl.cluster));
    for i = 1:max(tbl.cluster)
       strComms{i} = tbl.mesh(tbl.cluster == i,:);
       numComms{i} = tbl.idx(tbl.cluster == i,:);
    end  
    tempUsers = table2cell(tbl(:,[1 3]));
    tempUsersCommNums = table2array(tbl(:,2))';
    save([folder_name, 'data/matlab/temp-users/temp-users-', num2str(k), '.mat'], 'tempUsers');    
    save([folder_name, 'data/matlab/str-comms/str-comms-', num2str(k), '.mat'], 'strComms');
    save([folder_name, 'data/matlab/num-comms/num-comms-', num2str(k), '.mat'], 'numComms');
    save([folder_name, 'data/matlab/temp-users-comm-nums/temp-users-comm-nums-', num2str(k), '.mat'], 'tempUsersCommNums');
end
save([folder_name, 'data/matlab/other/comm-sizes.mat'], 'commSizes');
