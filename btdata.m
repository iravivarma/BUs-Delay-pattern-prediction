clc
clear all
close all
m = readtable('btBusData.noHeader.csv-000.txt');
A=m;
NextStop=table2array(A(:,1));
X_LastReport=table2array(A(:,2));
LineNr=table2array(A(:,3));
Destination=table2array(A(:,4));
x_collectedTimestamp=table2array(A(:,5));
Longitude=table2array(A(:,6));
Delay=table2array(A(:,7));
x_NextStopArrival=table2array(A(:,8));
NextStopName=table2array(A(:,9));
LastRe=cell2mat(table2array(A(:,10)));
LastReport = datetime(LastRe,'InputFormat','yyy-MM-dd''T''HH:mm:ss');
cog=table2array(A(:,11));
UnitId=table2array(A(:,12));
Latitude=table2array(A(:,13));
TripNr=table2array(A(:,14));
NextStopArrival=table2array(A(:,15));
tp = find(LineNr==6);
t1=UnitId(tp);
%tu=find(UnitId==101214);
tu=find(UnitId==101222 & TripNr==41 & LineNr==6);
timeInterval=diff(LastReport(tu));
figure,plot(timeInterval),title('Time interval')
InitTime=0;
timeV=zeros(length(timeInterval)+1,1);
timeV(1)=InitTime;
for kk=1:length(timeInterval)
    timeV(kk+1)=timeV(kk)+seconds(timeInterval(kk));
end
ns=NextStop(tu);
figure,plot(timeV,ns,'b')
title('X=time, Y=Staion code, showing the time to approach a station')
dl=Delay(tu);
figure,plot(timeV,ns,'r'),hold on
plot(timeV,dl+ns,'k'),title('delay to approach a station')
NextSationsList=-200;
for kk=1:length(ns)
    if isempty(find(NextSationsList==ns(kk), 1))
        NextSationsList=[NextSationsList,ns(kk)];
    end
end
NextSationsList=NextSationsList(2:end);
for kk=1:length(NextSationsList)
    timeSeries(kk).station= NextSationsList(kk);
    tp=find(ns==NextSationsList(kk));
    delayV=dl(tp);
    timeSeries(kk).delayV=delayV;
    tV=timeV(tp);
    timeSeries(kk).time=tV;
end
%%%%%%%%%%%%%%%%%%%%
figure,hold on, title('Delay time series for each station approach')
for kk=1:length(NextSationsList)
    
    plot(timeSeries(kk).time,timeSeries(kk).delayV)
end
figure,plot(timeSeries(2).time,timeSeries(2).delayV,'*'),hold on
length(timeSeries(2).delayV)
numberOfMissingPoints=max(timeSeries(2).delayV)- min(timeSeries(2).delayV)-length(timeSeries(2).delayV);

indexOfCurrentPoints=timeSeries(2).time-min(timeSeries(2).time)+1
figure,plot(indexOfCurrentPoints+120,timeSeries(2).delayV,'r*'),hold on
plot(indexOfCurrentPoints+120,timeSeries(2).delayV,'b')

tt=timeSeries(2).time;
yy=timeSeries(2).delayV;

indexOfMissingPoints=[];
pp=1;
for kk=1:length(min(tt):max(tt))
    
    if kk==indexOfCurrentPoints(pp)
        pp=pp+1;
    else
        indexOfMissingPoints=[indexOfMissingPoints,kk];%wrong
    end
    
end

%%%%%%%%%%%%%%%%%
% recoverY(1:length(min(tt):max(tt)))=0;
% recoverY(indexOfCurrentPoints)=yy;
% recoverY(recoverY==0)=NaN;
% Y2=fillgaps(recoverY,4,3);
%Resampling 
yy1=ones(size(yy,1)-1,1);
yy1(1:6,1)=yy(1:6,1);
yy1(7:11,1)=yy(8:12,1);
indexOfCurrentPoints1=ones(size(yy,1)-1,1); 
indexOfCurrentPoints1(1:6,1)=indexOfCurrentPoints(1:6,1);
indexOfCurrentPoints1(7:11,1)=indexOfCurrentPoints(8:12,1);
recoverY1=yy1;
recoverY(1:length(min(tt):max(tt)))=0;  
recoverY(indexOfCurrentPoints1)=yy1;
recoverY(recoverY==0)=NaN;
Y2=resample(recoverY1,indexOfCurrentPoints1,1,length(min(tt):max(tt)),length(yy1),'linear');
% 
% recoverY(1:length(min(tt):max(tt)))=0;    
% recoverY(indexOfCurrentPoints)=yy;
% Y2=recoverY;
% %adding random values
% Y2(Y2==0)=((rand(size(Y2(Y2==0))).*9)+1).*9; 
% recoverY(recoverY==0)=NaN;  
%%%%%%%%%%%% 
timeIndex=1:length(min(tt):max(tt));
figure,stem(timeIndex,Y2,'r'), hold on
stem(timeIndex,recoverY,'g*')


