classdef SolarPanelAssistantV2_1_code < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        SweepPlotTab                    matlab.ui.container.Tab
        mALabel                         matlab.ui.control.Label
        mVLabel                         matlab.ui.control.Label
        EditField_2                     matlab.ui.control.NumericEditField
        EditField                       matlab.ui.control.NumericEditField
        Lamp_3                          matlab.ui.control.Lamp
        Lamp_2                          matlab.ui.control.Lamp
        ConnectDeviceButton             matlab.ui.control.Button
        SelectSaveFolderButton          matlab.ui.control.Button
        VoltageSwipePanel               matlab.ui.container.Panel
        CancelButton                    matlab.ui.control.Button
        MaxCurrentEditField             matlab.ui.control.NumericEditField
        MaxCurrentEditFieldLabel        matlab.ui.control.Label
        Standardis1000Label             matlab.ui.control.Label
        Lamp                            matlab.ui.control.Lamp
        LampLabel                       matlab.ui.control.Label
        NumberofDataEditField           matlab.ui.control.NumericEditField
        NumberofDataEditFieldLabel      matlab.ui.control.Label
        StartSwipeButton                matlab.ui.control.Button
        InputVoltageVEditField          matlab.ui.control.NumericEditField
        InputVoltageVEditFieldLabel     matlab.ui.control.Label
        EnterFileNameEditField          matlab.ui.control.EditField
        EnterFileNameEditFieldLabel     matlab.ui.control.Label
        PlottingTab                     matlab.ui.container.Tab
        LogScaleOnOffCheckBox           matlab.ui.control.CheckBox
        FitCheckBox                     matlab.ui.control.CheckBox
        CreatingPlotPanel               matlab.ui.container.Panel
        TabGroup2                       matlab.ui.container.TabGroup
        ForwardBiasTab                  matlab.ui.container.Tab
        Panel                           matlab.ui.container.Panel
        PercentageErrorEditField        matlab.ui.control.EditField
        PercentageErrorLabel            matlab.ui.control.Label
        NumberofCellsEditField          matlab.ui.control.EditField
        NumberofCellsEditFieldLabel     matlab.ui.control.Label
        ThresholdPotentialEditField     matlab.ui.control.EditField
        ThresholdPotentialLabel         matlab.ui.control.Label
        ReverseBiasTab                  matlab.ui.container.Tab
        Panel_2                         matlab.ui.container.Panel
        BreakdownVoltageEditField       matlab.ui.control.EditField
        BreakdownVoltageEditFieldLabel  matlab.ui.control.Label
        PercentageErrorEditField_2      matlab.ui.control.EditField
        PercentageErrorEditField_2Label  matlab.ui.control.Label
        NumberofBypassDiodeEditField    matlab.ui.control.EditField
        NumberofBypassDiodeLabel        matlab.ui.control.Label
        CellTypeDropDown                matlab.ui.control.DropDown
        CellTypeDropDownLabel           matlab.ui.control.Label
        SelectFilesButton               matlab.ui.control.Button
        UIAxes                          matlab.ui.control.UIAxes
        IOControlTab                    matlab.ui.container.Tab
        CurrentGauge                    matlab.ui.control.LinearGauge
        CurrentGaugeLabel               matlab.ui.control.Label
        VoltGauge                       matlab.ui.control.LinearGauge
        VoltGaugeLabel                  matlab.ui.control.Label
        OkButton_2                      matlab.ui.control.Button
        SetIEditField                   matlab.ui.control.NumericEditField
        SetIEditFieldLabel              matlab.ui.control.Label
        OkButton                        matlab.ui.control.Button
        OutputONOFFCheckBox             matlab.ui.control.CheckBox
        SetVEditField                   matlab.ui.control.NumericEditField
        SetVEditFieldLabel              matlab.ui.control.Label
        CloseAppButton                  matlab.ui.control.Button
    end

    
    properties (Access = private)
        vlt
        datanum
        in % Description
        lokas % Description
        setV % Description
        setI = 0.2 % Description
        visausb = 0 % Description
        txtval % Description
        analiz % Description
        flag  % Description
        tresh
        player        
        valuefit
        value
        sifirlarr
        h
        secilmisforward = 0.7;
        secilmisreverse = 0.573;
    end
    methods (Access = private)
    
        function confirmClose(app, ~, event)
            % Determine which dialog button the user clicked
            answer = event.SelectedOption;
            
            % Close the app if the user clicks OK 
            if strcmp(answer,'OK')
                delete(app);
            end
        end
        
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.EditField.BackgroundColor = 'k';
            app.EditField.FontColor = 'r';
            app.EditField.FontWeight = 'bold';
            app.EditField.FontSize =35;
            app.EditField_2.BackgroundColor = 'k';
            app.EditField_2.FontColor = 'r';
            app.EditField_2.FontWeight = 'bold';
            app.EditField_2.FontSize =35;          
        end

        % Button pushed function: SelectFilesButton
        function SelectFilesButtonPushed(app, event)
            f = figure('Renderer', 'painters', 'Position', [-100 -100 0 0]);
            [filename,path] = uigetfile('*.txt', 'Open text file','MultiSelect','on');
            delete(f); 
            hold(app.UIAxes,"off");
           
            if isequal(filename, 0)
               disp('User selected Cancel')
               return;
            end
            
            if ischar(filename)
                filename = {filename}; 
            end
            
            breakdown = zeros(1,size(filename,2));
            
            filename = cellstr(filename);
            
            for i= 1:size(filename,2)
                tableData = load(fullfile(path, sprintf("%s",filename{i}))); 
                potansiyel(:,i) = tableData(:,1);
                akim(:,i) = tableData(:,2);  

                r2 = 0.1;
                at = 0;
    
                while r2 < 0.995
                at = at+1;
                linearCoefficients = polyfit(potansiyel(at:end,i), akim(at:end,i), 1);          % Coefficients
                yfit = polyval(linearCoefficients, potansiyel(at:end,i));          % Estimated  Regression Line
                SStot = sum((akim(at:end,i) - mean(akim(at:end,i))).^2);                    % Total Sum-Of-Squares
                SSres = sum((akim(at:end,i) - yfit).^2);                       % Residual Sum-Of-Squares
                r2 = 1-SSres/SStot;  
                end
                a = linearCoefficients(1);
                b = linearCoefficients(2);
                ksi = @(y) (y-b)/a;
%                 ddenk = @(x) a*x+b;
                breakdown(1,i) = ksi(0);
            end
           
            cellNumber = zeros(1,size(filename,2));
            sifirlar = zeros(1,size(breakdown,2));
            sz = 5;

            app.NumberofCellsEditField.Value = '';
            app.PercentageErrorEditField.Value ='';
            app.ThresholdPotentialEditField.Value ='';

            app.BreakdownVoltageEditField.Value ='';
            app.NumberofBypassDiodeEditField.Value ='';
            app.PercentageErrorEditField_2.Value =''; 

            persError = zeros(1,size(filename,2));
            
            for i=1:size(filename,2) 

                averageval = app.secilmisforward;
                
                cellNumber(1,i) = round(breakdown(1,i)/averageval);
                persError(1,i) = abs((breakdown(1,i)/cellNumber(1,i))-averageval)*100/averageval;
                
                app.NumberofCellsEditField.Value = append(app.NumberofCellsEditField.Value,filename(1,i),": ", sprintf("%d, ",cellNumber(1,i)));
                app.PercentageErrorEditField.Value = append(app.PercentageErrorEditField.Value,filename(1,i) +": %"+ sprintf("%3.2f, ",persError(1,i)));
                app.ThresholdPotentialEditField.Value = append(app.ThresholdPotentialEditField.Value,filename(1,i) + sprintf(": %3.3f V, ",(breakdown(1,i)/cellNumber(1,i))));
                 
                averageval = app.secilmisreverse;
                
                bypassNumber(1,i) = round(breakdown(1,i)/averageval);
                bypassError(1,i) = abs((breakdown(1,i)/bypassNumber(1,i))-averageval)*100/averageval;  
            
                app.BreakdownVoltageEditField.Value = append(app.BreakdownVoltageEditField.Value,filename(1,i) + sprintf(": %3.3f V, ",(breakdown(1,i)/bypassNumber(1,i))));                             
                app.NumberofBypassDiodeEditField.Value = append(app.NumberofBypassDiodeEditField.Value,filename(1,i),": ", sprintf("%d, ",bypassNumber(1,i)));
                app.PercentageErrorEditField_2.Value = append(app.PercentageErrorEditField_2.Value,filename(1,i) +": %"+ sprintf("%3.2f, ",bypassError(1,i)));                   
                                                     
            end
         
            scatter(app.UIAxes,potansiyel,akim,sz,"filled")            
            hold(app.UIAxes,"on");
%             plot(a,ddenk(a),'LineWidth',2.0)
%             hold on

%             scatter(app.UIAxes,breakdown,sifirlar,"k","filled")
            legend(app.UIAxes,filename)
            
            
            for i =1:length(akim)
                akim1 = round(akim(i,1),6);
                if akim1 > 0
                        k=1;
                        summ=0;
                        while k>6
                            
                            summ=summ+round(akim(i+k,1),6);
                            k=k+1;
                        end
                    if summ == 0
                        tresh = akim1;
                        tresh = find(akim==tresh);
                        tresh=tresh(1,1);
                        tresh=potansiyel(tresh,1)
                        app.EditField_3.Value = tresh;
                        break 
                    end
                end


                
            end
%                        if 
%                     tresh = akim1; 
%                     tresh = find(akim==tresh);
%                     tresh=tresh(1,1);
%                     tresh=potansiyel(tresh,1)
%                     app.ThresholdEditField.Value = tresh;
%                     break
%                 end    
%             end 
            app.valuefit=breakdown;
            app.sifirlarr = sifirlar;
            app.h=scatter(app.UIAxes,app.valuefit,app.sifirlarr,"k","filled",'DisplayName','Fit');

        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            % Display confirmation dialog box
            msg = 'Are you sure you want to close?';
            uiconfirm(app.UIFigure,msg,'Confirm Close','CloseFcn',@app.confirmClose);
        end

        % Value changed function: LogScaleOnOffCheckBox
        function logscale(app, event)
            value = app.LogScaleOnOffCheckBox.Value;
            if value == 1
                set(app.UIAxes,"yscale","log")
            else 
                set(app.UIAxes,"yscale","linear")
            end
        end

        % Value changed function: InputVoltageVEditField
        function InputVoltageVEditFieldValueChanged(app, event)

            app.vlt = app.InputVoltageVEditField.Value;
            
        end

        % Value changed function: EnterFileNameEditField
        function EnterFileNameEditFieldValueChanged(app, event)

            app.in = app.EnterFileNameEditField.Value;
            
        end

        % Button pushed function: StartSwipeButton
        function StartSwipeButtonPushed(app, event)
            app.Lamp.Color = [0.9100 0.4100 0.1700];
            visausbIN = app.visausb;
            writeline(visausbIN,"Volt 0")
            writeline(visausbIN,"OUTPUT ON")
            writeline(visausbIN,"Volt 0")
            writeline(visausbIN,sprintf("CURRENT %f", app.setI))
            potential = linspace(0,app.vlt,app.datanum);
            current = zeros(1,app.datanum);
            
            i=0;
            app.flag = 1;
            
            while app.flag > 0
                i = i+1;
                
                writeline(visausbIN,sprintf("VOLTAGE %f", potential(i)))
                writeline(visausbIN,"VOLTAGE?");
                app.EditField.Value = str2double(readline(visausbIN));
                pause(0.00005);

                writeline(visausbIN,"FETCh:CURR?"); 
                current(i) = str2double(readline(visausbIN));
                app.EditField.Value = current(i);

                if i == app.datanum
                    app.flag = 0;
                end
            end

            potential = potential';
            current = current';
            
            writeline(visausbIN,"OUTPUT OFF")
            writeline(visausbIN,"Volt 0")
            
            isim  = append(app.lokas,"\",app.in,".txt");
            plotData = fopen(isim,"w");
            
            fprintf(plotData,"%f %f\n",[potential,current]');
            fclose(plotData);
            app.Lamp.Color = "g"; 
            
%            sound('ses.avm');
            [song,fs]=audioread('ses.wav');
            app.player = audioplayer(song, fs);
            play(app.player);
        end

        % Button pushed function: CloseAppButton
        function CloseAppButtonPushed(app, event)
            closereq(); 
        end

        % Value changed function: NumberofDataEditField
        function NumberofDataEditFieldValueChanged(app, event)

            app.datanum = app.NumberofDataEditField.Value;
            
        end

        % Button pushed function: SelectSaveFolderButton
        function SelectSaveFolderButtonPushed(app, event)
            app.lokas = uigetdir('C:\');
            app.Lamp_3.Color = "g";
        end

        % Value changed function: OutputONOFFCheckBox
        function OutputONOFFCheckBoxValueChanged(app, event)
            value = app.OutputONOFFCheckBox.Value;
            if value == 1
                writeline(app.visausb,"OUTPUT ON")
            else 
                writeline(app.visausb,"OUTPUT OFF")
            end
        end

        % Value changed function: SetVEditField
        function SetVEditFieldValueChanged(app, event)
            app.setV = app.SetVEditField.Value;
        end

        % Button pushed function: OkButton
        function OkButtonPushed(app, event)
            v = sprintf('VOLT %f',app.setV);
            writeline(app.visausb,v)
            writeline(app.visausb,"VOLTAGE?");
            app.VoltGauge.Value = str2double(readline(app.visausb));    
        end

        % Value changed function: SetIEditField
        function SetIEditFieldValueChanged(app, event)
            app.setI= app.SetIEditField.Value;
        end

        % Button pushed function: OkButton_2
        function OkButton_2Pushed(app, event)
            I = sprintf('CURRENT %f',app.setI);
            writeline(app.visausb,I)
            writeline(app.visausb,"CURRENT?");
            app.CurrentGauge.Value = str2double(readline(app.visausb));  
        end

        % Button pushed function: ConnectDeviceButton
        function ConnectDeviceButtonPushed(app, event)
            app.visausb = visadev("USB0::0x05E6::0x2200::9090113::INSTR");
            app.Lamp_2.Color = "g";
            disp(app.visausb)
        end

        % Callback function
        function CellAnalysisCheckBoxValueChanged(app, event)
           app.analiz = app.CellAnalysisCheckBox.Value;
            
        end

        % Value changed function: MaxCurrentEditField
        function MaxCurrentEditFieldValueChanged(app, event)
            app.setI = app.MaxCurrentEditField.Value;
            
        end

        % Button pushed function: CancelButton
        function CancelButtonPushed(app, event)
            app.flag = 0;
        end

        % Value changed function: FitCheckBox
        function FitCheckBoxValueChanged(app, event)
            value = app.FitCheckBox.Value;
            
            if value == 1
                app.h.Visible='on';
            else
                app.h.Visible='off';
            end
            
        end

        % Value changed function: CellTypeDropDown
        function CellTypeDropDownValueChanged(app, event)
             secilmistext = app.CellTypeDropDown.Value;
             secilmis = str2double(regexp(secilmistext,'\d*[\.]?\d*','match'));
             disp(secilmis)
             app.secilmisforward = secilmis(1,1);
             app.secilmisreverse = secilmis(1,2);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 776 506];
            app.UIFigure.Name = 'Solar Panel Assistant';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create CloseAppButton
            app.CloseAppButton = uibutton(app.UIFigure, 'push');
            app.CloseAppButton.ButtonPushedFcn = createCallbackFcn(app, @CloseAppButtonPushed, true);
            app.CloseAppButton.Position = [680 11 70 24];
            app.CloseAppButton.Text = {'Close App'; ''; ''};

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [14 45 753 448];

            % Create SweepPlotTab
            app.SweepPlotTab = uitab(app.TabGroup);
            app.SweepPlotTab.Title = 'Sweep/Plot';

            % Create VoltageSwipePanel
            app.VoltageSwipePanel = uipanel(app.SweepPlotTab);
            app.VoltageSwipePanel.Title = 'Voltage Swipe';
            app.VoltageSwipePanel.Position = [26 66 302 277];

            % Create EnterFileNameEditFieldLabel
            app.EnterFileNameEditFieldLabel = uilabel(app.VoltageSwipePanel);
            app.EnterFileNameEditFieldLabel.HorizontalAlignment = 'right';
            app.EnterFileNameEditFieldLabel.Position = [26 207 92 22];
            app.EnterFileNameEditFieldLabel.Text = 'Enter File Name';

            % Create EnterFileNameEditField
            app.EnterFileNameEditField = uieditfield(app.VoltageSwipePanel, 'text');
            app.EnterFileNameEditField.ValueChangedFcn = createCallbackFcn(app, @EnterFileNameEditFieldValueChanged, true);
            app.EnterFileNameEditField.Position = [132 207 100 22];

            % Create InputVoltageVEditFieldLabel
            app.InputVoltageVEditFieldLabel = uilabel(app.VoltageSwipePanel);
            app.InputVoltageVEditFieldLabel.HorizontalAlignment = 'right';
            app.InputVoltageVEditFieldLabel.Position = [22 177 95 22];
            app.InputVoltageVEditFieldLabel.Text = 'Input Voltage (V)';

            % Create InputVoltageVEditField
            app.InputVoltageVEditField = uieditfield(app.VoltageSwipePanel, 'numeric');
            app.InputVoltageVEditField.ValueChangedFcn = createCallbackFcn(app, @InputVoltageVEditFieldValueChanged, true);
            app.InputVoltageVEditField.Tooltip = {''};
            app.InputVoltageVEditField.Position = [132 177 100 22];

            % Create StartSwipeButton
            app.StartSwipeButton = uibutton(app.VoltageSwipePanel, 'push');
            app.StartSwipeButton.ButtonPushedFcn = createCallbackFcn(app, @StartSwipeButtonPushed, true);
            app.StartSwipeButton.BackgroundColor = [1 1 1];
            app.StartSwipeButton.Position = [21 27 100 22];
            app.StartSwipeButton.Text = 'Start Swipe';

            % Create NumberofDataEditFieldLabel
            app.NumberofDataEditFieldLabel = uilabel(app.VoltageSwipePanel);
            app.NumberofDataEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofDataEditFieldLabel.Position = [28 99 90 22];
            app.NumberofDataEditFieldLabel.Text = 'Number of Data';

            % Create NumberofDataEditField
            app.NumberofDataEditField = uieditfield(app.VoltageSwipePanel, 'numeric');
            app.NumberofDataEditField.ValueChangedFcn = createCallbackFcn(app, @NumberofDataEditFieldValueChanged, true);
            app.NumberofDataEditField.Position = [132 99 99 22];

            % Create LampLabel
            app.LampLabel = uilabel(app.VoltageSwipePanel);
            app.LampLabel.HorizontalAlignment = 'right';
            app.LampLabel.Position = [94 27 25 22];
            app.LampLabel.Text = '';

            % Create Lamp
            app.Lamp = uilamp(app.VoltageSwipePanel);
            app.Lamp.Position = [134 27 20 20];
            app.Lamp.Color = [0.8 0.8 0.8];

            % Create Standardis1000Label
            app.Standardis1000Label = uilabel(app.VoltageSwipePanel);
            app.Standardis1000Label.Position = [134 78 104 22];
            app.Standardis1000Label.Text = {'(Standard is 1000)'; ''};

            % Create MaxCurrentEditFieldLabel
            app.MaxCurrentEditFieldLabel = uilabel(app.VoltageSwipePanel);
            app.MaxCurrentEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxCurrentEditFieldLabel.Position = [46 143 71 22];
            app.MaxCurrentEditFieldLabel.Text = 'Max Current';

            % Create MaxCurrentEditField
            app.MaxCurrentEditField = uieditfield(app.VoltageSwipePanel, 'numeric');
            app.MaxCurrentEditField.ValueChangedFcn = createCallbackFcn(app, @MaxCurrentEditFieldValueChanged, true);
            app.MaxCurrentEditField.Position = [132 143 100 22];

            % Create CancelButton
            app.CancelButton = uibutton(app.VoltageSwipePanel, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.CancelButton.Position = [189 27 100 22];
            app.CancelButton.Text = 'Cancel';

            % Create SelectSaveFolderButton
            app.SelectSaveFolderButton = uibutton(app.SweepPlotTab, 'push');
            app.SelectSaveFolderButton.ButtonPushedFcn = createCallbackFcn(app, @SelectSaveFolderButtonPushed, true);
            app.SelectSaveFolderButton.Position = [192 375 122 28];
            app.SelectSaveFolderButton.Text = 'Select Save Folder';

            % Create ConnectDeviceButton
            app.ConnectDeviceButton = uibutton(app.SweepPlotTab, 'push');
            app.ConnectDeviceButton.ButtonPushedFcn = createCallbackFcn(app, @ConnectDeviceButtonPushed, true);
            app.ConnectDeviceButton.Position = [20 378 100 22];
            app.ConnectDeviceButton.Text = 'Connect Device';

            % Create Lamp_2
            app.Lamp_2 = uilamp(app.SweepPlotTab);
            app.Lamp_2.Position = [142 379 20 20];
            app.Lamp_2.Color = [0.8 0.8 0.8];

            % Create Lamp_3
            app.Lamp_3 = uilamp(app.SweepPlotTab);
            app.Lamp_3.Position = [326 379 20 20];
            app.Lamp_3.Color = [0.8 0.8 0.8];

            % Create EditField
            app.EditField = uieditfield(app.SweepPlotTab, 'numeric');
            app.EditField.Limits = [0 15];
            app.EditField.Position = [432 261 223 79];

            % Create EditField_2
            app.EditField_2 = uieditfield(app.SweepPlotTab, 'numeric');
            app.EditField_2.Limits = [0 0.5];
            app.EditField_2.Position = [432 133 223 79];

            % Create mVLabel
            app.mVLabel = uilabel(app.SweepPlotTab);
            app.mVLabel.Position = [661 261 25 22];
            app.mVLabel.Text = 'mV';

            % Create mALabel
            app.mALabel = uilabel(app.SweepPlotTab);
            app.mALabel.Position = [661 131 25 22];
            app.mALabel.Text = 'mA';

            % Create PlottingTab
            app.PlottingTab = uitab(app.TabGroup);
            app.PlottingTab.Title = 'Plotting';

            % Create UIAxes
            app.UIAxes = uiaxes(app.PlottingTab);
            title(app.UIAxes, 'I-V Plot')
            xlabel(app.UIAxes, 'Voltage')
            ylabel(app.UIAxes, 'Current')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [356 50 396 350];

            % Create CreatingPlotPanel
            app.CreatingPlotPanel = uipanel(app.PlottingTab);
            app.CreatingPlotPanel.Title = 'Creating Plot';
            app.CreatingPlotPanel.Position = [1 1 356 399];

            % Create SelectFilesButton
            app.SelectFilesButton = uibutton(app.CreatingPlotPanel, 'push');
            app.SelectFilesButton.ButtonPushedFcn = createCallbackFcn(app, @SelectFilesButtonPushed, true);
            app.SelectFilesButton.Position = [65 293 97 22];
            app.SelectFilesButton.Text = 'Select Files';

            % Create CellTypeDropDownLabel
            app.CellTypeDropDownLabel = uilabel(app.CreatingPlotPanel);
            app.CellTypeDropDownLabel.HorizontalAlignment = 'right';
            app.CellTypeDropDownLabel.Position = [5 338 55 22];
            app.CellTypeDropDownLabel.Text = 'Cell Type';

            % Create CellTypeDropDown
            app.CellTypeDropDown = uidropdown(app.CreatingPlotPanel);
            app.CellTypeDropDown.Items = {'Azur', 'Jessie'};
            app.CellTypeDropDown.ItemsData = {'0.7,0.573', '1.488,0.4', ''};
            app.CellTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @CellTypeDropDownValueChanged, true);
            app.CellTypeDropDown.Position = [65 338 100 22];
            app.CellTypeDropDown.Value = '0.7,0.573';

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.CreatingPlotPanel);
            app.TabGroup2.Position = [1 0 354 273];

            % Create ForwardBiasTab
            app.ForwardBiasTab = uitab(app.TabGroup2);
            app.ForwardBiasTab.Title = 'Forward Bias';

            % Create Panel
            app.Panel = uipanel(app.ForwardBiasTab);
            app.Panel.Position = [7 14 338 229];

            % Create ThresholdPotentialLabel
            app.ThresholdPotentialLabel = uilabel(app.Panel);
            app.ThresholdPotentialLabel.Position = [12 112 112 27];
            app.ThresholdPotentialLabel.Text = {'Threshold '; 'Potential'};

            % Create ThresholdPotentialEditField
            app.ThresholdPotentialEditField = uieditfield(app.Panel, 'text');
            app.ThresholdPotentialEditField.Editable = 'off';
            app.ThresholdPotentialEditField.Position = [110 102 211 46];

            % Create NumberofCellsEditFieldLabel
            app.NumberofCellsEditFieldLabel = uilabel(app.Panel);
            app.NumberofCellsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofCellsEditFieldLabel.Position = [6 171 91 22];
            app.NumberofCellsEditFieldLabel.Text = 'Number of Cells';

            % Create NumberofCellsEditField
            app.NumberofCellsEditField = uieditfield(app.Panel, 'text');
            app.NumberofCellsEditField.Editable = 'off';
            app.NumberofCellsEditField.Position = [110 160 210 42];

            % Create PercentageErrorLabel
            app.PercentageErrorLabel = uilabel(app.Panel);
            app.PercentageErrorLabel.Position = [12 48 67 28];
            app.PercentageErrorLabel.Text = {'Percentage'; 'Error(%)'};

            % Create PercentageErrorEditField
            app.PercentageErrorEditField = uieditfield(app.Panel, 'text');
            app.PercentageErrorEditField.Editable = 'off';
            app.PercentageErrorEditField.Position = [110 39 211 46];

            % Create ReverseBiasTab
            app.ReverseBiasTab = uitab(app.TabGroup2);
            app.ReverseBiasTab.Title = 'Reverse Bias';

            % Create Panel_2
            app.Panel_2 = uipanel(app.ReverseBiasTab);
            app.Panel_2.Position = [7 14 338 229];

            % Create NumberofBypassDiodeLabel
            app.NumberofBypassDiodeLabel = uilabel(app.Panel_2);
            app.NumberofBypassDiodeLabel.Position = [12 169 80 28];
            app.NumberofBypassDiodeLabel.Text = {'Number of '; 'Bypass Diode'};

            % Create NumberofBypassDiodeEditField
            app.NumberofBypassDiodeEditField = uieditfield(app.Panel_2, 'text');
            app.NumberofBypassDiodeEditField.Editable = 'off';
            app.NumberofBypassDiodeEditField.Position = [110 160 210 42];

            % Create PercentageErrorEditField_2Label
            app.PercentageErrorEditField_2Label = uilabel(app.Panel_2);
            app.PercentageErrorEditField_2Label.Position = [12 48 67 28];
            app.PercentageErrorEditField_2Label.Text = {'Percentage'; 'Error(%)'};

            % Create PercentageErrorEditField_2
            app.PercentageErrorEditField_2 = uieditfield(app.Panel_2, 'text');
            app.PercentageErrorEditField_2.Editable = 'off';
            app.PercentageErrorEditField_2.Position = [110 39 210 46];

            % Create BreakdownVoltageEditFieldLabel
            app.BreakdownVoltageEditFieldLabel = uilabel(app.Panel_2);
            app.BreakdownVoltageEditFieldLabel.Position = [12 112 112 27];
            app.BreakdownVoltageEditFieldLabel.Text = {'Breakdown'; 'Voltage'};

            % Create BreakdownVoltageEditField
            app.BreakdownVoltageEditField = uieditfield(app.Panel_2, 'text');
            app.BreakdownVoltageEditField.Editable = 'off';
            app.BreakdownVoltageEditField.Position = [110 102 210 46];

            % Create FitCheckBox
            app.FitCheckBox = uicheckbox(app.PlottingTab);
            app.FitCheckBox.ValueChangedFcn = createCallbackFcn(app, @FitCheckBoxValueChanged, true);
            app.FitCheckBox.Text = 'Fit';
            app.FitCheckBox.Position = [631 15 35 22];

            % Create LogScaleOnOffCheckBox
            app.LogScaleOnOffCheckBox = uicheckbox(app.PlottingTab);
            app.LogScaleOnOffCheckBox.ValueChangedFcn = createCallbackFcn(app, @logscale, true);
            app.LogScaleOnOffCheckBox.Text = 'Log Scale On/Off';
            app.LogScaleOnOffCheckBox.Position = [462 15 114 22];

            % Create IOControlTab
            app.IOControlTab = uitab(app.TabGroup);
            app.IOControlTab.Title = 'I/O Control';

            % Create SetVEditFieldLabel
            app.SetVEditFieldLabel = uilabel(app.IOControlTab);
            app.SetVEditFieldLabel.HorizontalAlignment = 'right';
            app.SetVEditFieldLabel.Position = [42 240 35 22];
            app.SetVEditFieldLabel.Text = 'Set V';

            % Create SetVEditField
            app.SetVEditField = uieditfield(app.IOControlTab, 'numeric');
            app.SetVEditField.ValueChangedFcn = createCallbackFcn(app, @SetVEditFieldValueChanged, true);
            app.SetVEditField.Position = [92 240 100 22];

            % Create OutputONOFFCheckBox
            app.OutputONOFFCheckBox = uicheckbox(app.IOControlTab);
            app.OutputONOFFCheckBox.ValueChangedFcn = createCallbackFcn(app, @OutputONOFFCheckBoxValueChanged, true);
            app.OutputONOFFCheckBox.Text = 'Output ON/OFF';
            app.OutputONOFFCheckBox.Position = [49 307 107 22];

            % Create OkButton
            app.OkButton = uibutton(app.IOControlTab, 'push');
            app.OkButton.ButtonPushedFcn = createCallbackFcn(app, @OkButtonPushed, true);
            app.OkButton.Position = [213 240 100 22];
            app.OkButton.Text = 'Ok';

            % Create SetIEditFieldLabel
            app.SetIEditFieldLabel = uilabel(app.IOControlTab);
            app.SetIEditFieldLabel.HorizontalAlignment = 'right';
            app.SetIEditFieldLabel.Position = [43 194 30 22];
            app.SetIEditFieldLabel.Text = 'Set I';

            % Create SetIEditField
            app.SetIEditField = uieditfield(app.IOControlTab, 'numeric');
            app.SetIEditField.ValueChangedFcn = createCallbackFcn(app, @SetIEditFieldValueChanged, true);
            app.SetIEditField.Position = [92 194 101 22];

            % Create OkButton_2
            app.OkButton_2 = uibutton(app.IOControlTab, 'push');
            app.OkButton_2.ButtonPushedFcn = createCallbackFcn(app, @OkButton_2Pushed, true);
            app.OkButton_2.Position = [214 193 100 22];
            app.OkButton_2.Text = 'Ok';

            % Create VoltGaugeLabel
            app.VoltGaugeLabel = uilabel(app.IOControlTab);
            app.VoltGaugeLabel.HorizontalAlignment = 'center';
            app.VoltGaugeLabel.Position = [502 234 26 22];
            app.VoltGaugeLabel.Text = 'Volt';

            % Create VoltGauge
            app.VoltGauge = uigauge(app.IOControlTab, 'linear');
            app.VoltGauge.Limits = [0 10];
            app.VoltGauge.Position = [399 271 232 40];

            % Create CurrentGaugeLabel
            app.CurrentGaugeLabel = uilabel(app.IOControlTab);
            app.CurrentGaugeLabel.HorizontalAlignment = 'center';
            app.CurrentGaugeLabel.Position = [494 131 46 22];
            app.CurrentGaugeLabel.Text = 'Current';

            % Create CurrentGauge
            app.CurrentGauge = uigauge(app.IOControlTab, 'linear');
            app.CurrentGauge.Limits = [0 5];
            app.CurrentGauge.Position = [402 168 231 40];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SolarPanelAssistantV2_1_code

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end