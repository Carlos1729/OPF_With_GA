clc
clear all;
close all;
warning off;
tic;
[user,sys]=memory;
%header
% profile('-memory','on');
% profile on;
% setpref('profiler','showJitLines',1);
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

figure,plot(1:length(VOLTAGE_BASE_CASE),VOLTAGE_BASE_CASE,'r-','linewidth', 2);
hold on; plot (1: length (VOLTAGE_WITH_DG), VOLTAGE_WITH_DG, 'b', 'linewidth', 2); 
xlabel('Bus Number');ylabel('Bus Voltage'); grid on; title('Voltage Profile-Particle Swarm Optimization');
legend('Basecase-Without DG', ['With' ,num2str(no_of_DG),'DG'] );
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

toc;
[user2,sys2]=memory;
memory_used_in_bytes=user2.MemAvailableAllArrays-user.MemAvailableAllArrays;
fprintf('Memory used - %d\n',memory_used_in_bytes);