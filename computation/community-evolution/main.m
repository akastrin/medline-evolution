clear all;clc;
tic

addpath(genpath('./scripts'));
folder_name = '../../'
show_plots = 1;
recursive = 0;

% Prepare necessary data for further analysis
prepare_data(folder_name)

% Detect the evolution of the communities between timeslots
s1_comm_evol_detect(folder_name);

% Detect the evolution of the communities between timeslots
s2_comm_routes(folder_name);

% Extract the user centrality of all adjacency matrices in between
% timeslots using the PageRank algorithm
s3_usr_centrality(folder_name);

% Extracts the community adjacency matrix in between timeslots
s4_comm_dyn_adj_mat_wr(folder_name);

% Extracts the centrality of the community adjacency matrices using the
% PageRank algorithm.											  %
s5_comm_centrality_extraction(folder_name);

% Compute stability, persistance and community centrality. It is necessary
% to provide number of top evolving communities
top_evol=10;
[sigComms,sigComms_sblt,sigComms_prsst,sigComms_commCentr] = s6_comm_rank_comparison(folder_name, top_evol);

% The signifComms variable provides the user with the most significant
% communities along with the users which comprise it and their centrality
% values. commEvol and commEvolSize are also useful are they present the 
% evolution of the communities and the community sizes respectfully.

toc


