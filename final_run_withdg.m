clc;
clear;
close all;

nbus=26;
V=without_DG_process(nbus);
voltval1=V;
%%Change values for iteration,population values
iter_max=600;      
no_of_pop=100;  %previously 300    
prop_crsval=0.7;   
no_of_crs=2*round(prop_crsval*no_of_pop/2);  

prop_mutval=0.3;                          
no_of_mut=round(prop_mutval*no_of_pop);   
mu=0.02;       
sigma=2;


%%
int_tmp_pop.Position=[];
int_tmp_pop.Cost=[];
int_tmp_pop.Rank=[];
int_tmp_pop.DominationSet=[];
int_tmp_pop.DominatedCount=[];
int_tmp_pop.CrowdingDistance=[];

population_func_data=repmat(int_tmp_pop,no_of_pop,1);
minval1=1;
maxval1=nbus;
minval2=0;
maxval2=50;
no_of_dg=4;%Change no. of DG from 1-4


for locm=1:no_of_pop
    population_func_data(locm).Position=[randsrc(1,no_of_dg,minval1:maxval1) randsrc(1,no_of_dg,minval2:maxval2)];
    population_func_data(locm).Cost=feed_power(nbus,population_func_data(locm).Position);
    
end
[population_func_data, rankval]=non_dominate_sorting_process(population_func_data);
population_func_data=cal_crown_dist(population_func_data,rankval);
[population_func_data, rankval]=sort_process(population_func_data);
for iter=1:iter_max
       
    population_cross=repmat(int_tmp_pop,no_of_crs/2,2);
    for k=1:no_of_crs/2
        loc1=randi([1 no_of_pop]);
        loc1_data=population_func_data(loc1);
        
        loc2=randi([1 no_of_pop]);
        loc2_data=population_func_data(loc2);
        [population_cross(k,1).Position, population_cross(k,2).Position]=cross_over_process(loc1_data.Position,loc2_data.Position,minval1,maxval1,minval2,maxval2);
        
        population_cross(k,1).Cost=feed_power(nbus,population_cross(k,1).Position);
        population_cross(k,2).Cost=feed_power(nbus,population_cross(k,2).Position);
        
    end
    population_cross=population_cross(:);
    population_mute=repmat(int_tmp_pop,no_of_mut,1);
    for k=1:no_of_mut
        locm=randi([1 no_of_pop]);
        data_locm=population_func_data(locm);
        population_mute(k).Position=mutation_process(data_locm.Position,mu,sigma,minval1,maxval1,minval2,maxval2);
        population_mute(k).Cost=feed_power(nbus,population_mute(k).Position);
        
    end
    
   
    population_func_data=[population_func_data;population_cross;population_mute]; 
    [population_func_data, rankval]=non_dominate_sorting_process(population_func_data);
    population_func_data=cal_crown_dist(population_func_data,rankval);
    population_func_data=sort_process(population_func_data);
    population_func_data=population_func_data(1:no_of_pop);
   [population_func_data, rankval]=non_dominate_sorting_process(population_func_data);
    population_func_data=cal_crown_dist(population_func_data,rankval);
    [population_func_data, rankval]=sort_process(population_func_data);
    resout_final=population_func_data(rankval{1});
    
    res1=[resout_final.Cost];
    

%     figure(1),
%     plot(res1(1,:),res1(3,:),'r*','MarkerSize',8);
%     xlabel('Total System Loss');
%     ylabel('Total DG Unit');
%     grid on;
%     
%     figure(2),
%     plot(res1(3,:),res1(2,:),'b*','MarkerSize',8);
%     xlabel('DG Uint');
%     ylabel('Stability Index');
%     grid on;
%    
%     
%     figure(3),
%     plot(res1(1,:),res1(2,:),'k*','MarkerSize',8);
%     xlabel('Total System Loss');
%     ylabel('Stability Index');
%     grid on;
%    pause(0.01);
      
end
datart=resout_final(end).Position;

DG_LOCATION=datart(1:4)
DG_UNIT_SIZE=datart(5:8)
load resg.mat 
POWER_LOSSES_WITH_DG=POWER_LOSSES
STABILITY_INDEX_WITH_DG=STABILITY_INDEX
voltval2=V;

EIGEN_VALUE=diag(d1).'

no_of_int_pop = input('Enter the Population Value');
no_of_iter = input('Enter the Iteration Value');
no_of_DG = input('Number of DG');
%%
nbus = 26;
DG_SIZE_MIN = 10;
DG_SIZE_MAX = 1000;
data_pass_to_loadflow{2}=0.95;
data_pass_to_loadflow{3}=1.0;
data_pass_to_loadflow{4}=2000;
data_pass_to_loadflow{12}=no_of_DG;
%% apply load flow base case
[objective_result]=load_flow_process_basecase(nbus,data_pass_to_loadflow);
%Display  Power Loss
%POWER_LOSS_BASE_CASE=objective_result{1};
%%
%Display Power Loss in Real and Reactive value
ACTIVE_POWER_LOSS_BASE_CASE=objective_result{1};
REACTIVE_POWER_LOSS_BASE_CASE=objective_result{3};
VOLTAGE_BASE_CASE=objective_result{4};
BASE_CASE_RESULT=table(ACTIVE_POWER_LOSS_BASE_CASE,REACTIVE_POWER_LOSS_BASE_CASE);
disp(BASE_CASE_RESULT)
pause(3);
%%  Only DG 
for km=2:nbus
min_val1=km;   % lower limit
max_val1=km;  % upper limit
min_val2=DG_SIZE_MIN;   % lower limit
max_val2=DG_SIZE_MAX;  % upper limit
data_pass_to_loadflow{12}=1;
no_in_val=1;

%% PSO algorithm process
[data_final_pso,final_fit_pso]=PSO_PROCESS_dgplace(nbus,no_of_int_pop,...
                            no_of_iter,min_val1,max_val1,min_val2,max_val2,...
                            no_in_val*2,data_pass_to_loadflow);
FINAL_DG_loc=data_final_pso;
[objective_result]=load_flow_process_withdg(nbus,...
                            FINAL_DG_loc,data_pass_to_loadflow);
POWER_LOSS_p=objective_result{2};
POWER_LOSS_q=objective_result{3};
BUS_NUMBER(km-1,1)=FINAL_DG_loc(1);
DG_SIZE_MW(km-1,1)=FINAL_DG_loc(2)/1000;
Ploss_KW(km-1,1)=POWER_LOSS_p;
Qloss_KVar(km-1,1)=POWER_LOSS_q;
end

if(nbus == 26)
RESULT_OF_26_BUS_SYSTEM=table(BUS_NUMBER,DG_SIZE_MW,Ploss_KW,Qloss_KVar)    
elseif(nbus==33)
RESULT_OF_33_BUS_SYSTEM=table(BUS_NUMBER,DG_SIZE_MW,Ploss_KW,Qloss_KVar)
else
RESULT_OF_69_BUS_SYSTEM=table(BUS_NUMBER,DG_SIZE_MW,Ploss_KW,Qloss_KVar)
end    

figure,plot(BUS_NUMBER,DG_SIZE_MW,'m-^','linewidth',2);
xlabel('Bus Number');ylabel('DG Size MW');grid on;
title(['Suitable DG size for IEEE BUS - ' num2str(nbus)]);
data_pass_to_loadflow{12}=no_of_DG;
%%  Only DG placement
min_val1=2;   % lower limit
max_val1=nbus;  % upper limit
min_val2=DG_SIZE_MIN;   % lower limit
max_val2=DG_SIZE_MAX;  % upper limit
no_in_val=no_of_DG;
%% PSO algorithm process
[data_final_pso,final_fit_pso]=PSO_PROCESS_dgplace(nbus,no_of_int_pop,...
                            no_of_iter,min_val1,max_val1,min_val2,max_val2,...
                            no_in_val*2,data_pass_to_loadflow);
FINAL_DG_loc=data_final_pso;
DG_LOCATION=FINAL_DG_loc(1:no_of_DG);
DG_SIZE_Kw=(FINAL_DG_loc(no_of_DG+1:end));
[objective_result]=load_flow_process_withdg(nbus,...
                            FINAL_DG_loc,data_pass_to_loadflow);
POWER_LOSS_p=objective_result{2};
POWER_LOSS_q=objective_result{3};
LINE_LOSS_p=objective_result{5};
VOLTAGE_WITH_DG=objective_result{4};

%figure_plot
%ALG_NAME = 'PSO'
figure,bar(1:length(LINE_LOSS_p),LINE_LOSS_p,'c');
xlabel('Line Number');ylabel('Real Power Loss'); grid on;
title('Power Loss of a 26-Bus Test System');
pause(3)

figure,plot(1:length(final_fit_pso),final_fit_pso,'k-s','linewidth',2);
xlabel('Iteration');ylabel('Fitness');grid on;
title('Convergence Graph');
pause(3);

dglocation = table(DG_LOCATION);
dgsize = table(DG_SIZE_Kw);
disp(dglocation)
disp(dgsize)

EFFICIENCY=((ACTIVE_POWER_LOSS_BASE_CASE-min(Ploss_KW))/ACTIVE_POWER_LOSS_BASE_CASE)*100;
RESULT = table(DG_LOCATION, DG_SIZE_Kw, EFFICIENCY);

fprintf('Efficiency - %f\n',EFFICIENCY);
disp(RESULT)


namadh = 1:nbus;
plot(namadh,voltval1,'r');
hold on,
plot(namadh,voltval2,'g');
hold on,
plot(namadh,VOLTAGE_BASE_CASE,'y');
hold on,
plot (namadh,VOLTAGE_WITH_DG, 'b');
grid on,
title('Voltage Profile-Particle Swarm Optimization');
% legend('Voltage Before DG','Voltage After DG','Basecase-Without DG', ['With' ,num2str(no_of_DG),'DG']);
xlabel('Bus Number');
ylabel('Voltage');

    









