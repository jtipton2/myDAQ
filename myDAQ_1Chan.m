%% MATLAB myDAQ Data Acquisition File
% Created by Garrett Wood (8/5/2017)
% Modified by Joseph B. Tipton, Jr. (2/7/2018)

clc
clear all

%% Graphical User Interface
str = {'Hardware Timed Continuous Sampling','Software Timed Continuous Sampling','Hardware Timed Finite Sampling','Software Timed Finite Sampling'};
[s,v] = listdlg('PromptString','Select one mode of data collection:',...
                'SelectionMode','single',...
                'ListString',str,...
                'ListSize',[300 160]);
            
if v == 0
    error('You must select a DAQ mode.')
end

switch s
    case 1
        %Hardware Timed Continuous Sampling
        prompt = {'Enter either 2 or 10 for voltage range:','Enter sampling rate (Hz):'};
        dlg_title = 'Hardware Timed Continuous Sampling';
        num_lines = 1;
        defaultans = {'2','1000'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if str2num(answer{1,:})~=2 && str2num(answer{1,:})~=10
            error('Valid voltage ranges for NI myDAQ are +- 2V and +- 10V')
        end
        VoltageRange = [-str2num(answer{1,:}), str2num(answer{1,:})];
        Rate = str2num(answer{2,:});
        
        Data = HWT_Continuous( VoltageRange, Rate );
    case 2
        %Software Timed Continuous Sampling
        msgbox( 'This feature is still in development.')
    case 3
        %Hardware Timed Finite Sampling
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
        
        Data = HWT_Finite( VoltageRange, Rate , Duration );
    case 4
        %Software Timed Finite Sampling
        prompt = {'Enter either 2 or 10 for voltage range:','Enter pause between samples (sec):','Enter number of samples:'};
        dlg_title = 'Software Timed Finite Sampling';
        num_lines = 1;
        defaultans = {'2','0.5','4'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if str2num(answer{1,:})~=2 && str2num(answer{1,:})~=10
            error('Valid voltage ranges for NI myDAQ are +- 2V and +- 10V')
        end
        VoltageRange = [-str2num(answer{1,:}), str2num(answer{1,:})];
        Pause = str2num(answer{2,:});
        NSamples = str2num(answer{3,:});
        
        Data = SWT_Finite( VoltageRange, Pause , NSamples );
    otherwise
        error('You must select a DAQ mode.')
end

%% Data Collection Subroutines
function [ Data ] = HWT_Continuous( range, rate )
    
    Times = [];
    SessionData = [];
    
    %%  Create a data acquisition session
    
    daqSession_0 = daq.createSession( 'ni' );

    %%  Add channels specified by subsystem type and device
    
    ch1 = daqSession_0.addAnalogInputChannel( 'myDAQ1' , 'ai0' , 'Voltage' );
    ch1.Range = range;
    
    %%  Configure properties
    
    daqSession_0.Rate = rate;
    daqSession_0.IsContinuous = 1;
    daqSession_0.addlistener( 'DataAvailable' , @HWT_C_Data );
    
    %% Data Acquisition Procedure
    
    function HWT_C_Data( ~ , event )
        
        Times = [ Times ; event.TimeStamps ];
        SessionData = [ SessionData ; event.Data ];
        plot( Times , SessionData )
        
    end

    %%  Begin Data Acquisition Session
    
    daqSession_0.startBackground();
    fprintf( 'Click on figure to end Data Acquisition.\n' )
    waitforbuttonpress;
    fprintf( 'Data Acquisition ended.\n' )
    Data = [ Times , SessionData ];
    daqSession_0.stop()
    
    %%  Disconnect from the device
    
    daqSession_0.release();
    delete( daqSession_0 );
    clear daqSession_0;
    
end 


function [ Data ] = HWT_Finite( range, rate , dur )

    %%  Create a data acquisition session
    
    daqSession_0 = daq.createSession( 'ni' );

    %%  Add channels specified by subsystem type and device
    
    ch1 = daqSession_0.addAnalogInputChannel( 'myDAQ1' , 'ai0' , 'Voltage' );
    ch1.Range = range;
    
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


function [ Data ] = SWT_Finite( range, delay , N )

    %% Test Code for Timer Function
    Data = TestTimer( range, N , delay );

    function [ Data ] = TestTimer( range, N , delay )

        %% Timer Setup

        Data = [];
        AcquisitionTimer = timer;
        AcquisitionTimer.TimerFcn = @( ~ , thisEvent ) TimedData(range);
        AcquisitionTimer.TasksToExecute = N;
        AcquisitionTimer.Period = delay;
        AcquisitionTimer.ExecutionMode = 'fixedrate';
        start( AcquisitionTimer )

        %% Kill Timer

        pause( delay*N ) 
        delete( AcquisitionTimer )

        function TimedData(range)

            %% Acquisition Setup

            daqSession_0 = daq.createSession( 'ni' );
            ch1 = daqSession_0.addAnalogInputChannel( 'myDAQ1' , 'ai0' , 'Voltage' );
            ch1.Range = range;
                        
            Data = [ Data ; clock , daqSession_0.inputSingleScan; ];

            daqSession_0.release();
            delete( daqSession_0 );
            clear daqSession_0;  

        end

    end

end
