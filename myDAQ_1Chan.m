%% MATLAB myDAQ Data Acquisition File
% CREATED BY:   Garrett Wood (8/5/2017)
% MODIFIED BY:  Joseph B. Tipton, Jr. (2/22/2018)
% DESCRIPTION:  This program will use Hardware Timed Finite Sampling
%               to collect data on 2, differential, AI channels
%               simultaneously.

clc
clear all

%% Graphical User Interface
        prompt = {'Enter either 2 or 10 for voltage range:','Enter sampling rate (Hz):','Enter test duration (sec):'};
        dlg_title = 'Hardware Timed Finite Sampling';
        num_lines = 1;
        defaultans = {'2','1000','1'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if str2num(answer{1,:})~=2 && str2num(answer{1,:})~=10
            error('Valid voltage ranges for NI myDAQ are +- 2V and +- 10V')
        end
        VoltageRange = [-str2num(answer{1,:}), str2num(answer{1,:})];
        Rate = str2num(answer{2,:});
        Duration = str2num(answer{3,:});


%% Collect Data from the NI myDAQ using the MATLAB Drivers
        Data = HWT_Finite( VoltageRange, Rate , Duration );


%% CUSTOM ANALYSIS
    % Once data collection is complete, you will have an array called
    % "Data".  You can add your custom code here to analyze the data as
    % needed.


%% Data Collection Subroutines ============================================

function [ Data ] = HWT_Finite( range, rate , dur )

    %%  Create a data acquisition session
    
    daqSession_0 = daq.createSession( 'ni' );

    %%  Add channels specified by subsystem type and device
    
    ch1 = daqSession_0.addAnalogInputChannel( 'myDAQ1' , 'ai0' , 'Voltage' );
    ch1.Range = range;
    
    ch2 = daqSession_0.addAnalogInputChannel( 'myDAQ1' , 'ai1' , 'Voltage' );
    ch2.Range = range;
    
    %%  Configure properties
    
    daqSession_0.DurationInSeconds = dur;
    daqSession_0.Rate = rate;

    %%  Begin Data Acquisition Session
    
    [ SessionData , Times ] = daqSession_0.startForeground();
    Data = [ Times , SessionData ];
    
    %%  Disconnect from the device
    
    daqSession_0.release();
    delete( daqSession_0 );
    clear daqSession_0;
    
end 
