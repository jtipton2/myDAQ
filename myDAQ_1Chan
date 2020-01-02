%% MATLAB myDAQ Data Acquisition File
%

clc ; close all

%% Configuration Variables

Continuous = 0; % Set to 0 for finite data Acquisition
HardwareTimed = 0; % Set to 0 for software timed data Acquisition.
Rate = 1; 
NSamples = 20;
Duration = 10;
Pause = 1;

%% Method Selection

if Continuous == 1 && HardwareTimed == 1
    
    Data = HWT_Continuous( Rate );
    
elseif Continuous == 1 && HardwareTimed == 0
    
    Data = SWT_Continuous( Pause , NSamples ); % SWT_Continuous may be run without the "NSamples" input but the acquisition must then be ended manually.
    
elseif Continuous == 0 && HardwareTimed == 1
    
    Data = HWT_Finite( Rate , Duration );
    
elseif Continuous == 0 && HardwareTimed == 0    
    
    Data = SWT_Finite( Pause , NSamples );
    
end

%% Hardware Timed Continuous Data Acquisition

function [ Data ] = HWT_Continuous( rate )
    
    Times = [];
    SessionData = [];
    
    %%  Create a data acquisition session
    
    daqSession_0 = daq.createSession( 'ni' );

    %%  Add channels specified by subsystem type and device
    
    daqSession_0.addAnalogInputChannel( 'myDAQ1' , 'ai0' , 'Voltage' );

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

%% Hardware Timed Finite Data Acquisition

function [ Data ] = HWT_Finite( rate , dur )

    %%  Create a data acquisition session
    
    daqSession_0 = daq.createSession( 'ni' );

    %%  Add channels specified by subsystem type and device
    
    daqSession_0.addAnalogInputChannel( 'myDAQ1' , 'ai0' , 'Voltage' );

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

%% Software Timed Continuous Data Acquisition

function [ Data ] = SWT_Continuous( delay , N ) 

       
    daqSession_0 = daq.createSession( 'ni' );
    daqSession_0.addAnalogInputChannel( 'myDAQ1' , 'ai0' , 'Voltage' ); 
    Data = [];
    
    switch nargin
        
        case 2
    
            while length( Data ) < N
        
                Data = [ Data ; clock , daqSession_0.inputSingleScan; ];
                pause( delay )

            end
            
        case 1
            
            msgbox( 'To end the Data Acquisition press " ctrl + c ".')
            
            while ( 1 )
        
                Data = [ Data ; clock , daqSession_0.inputSingleScan; ];
                pause( delay )

            end
            
    end
    
    daqSession_0.release();
    delete( daqSession_0 );
    clear daqSession_0;  
    
end
    
%% Software Timed Finite Data Acquisition

function [ Data ] = SWT_Finite( delay , N )

    %% Test Code for Timer Function
    Data = TestTimer( N , delay );

    function [ Data ] = TestTimer( N , delay )

        %% Timer Setup

        Data = [];
        AcquisitionTimer = timer;
        AcquisitionTimer.TimerFcn = @( ~ , thisEvent ) TimedData;
        AcquisitionTimer.TasksToExecute = N;
        AcquisitionTimer.Period = delay;
        AcquisitionTimer.ExecutionMode = 'fixedrate';
        start( AcquisitionTimer )

        %% Kill Timer

        pause( delay*N ) 
        delete( AcquisitionTimer )

        function TimedData

            %% Acquisition Setup

            daqSession_0 = daq.createSession( 'ni' );
            daqSession_0.addAnalogInputChannel( 'myDAQ1' , 'ai0' , 'Voltage' ); 
            Data = [ Data ; clock , daqSession_0.inputSingleScan; ];

            daqSession_0.release();
            delete( daqSession_0 );
            clear daqSession_0;  

        end

    end

end
