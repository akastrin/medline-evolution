% step9_commRank_comparison.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file provides a comparison of the communities perceived as most %
% significant by 3 different community evolution factors: stability,      %
% persistance and community centrality. The synergy of the 3 is also      %
% available for comparison. 											  %
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function lines below accordingly                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sigComms,sigComms_sblt,sigComms_prsst,sigComms_commCentr] = s6_comm_rank_comparison(folder_name, top) %%Comment this line if you need the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%stand alone script %%comment the following 4 lines if you need the fn
% folder_name=uigetdir;
% timeSeg=1800; % Change the value of timeSeg in respect to the desired time sampling interval (seconds)
% top=20;%number of top evolving communities to show
%%%Sampling time values {600 1800 3600 21600 43200 86400};%%%%%%%%%


sigComms = s6_comm_rank_synergy(folder_name, top);

sigComms_sblt = s6_comm_rank_stability(folder_name, top);

sigComms_prsst = s6_comm_rank_persist(folder_name, top);

sigComms_commCentr = s6_comm_rank_comm_centr(folder_name, top);

