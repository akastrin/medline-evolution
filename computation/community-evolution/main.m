clear all;clc;
tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('./scripts'));
folder_name = '../../'
% timeSeg= 1800; % If a specific sampling time is requested, please make the 
% selection and silence the step1 fn. 
show_plots = 1; % should be set to 1 if the plots are to be shown and to 0 if not.
recursive = 0; % Enable recursive computation for the Louvain algorith (will be slow for lg databases)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prepare_data(folder_name)

% This .m file detects the evolution of the communities between timeslots.
s1_comm_evol_detect(folder_name);

% This .m file detects the evolution of the communities between timeslots.
s2_comm_routes(folder_name);

% This .m file extracts the user centrality of all adjacency matrices in  %
% between timeslots using the pagerank algorithm.  
s3_usr_centrality(folder_name);

% This .m file extracts the community adjacency matrix in between        
% timeslots. (In this case, the communities are treated as users.)
s4_comm_dyn_adj_mat_wr(folder_name);

% This .m file extracts the centrality of the community adjacency matrices%
% using the PageRank algorithm.											  %
s5_comm_centrality_extraction(folder_name);

% This .m file provides a comparison of the communities perceived as most %
% significant by 3 different community evolution factors: stability,      %
% persistance and community centrality. The synergy of the 3 is also      %
% available for comparison.
top_evol=10;%number of top evolving communities to show
%[sigComms,sigComms_sblt,sigComms_prsst,sigComms_commCentr]=my_step9_commRank_comparison(folder_name, top_evol);
[sigComms,sigComms_sblt,sigComms_prsst,sigComms_commCentr] = s6_comm_rank_comparison(folder_name, top_evol);
% The signifComms variable provides the user with the most significant
% communities along with the users which comprise it and their centrality
% values. commEvol and commEvolSize are also useful are they present the 
% evolution of the communities and the community sizes respectfully.
% A heatmap presenting the evolution and size of all evolving communities
% is produced giving the user an idea of the bigger picture.
toc


