
%% Convert Excel data to MATLAB date-time format 
% WSPR timestamp (wspr) -> MATLAB data-time = 
% wspr/86400 + datenum('01-Jan-1970');

% Excel general format of '01-Jan-1970' = 25569
% Excel timestamp (csv) -> MATLAB data-time = 
% (csv - 25569) + datenum('01-Jan-1970');

%% Reset MATLAB
clear all 
close all
clc

%% Load data from workspace
% load data from the wspr mat file
load 'Apr18.mat'
%Aprtime=datevec(((cell2mat(Apr18(:,2))-25569))+datenum('01-Jan-1970'));

%figure(1)
%histogram(Aprtime(:,4),'Binwidth',1);
%xlabel('Hours');
%ylabel('Number of Counts');
%title('WSPR radio links between the UK and NZ in april 2018');

%% Sort rows

% Create a table from the cell array 
T = cell2table(Apr18,...
    'VariableNames',{'SpotID' 'Timestamp' 'Reporter' 'RGrid','SNR','fMHz',...
    'Callsign','TxGrid','dBm','Drift','Distance','Azimuth','Band','Version','Code'});

I_locator = "IO";
J_locator = "J";
ZL_locator = "R";

% Logical arrays - select radio links between the UK and NZ 
% Reporter Maidenhead Locators
RF = startsWith(string(Apr18(:,4)),I_locator) | ... %UK locators
     startsWith(string(Apr18(:,4)),J_locator) | ... %UK  locators
     startsWith(string(Apr18(:,4)),ZL_locator);     %NZ  locators
 
%Transmitter Maidenhead locators 
TF = startsWith(string(Apr18(:,8)),I_locator) | ... %UK locators
     startsWith(string(Apr18(:,8)),J_locator) | ... %UK locators
     startsWith(string(Apr18(:,8)),ZL_locator);     %NZ locators

%Logical array - Pair up the radio links between the UK and NZ
Trx = TF & RF;  

%Finalised overall table - UK - NZ radio links 
T = T(Trx,:);

rx = string(table2cell(T(:,'Reporter'))); %Extract the Reporter column for logical analysis
tx = string(table2cell(T(:,'Callsign'))); %Extract the Callsign column for logical analysis
Station_NZ = "ZL"; %New Zealand radio callsign prefix

%Logical array - Check if the receiver is from NZ
NZ_stations_rx = table(double(startsWith(rx,Station_NZ)),...
                       'VariableNames',{'NZreceiver'});
                   
%Logical array - Check if the transmitter is from NZ
NZ_stations_tx = table(double(startsWith(tx,Station_NZ)),...
                       'VariableNames',{'NZtransmitter'});
%Timestamp
[Aprtime] = april_wspr_csv(table2cell(T(:,2)));
% Tx links from the UK                   
Tx_UK = T;
Tx_UK = [Tx_UK NZ_stations_rx];
Tx_UK = Tx_UK(Tx_UK.NZreceiver==1,:);
[Aprtime_uk] = april_wspr_table(table2cell(Tx_UK(:,2))); %Tabular data for time

% Tx links from NZ
Tx_NZ = T;
Tx_NZ = [Tx_NZ NZ_stations_tx];
Tx_NZ = Tx_NZ(Tx_NZ.NZtransmitter==1,:);
[Aprtime_nz] = april_wspr_table(table2cell(Tx_NZ(:,2))); %Tabular data for time

%% Figure 1 - Create the histograms
edges = 0:1:24; %Binwidth in 1 hour interval for 24 hours (1 day)
figure(1)

subplot(3,1,1)
histogram(Aprtime(:,4),edges,'FaceColor','k');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure A: WSPR radio links made between the UK and NZ in april 2018');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

subplot(3,1,2)
histogram(Aprtime_uk(:,4),edges,'FaceColor','b');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure B: WSPR radio links from the UK to NZ in april 2018');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

subplot(3,1,3)
histogram(Aprtime_nz(:,4),edges,'FaceColor','r');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure C: WSPR radio links from NZ and the UK in april 2018');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));
saveas(gcf,'UKNZ_WSPR_April_overall_histogram.fig');
saveas(gcf,'UKNZ_WSPR_April_overall_histogram.jpg');


%% Figure 2 - 7 MHz frequency band radio link 
unique_bands = unique(T.Band);
T_7MHz = T(T.Band == 7,:);  % 7MHz band
time_7MHz = table2cell(T_7MHz(:,2));
[Aprtime_7MHz] = april_wspr_table(time_7MHz); %Tabular data

% 7MHz band from the UK
Tx_UK_7MHz = Tx_UK;
Tx_UK_7MHz = Tx_UK_7MHz(Tx_UK_7MHz.Band==7,:);
[Aprtime_uk_7MHz] = april_wspr_table(table2cell(Tx_UK_7MHz(:,2))); %Tabular data


% 7MHz band from NZ
Tx_NZ_7MHz = Tx_NZ;
Tx_NZ_7MHz = Tx_NZ_7MHz(Tx_NZ_7MHz.Band==7,:);
[Aprtime_nz_7MHz] = april_wspr_table(table2cell(Tx_NZ_7MHz(:,2))); %Tabular data

%Figure 2

figure(2)
subplot(3,1,1)
histogram(Aprtime_7MHz(:,4),edges,'FaceColor','k');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure A: WSPR Radio links between the UK and NZ at 7 MHz frequency band in april 2018');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

subplot(3,1,2)
histogram(Aprtime_uk_7MHz(:,4),edges,'FaceColor','b');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure B: WSPR radio links from the UK to NZ in april 2018 at 7MHz band');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

subplot(3,1,3)
histogram(Aprtime_nz_7MHz(:,4),edges,'FaceColor','r');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure C: WSPR radio links from NZ and the UK in april 2018 at 7MHz band');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

saveas(gcf,'UKNZ_WSPR_April_7MHz_histogram.fig');
saveas(gcf,'UKNZ_WSPR_April_7MHz_histogram.jpg');


%% Figure 3 - 14 MHz band radio link between the UK and NZ
T_14MHz = T(T.Band == 14,:); %14 MHz band
time_14MHz = table2cell(T_14MHz(:,2));
[Aprtime_14MHz] = april_wspr_table(time_14MHz); %Tabular data

% 14MHz band from the UK
Tx_UK_14MHz = Tx_UK;
Tx_UK_14MHz = Tx_UK_14MHz(Tx_UK_14MHz.Band==14,:);
[Aprtime_uk_14MHz] = april_wspr_table(table2cell(Tx_UK_14MHz(:,2))); %Tabular data


% 7MHz band from NZ
Tx_NZ_14MHz = Tx_NZ;
Tx_NZ_14MHz = Tx_NZ_14MHz(Tx_NZ_14MHz.Band==14,:);
[Aprtime_nz_14MHz] = april_wspr_table(table2cell(Tx_NZ_14MHz(:,2))); %Tabular data

figure(3)
subplot(3,1,1)
histogram(Aprtime_14MHz(:,4),edges,'FaceColor','k');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure A: WSPR Radio links between the UK and NZ at 14 MHz frequency band in april 2018');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

subplot(3,1,2)
histogram(Aprtime_uk_14MHz(:,4),edges,'FaceColor','b');

xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure B: WSPR radio links from the UK to NZ in april 2018 at 14MHz band');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

subplot(3,1,3)
histogram(Aprtime_nz_14MHz(:,4),edges,'FaceColor','r');

xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure C: WSPR radio links from NZ and the UK in april 2018 at 14MHz band');
set(gca,'FontSize',20);
%datetick('x','hh:mm','keeplimits');
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

saveas(gcf,'UKNZ_WSPR_April_14MHz_histogram.fig');
saveas(gcf,'UKNZ_WSPR_April_14MHz_histogram.jpg');

%% Figure 4 - 10 MHz
T_10MHz = T(T.Band == (unique_bands(2,1)),:); %14 MHz band
time_10MHz = table2cell(T_10MHz(:,2));
[Aprtime_10MHz] = april_wspr_table(time_10MHz); %Tabular data

% 10MHz band from the UK
Tx_UK_10MHz = Tx_UK;
Tx_UK_10MHz = Tx_UK_10MHz(Tx_UK_10MHz.Band==10,:);
[Aprtime_uk_10MHz] = april_wspr_table(table2cell(Tx_UK_10MHz(:,2))); %Tabular data


% 7MHz band from NZ
Tx_NZ_10MHz = Tx_NZ;
Tx_NZ_10MHz = Tx_NZ_10MHz(Tx_NZ_10MHz.Band==10,:);
[Aprtime_nz_10MHz] = april_wspr_table(table2cell(Tx_NZ_10MHz(:,2))); %Tabular data

figure(4)
subplot(3,1,1)
histogram(Aprtime_10MHz(:,4),edges,'FaceColor','k');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure A: WSPR Radio links between the UK and NZ at 14 MHz frequency band in april 2018');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

subplot(3,1,2)
histogram(Aprtime_uk_10MHz(:,4),edges,'FaceColor','b');

xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure B: WSPR radio links from the UK to NZ in april 2018 at 10MHz band');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

subplot(3,1,3)
histogram(Aprtime_nz_10MHz(:,4),edges,'FaceColor','r');

xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure C: WSPR radio links from NZ and the UK in april 2018 at 10MHz band');
set(gca,'FontSize',20);
%datetick('x','hh:mm','keeplimits');
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

%saveas(gcf,'UKNZ_WSPR_April_14MHz_histogram.fig');
%saveas(gcf,'UKNZ_WSPR_April_14MHz_histogram.jpg');
%% Figure 5 - 21 MHz
T_21MHz = T(T.Band == (unique_bands(4,1)),:); %21 MHz band
time_21MHz = table2cell(T_21MHz(:,2));
[Aprtime_21MHz] = april_wspr_table(time_21MHz); %Tabular data

% 10MHz band from the UK
Tx_UK_21MHz = Tx_UK;
Tx_UK_21MHz = Tx_UK_21MHz(Tx_UK_21MHz.Band== (unique_bands(4,1)),:);
[Aprtime_uk_21MHz] = april_wspr_table(table2cell(Tx_UK_21MHz(:,2))); %Tabular data


% 7MHz band from NZ
Tx_NZ_21MHz = Tx_NZ;
Tx_NZ_21MHz = Tx_NZ_10MHz(Tx_NZ_21MHz.Band==(unique_bands(4,1)),:);
[Aprtime_nz_21MHz] = april_wspr_table(table2cell(Tx_NZ_21MHz(:,2))); %Tabular data

figure(5)
subplot(3,1,1)
histogram(Aprtime_10MHz(:,4),edges,'FaceColor','k');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure A: WSPR Radio links between the UK and NZ at 21 MHz frequency band in april 2018');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

subplot(3,1,2)
histogram(Aprtime_uk_10MHz(:,4),edges,'FaceColor','b');

xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure B: WSPR radio links from the UK to NZ in april 2018 at 21MHz band');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

subplot(3,1,3)
histogram(Aprtime_nz_10MHz(:,4),edges,'FaceColor','r');

xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('Figure C: WSPR radio links from NZ and the UK in april 2018 at 21MHz band');
set(gca,'FontSize',20);
%datetick('x','hh:mm','keeplimits');
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));

%% Figures 6-8 - Stacked histograms - Overall links

% Overall
hist_7MHz  = hist(Aprtime_7MHz(:,4),edges);
hist_10MHz = hist(Aprtime_10MHz(:,4),edges);
hist_14MHz = hist(Aprtime_14MHz(:,4),edges);
hist_21MHz = hist(Aprtime_21MHz(:,4),edges);
hist_overall_max = max([hist_7MHz.' hist_10MHz.' hist_14MHz.' hist_21MHz.']);
hist_overall_max = sum(hist_overall_max,2);

%UK
hist_7MHz_uk  = hist(Aprtime_uk_7MHz(:,4),edges);
hist_10MHz_uk = hist(Aprtime_uk_10MHz(:,4),edges);
hist_14MHz_uk = hist(Aprtime_uk_14MHz(:,4),edges);
hist_21MHz_uk = hist(Aprtime_uk_21MHz(:,4),edges);

%NZ
hist_7MHz_nz  = hist(Aprtime_nz_7MHz(:,4),edges);
hist_10MHz_nz = hist(Aprtime_nz_10MHz(:,4),edges);
hist_14MHz_nz = hist(Aprtime_nz_14MHz(:,4),edges);
hist_21MHz_nz = hist(Aprtime_nz_21MHz(:,4),edges);

hist_nz_max = max(hist_7MHz_nz) + max(hist_10MHz_nz)+...
              max(hist_14MHz_nz)+max(hist_21MHz_nz);


figure(6)
bar([hist_7MHz.' hist_10MHz.' hist_14MHz.' hist_21MHz.'],'stacked');
legend('7 MHz','10 MHz', '14 MHz', '21 MHz');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('WSPR Radio links between the UK and NZ in april 2018');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));
%set(gca,'YTick',(0:1:max(y)));
saveas(gcf,'UKNZ_WSPR_April_overall_stacked_histogram.fig');
saveas(gcf,'UKNZ_WSPR_April_overall_stacked_histogram.jpg');


figure(7)
bar([hist_7MHz_uk.' hist_10MHz_uk.' hist_14MHz_uk.' hist_21MHz_uk.'],'stacked');
legend('7 MHz','10 MHz', '14 Mhz', '21 MHz');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('WSPR Radio links from the UK transmitters in April 2018');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));
%set(gca,'YTick',(0:1:));
saveas(gcf,'UKNZ_WSPR_April_Tx_UK_stacked_histogram.fig');
saveas(gcf,'UKNZ_WSPR_April_Tx_UK_stacked_histogram.jpg');

figure(8)
bar([hist_7MHz_nz.' hist_10MHz_nz.' hist_14MHz_nz.' hist_21MHz_nz.'],'stacked');
legend('7 MHz','10 MHz', '14 Mhz', '21 MHz');
xlabel('Hours (UTC)');
ylabel('Number of Counts');
title('WSPR Radio links from the NZ transmitters in april 2018');
set(gca,'FontSize',20);
set(gca,'XLim',[0 24]);
set(gca,'XTick',(0:1:24));
set(gca,'YTick',(0:1:hist_nz_max));
saveas(gcf,'UKNZ_WSPR_April_Tx_NZ_stacked_histogram.fig');
saveas(gcf,'UKNZ_WSPR_April_Tx_NZ_stacked_histogram.jpg');

%% Signal-to-Noise Ratio SNR plots 

%% Figure 9 - UK to New Zealand
Aprtime_uk_snr = datetime(Aprtime_uk(:,1),Aprtime_uk(:,2),Aprtime_uk(:,3),...
                          Aprtime_uk(:,4),...
                          Aprtime_uk(:,5),Aprtime_uk(:,6),...
                          'Format','yyyy-MM-dd HH:mm:ss');
Aprtime_uk_snr_hour = Aprtime_uk(:,4)+ Aprtime_uk(:,5)/60+ Aprtime_uk(:,6)/3600;

%7MHz
Aprtime_uk_snr_hour_7MHz = Aprtime_uk_7MHz(:,4)+ ...
                           Aprtime_uk_7MHz(:,5)/60+ Aprtime_uk_7MHz(:,6)/3600;

%10MHz
Aprtime_uk_snr_hour_10MHz = Aprtime_uk_10MHz(:,4)+ ...
                           Aprtime_uk_10MHz(:,5)/60+ Aprtime_uk_10MHz(:,6)/3600;

%14MHz
Aprtime_uk_snr_hour_14MHz = Aprtime_uk_14MHz(:,4)+ ...
                            Aprtime_uk_14MHz(:,5)/60+ Aprtime_uk_14MHz(:,6)/3600;
                        
%21MHz
Aprtime_uk_snr_hour_21MHz = Aprtime_uk_21MHz(:,4)+ ...
                           Aprtime_uk_21MHz(:,5)/60+ Aprtime_uk_21MHz(:,6)/3600;

                        
SNR_UK = cell2mat(table2cell(Tx_UK(:,5)));
SNR_UK_7MHz = cell2mat(table2cell(Tx_UK_7MHz(:,5)));
SNR_UK_10MHz = cell2mat(table2cell(Tx_UK_10MHz(:,5)));
SNR_UK_14MHz = cell2mat(table2cell(Tx_UK_14MHz(:,5)));
SNR_UK_21MHz = cell2mat(table2cell(Tx_UK_21MHz(:,5)));

figure(9)
subplot(2,1,1)
scatter(datetime(Aprtime_uk_7MHz),SNR_UK_7MHz,'r*');
hold on
scatter(datetime(Aprtime_uk_10MHz),SNR_UK_10MHz,'b*');
scatter(datetime(Aprtime_uk_14MHz),SNR_UK_14MHz,'g*');
scatter(datetime(Aprtime_uk_21MHz),SNR_UK_21MHz,'k*');

xlabel('Date');
ylabel('Received SNR (dB)');
title('Figure A: SNR recorded from the NZ receivers in april 2018');
set(gca,'FontSize',20);
legend('UK 7 MHz Band','UK 10 MHz band','UK 14 MHz band','UK 21 MHz band');

subplot(2,1,2)
scatter(Aprtime_uk_snr_hour_7MHz,SNR_UK_7MHz,'*','r');
hold on
scatter(Aprtime_uk_snr_hour_10MHz,SNR_UK_10MHz,'*','b');
scatter(Aprtime_uk_snr_hour_14MHz,SNR_UK_14MHz,'*','g');
scatter(Aprtime_uk_snr_hour_21MHz,SNR_UK_21MHz,'*','k');
grid on
xlabel('Hours (UTC)');
ylabel('Receiver signal to noise ratio (dB)');
title('Figure B: Received SNR from the UK to NZ on a hourly basis');
set(gca,'FontSize',20);
set(gca,'XTick',(0:1:24));
xlim([0 24]);
legend('UK 7 MHz Band','UK 10 MHz band','UK 14 MHz band','UK 21 MHz band');
%xl = xlim
%xlim([0 24]);
saveas(gcf,'UKNZ_WSPR_April_SNR_NZ.fig');
saveas(gcf,'UKNZ_WSPR_April_SNR_Nz.jpg');
%% Figure 10 - New zealand to UK 

Aprtime_nz_snr = datetime(Aprtime_nz(:,1),Aprtime_nz(:,2),Aprtime_nz(:,3),...
                          Aprtime_nz(:,4),...
                          Aprtime_nz(:,5),Aprtime_nz(:,6),...
                          'Format','yyyy-MM-dd HH:mm:ss');

Aprtime_nz_snr_hour = Aprtime_nz(:,4)+ Aprtime_nz(:,5)/60+ Aprtime_nz(:,6)/3600;

%7MHz
Aprtime_nz_snr_hour_7MHz = Aprtime_nz_7MHz(:,4)+ ...
                           Aprtime_nz_7MHz(:,5)/60+ Aprtime_nz_7MHz(:,6)/3600;

%10MHz
Aprtime_nz_snr_hour_10MHz = Aprtime_nz_10MHz(:,4)+ ...
                           Aprtime_nz_10MHz(:,5)/60+ Aprtime_nz_10MHz(:,6)/3600;

%14MHz
Aprtime_nz_snr_hour_14MHz = Aprtime_nz_14MHz(:,4)+ ...
                            Aprtime_nz_14MHz(:,5)/60+ Aprtime_nz_14MHz(:,6)/3600;
                        
%21MHz
Aprtime_nz_snr_hour_21MHz = Aprtime_nz_21MHz(:,4)+ ...
                           Aprtime_nz_21MHz(:,5)/60+ Aprtime_nz_21MHz(:,6)/3600;


                          
%Aprtime_nz_snr_hour = datenum(Aprtime_nz_snr);                        
SNR_NZ = cell2mat(table2cell(Tx_NZ(:,5)));
         
SNR_NZ_7MHz = cell2mat(table2cell(Tx_NZ_7MHz(:,5)));
SNR_NZ_10MHz = cell2mat(table2cell(Tx_NZ_10MHz(:,5)));
SNR_NZ_14MHz = cell2mat(table2cell(Tx_NZ_14MHz(:,5)));
SNR_NZ_21MHz = cell2mat(table2cell(Tx_NZ_21MHz(:,5)));

%x = find(Aprtime_uk(:,4)>6 & Aprtime_uk(:,4)<=12,3);
figure(10)
subplot(2,1,1)
scatter(datetime(Aprtime_nz_7MHz) ,SNR_NZ_7MHz,'r*');
hold on
scatter(datetime(Aprtime_nz_10MHz),SNR_NZ_10MHz,'b*');
scatter(datetime(Aprtime_nz_14MHz),SNR_NZ_14MHz,'g*');
scatter(datetime(Aprtime_nz_21MHz),SNR_NZ_21MHz,'k*');
legend('NZ 7 MHz Band','NZ 10 MHz band','NZ 14 MHz band','NZ 21 MHz band');
xlabel('Date');
ylabel('Received SNR (dB)');
title('Figure A: SNR recorded from the UK Receivers in April 2018');
set(gca,'FontSize',20);

subplot(2,1,2)
scatter(Aprtime_nz_snr_hour_7MHz,SNR_NZ_7MHz,'*','r');
hold on
scatter(Aprtime_nz_snr_hour_10MHz,SNR_NZ_10MHz,'*','b');
scatter(Aprtime_nz_snr_hour_14MHz,SNR_NZ_14MHz,'*','g');
scatter(Aprtime_nz_snr_hour_21MHz,SNR_NZ_21MHz,'*','k');
grid on
set(gca,'FontSize',20);
set(gca,'XTick',(0:1:24));
xlabel('Hours (UTC)');
ylabel('Received SNR (dB)');
title('Figure B: Received SNR from NZ to the UK on a hourly basis');
set(gca,'FontSize',20);
xlim([0 24]); %datenum format from 0 to 24 hours (midnight to midnight) 
legend('NZ 7 MHz Band','NZ 10 MHz band','NZ 14 MHz band','NZ 21 MHz band');
%datetick('x','keepticks','keeplimits');

saveas(gcf,'UKNZ_WSPR_April_SNR_UK.fig');
saveas(gcf,'UKNZ_WSPR_April_SNR_UK.jpg');

%% Figure 11 - UK Receivers 

time_of_day_nz = Aprtime_nz(:,3) + Aprtime_nz(:,4)/24 +Aprtime_nz(:,5)/60;
figure(11)
scatter(time_of_day_nz, Tx_NZ{:,5},'r*');
legend('SNR from the UK receivers');
xlabel('Date and hours(UTC)');
datetick('x','dd');
ylabel('SNR (dB)');
title('Received SNR from the UK receivers');
set(gca,'FontSize',20);

saveas(gcf,'UKNZ_WSPR_April_Rx_SNR_UK.fig');
saveas(gcf,'UKNZ_WSPR_April_Rx_SNR_UK.jpg');
%% Figure 12 - UK Transmitters 
time_of_day_uk = Aprtime_uk(:,3) + Aprtime_uk(:,4)/24 +Aprtime_uk(:,5)/60;
figure(12)
scatter(time_of_day_uk, Tx_UK{:,5},'b*');
xlabel('Date and hours(UTC)');
legend('SNR from the NZ receivers');
ylabel('SNR (dB)');
title('Received SNR from the NZ receivers');
set(gca,'FontSize',20);
saveas(gcf,'UKNZ_WSPR_April_Rx_SNR_NZ.fig');
saveas(gcf,'UKNZ_WSPR_April_Rx_SNR_NZ.jpg');
%% Figure 13 
figure (13)
subplot(2,1,1)
histogram(Aprtime_nz(:,3),'FaceColor','b');
legend('Radio links made from NZ');
set(gca,'FontSize',20);
set(gca,'XTick',(0:1:32));
xlim([0 31]);
xlabel('april Days');
ylabel('Number of established radio links');
title('Histogram of the radio links transmitted from NZ to the UK');
subplot(2,1,2)
histogram(Aprtime_uk(:,3),'FaceColor','r');
legend('Radio links made from the UK');
set(gca,'FontSize',20);
set(gca,'XTick',(0:1:31));
xlim([0 31]);
xlabel('april Days');
ylabel('Number of established radio links');
title('Histogram of the radio links transmitted from the UK to NZ');

saveas(gcf,'UKNZ_WSPR_April_Radiolinks_NZ.fig');
saveas(gcf,'UKNZ_WSPR_April_Radiolinks_NZ.jpg');

%% Figure 14 - UK Distance

distance_UK = cell2mat(table2cell(Tx_UK(:,11)));
distance_UK_7MHz = cell2mat(table2cell(Tx_UK_7MHz(:,11)));
distance_UK_10MHz = cell2mat(table2cell(Tx_UK_10MHz(:,11)));
distance_UK_14MHz = cell2mat(table2cell(Tx_UK_14MHz(:,11)));
distance_UK_21MHz = cell2mat(table2cell(Tx_UK_21MHz(:,11)));


distance_NZ = cell2mat(table2cell(Tx_NZ(:,11)));
distance_NZ_7MHz = cell2mat(table2cell(Tx_NZ_7MHz(:,11)));
distance_NZ_10MHz = cell2mat(table2cell(Tx_NZ_10MHz(:,11)));
distance_NZ_14MHz = cell2mat(table2cell(Tx_NZ_14MHz(:,11)));
distance_NZ_21MHz = cell2mat(table2cell(Tx_NZ_21MHz(:,11)));


figure(14)
subplot(2,1,1)
scatter(datetime(Aprtime_nz_7MHz),distance_NZ_7MHz,'*','r');
hold on
scatter(datetime(Aprtime_nz_10MHz),distance_NZ_10MHz,'*','b');
scatter(datetime(Aprtime_nz_14MHz),distance_NZ_14MHz,'*','g');
scatter(datetime(Aprtime_nz_21MHz),distance_NZ_21MHz,'*','k');
xlabel('Date');
ylabel('Distance (km)');
title('Figure A: Distance recorded from the UK Receivers in April 2018');
set(gca,'FontSize',20);
legend('NZ 7 MHz Band','NZ 10 MHz band','NZ 14 MHz band','NZ 21 MHz band');

subplot(2,1,2)
scatter(Aprtime_nz_snr_hour_7MHz,distance_NZ_7MHz,'*','r');
hold on
scatter(Aprtime_nz_snr_hour_10MHz,distance_NZ_10MHz,'*','b');
scatter(Aprtime_nz_snr_hour_14MHz,distance_NZ_14MHz,'*','g');
scatter(Aprtime_nz_snr_hour_21MHz,distance_NZ_21MHz,'*','k');

grid on
set(gca,'FontSize',20);
set(gca,'XTick',(0:1:24));
xlabel('Hours (UTC)');
ylabel('Distance (km)');
title('Figure B: Distance from the UK Receivers on a hourly basis');
set(gca,'FontSize',20);
xlim([0 24]); %datenum format from 0 to 24 hours (midnight to midnight) 
legend('NZ 7 MHz Band','NZ 10 MHz band','NZ 14 MHz band','NZ 21 MHz band');
%datetick('x','keepticks','keeplimits');
saveas(gcf,'UKNZ_WSPR_April_distance_UK.fig');
saveas(gcf,'UKNZ_WSPR_April_distance_UK.jpg');

%% Figure 15 - NZ Distance 
figure(15)
subplot(2,1,1)
scatter(datetime(Aprtime_uk_7MHz) ,distance_UK_7MHz,'*','r');
hold on
scatter(datetime(Aprtime_uk_10MHz),distance_UK_10MHz,'*','b');
scatter(datetime(Aprtime_uk_14MHz),distance_UK_14MHz,'*','g');
scatter(datetime(Aprtime_uk_21MHz),distance_UK_21MHz,'*','k');
xlabel('Date');
ylabel('Received SNR (dB)');
title('Figure A: Distance recorded from the NZ Receivers in April 2018');
set(gca,'FontSize',20);
legend('UK 7 MHz Band','UK 10 MHz band','UK 14 MHz band','UK 21 MHz band');

subplot(2,1,2)
scatter(Aprtime_uk_snr_hour_7MHz,distance_UK_7MHz,'*','r');
hold on
scatter(Aprtime_uk_snr_hour_10MHz,distance_UK_10MHz,'*','b');
scatter(Aprtime_uk_snr_hour_14MHz,distance_UK_14MHz,'*','g');
scatter(Aprtime_uk_snr_hour_21MHz,distance_UK_21MHz,'*','k');

grid on
xlabel('Hours (UTC)');
ylabel('Distance (km)');
title('Figure B: Distance recorded from the NZ Receivers on a hourly basis');
set(gca,'FontSize',20);
set(gca,'XTick',(0:1:24));
xlim([0 24]);
legend('UK 7 MHz Band','UK 10 MHz band','UK 14 MHz band','UK 21 MHz band');
%xl = xlim
%xl= xlim
%datetick('x','mm-dd');
saveas(gcf,'UKNZ_WSPR_April_distance_NZ.fig');
saveas(gcf,'UKNZ_WSPR_April_distance_NZ.jpg');
%%
save('April_kp_comparison.mat');
