classdef F22K1011 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        SavePanel                   matlab.ui.container.Panel
        Label                       matlab.ui.control.Label
        extDropDown                 matlab.ui.control.DropDown
        pngDropDownLabel            matlab.ui.control.Label
        SAVEButton                  matlab.ui.control.Button
        FiliNameEditField           matlab.ui.control.EditField
        FiliNameEditFieldLabel      matlab.ui.control.Label
        TabGroup                    matlab.ui.container.TabGroup
        CropTab                     matlab.ui.container.Tab
        AngleSlider                 matlab.ui.control.Slider
        AngleSliderLabel            matlab.ui.control.Label
        ySlider                     matlab.ui.control.RangeSlider
        ySliderLabel                matlab.ui.control.Label
        xSlider                     matlab.ui.control.RangeSlider
        xSliderLabel                matlab.ui.control.Label
        ColorAdjustmentTab          matlab.ui.container.Tab
        ContrastSlider              matlab.ui.control.Slider
        ContrastSliderLabel         matlab.ui.control.Label
        SaturationSlider            matlab.ui.control.Slider
        SaturationSliderLabel       matlab.ui.control.Label
        BrightnessSlider            matlab.ui.control.Slider
        BrightnessSliderLabel       matlab.ui.control.Label
        FiltersTab                  matlab.ui.container.Tab
        FilterButtonGroup           matlab.ui.container.ButtonGroup
        InitialButton               matlab.ui.control.ToggleButton
        ImageBin                    matlab.ui.control.Image
        ImageNega                   matlab.ui.control.Image
        BinarizationButton          matlab.ui.control.ToggleButton
        ImageSepia                  matlab.ui.control.Image
        ImageGray                   matlab.ui.control.Image
        ReversalButton              matlab.ui.control.ToggleButton
        SepiaButton                 matlab.ui.control.ToggleButton
        GrayScaleButton             matlab.ui.control.ToggleButton
        MunualColorAdjustmentTab    matlab.ui.container.Tab
        PreviewButton               matlab.ui.control.Button
        ySpinner                    matlab.ui.control.Spinner
        ySpinnerLabel               matlab.ui.control.Label
        xSpinner                    matlab.ui.control.Spinner
        xSpinnerLabel               matlab.ui.control.Label
        SelectedPointDropDown       matlab.ui.control.DropDown
        SelectedPointDropDownLabel  matlab.ui.control.Label
        PlusButton                  matlab.ui.control.Button
        DeleteButton                matlab.ui.control.Button
        RGBButtonGroup              matlab.ui.container.ButtonGroup
        ButtonB                     matlab.ui.control.ToggleButton
        ButtonG                     matlab.ui.control.ToggleButton
        ButtonR                     matlab.ui.control.ToggleButton
        ButtonA                     matlab.ui.control.ToggleButton
        UIAxes                      matlab.ui.control.UIAxes
        save                        matlab.ui.control.Button
        do                          matlab.ui.control.Button
        cancel                      matlab.ui.control.Button
        Image                       matlab.ui.control.Image
    end

    
    properties (Access = private)
        %変数の設定
        I;
        I2;
        h0;
        w0;
        d0;
        imname;
        ext;
        map;
        filename;
        points;
        line;
        dim;
        Ig;
        Is;
        Ir;
        Ib;
    end
    
    methods (Access = private)

        function trimming(app)
            x = floor(app.xSlider.Value);
            y = floor(app.ySlider.Value);

            range = ones(app.h0,app.w0,app.d0)*0.5;
            range(y(1):y(2),x(1):x(2),:) = 1;
            I1 = double(app.I).*range;

            app.Image.ImageSource = uint8(I1);
            
            app.I2=[];
            app.I2(1:y(2)-y(1)+1,1:x(2)-x(1)+1,:) = I1(y(1):y(2),x(1):x(2),:);
            
        end
        
        function drawpoints(app)
            plot(app.UIAxes,0:255,0:255)
            hold(app.UIAxes,"on")
            
            scatter(app.UIAxes,app.points(:,1),app.points(:,2),"blue");
            n = app.SelectedPointDropDown.Value;
            scatter(app.UIAxes,app.points(n,1),app.points(n,2),"filled","blue");

            app.xSpinner.Value = app.points(n,1);
            app.ySpinner.Value = app.points(n,2);

            app.line = [];
            app.line = interp1(app.points(:,1),app.points(:,2),0:255,"makima");
            plot(app.UIAxes,app.line)
            %yyaxis right
            %histogram(app.UIAxes,app.I,"FaceColor","k","FaceAlpha",0.2, ...
            %    "EdgeColor","none","BinWidth",3);

            hold(app.UIAxes,"off")

            if n == 1 || n == 2
                app.xSpinner.Enable = "off";
                app.DeleteButton.Enable = "off";
            else
                app.xSpinner.Enable = "on";
                app.DeleteButton.Enable = "on";
            end

        end
        
        
        function changebutton(app)
            app.save.Visible = "off";
            app.save.Enable = "off";
            app.do.Visible = "on";
            app.do.Enable = "on";
            
        end

        
        function filters(app)
            I = app.I;
            
            %sepia
            app.Is = [];
            V = 0.291*double(I(:,:,1))+...
                0.571*double(I(:,:,2))+0.140*double(I(:,:,3));
            app.Is(:,:,1) = V.*1.351;
            app.Is(:,:,2) = V.*1.2;
            app.Is(:,:,3) = V.*0.934;

            %revers
            app.Ir = [];
            app.Ir = abs(255.-I);

            %gray
            app.Ig = [];
            I = im2gray(I);
            app.Ig(:,:,1) = I;
            app.Ig(:,:,2) = I;
            app.Ig(:,:,3) = I;

            %binary 
            app.Ib = [];
            I(I < 128) = 0;
            I(I >= 128) = 255;
            app.Ib(:,:,1) = I;
            app.Ib(:,:,2) = I;
            app.Ib(:,:,3) = I;

        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.I = imread(app.Image.ImageSource);
            [~, app.imname, app.ext] = fileparts(app.Image.ImageSource);

            [app.h0 app.w0 app.d0] = size(app.I);
            app.points = [0 0;255 255];

            app.xSlider.Limits = [1 app.w0];
            app.xSlider.Value = [1 app.w0];
            app.xSlider.MajorTicks = linspace(1,app.w0,10);
            app.xSlider.MajorTickLabels = "";
            app.xSlider.MinorTicks = [];
            
            app.ySlider.Limits = [1 app.h0];
            app.ySlider.Value = [1 app.h0];
            app.ySlider.MajorTicks = linspace(1,app.h0,10);
            app.ySlider.MajorTickLabels = "";
            app.ySlider.MinorTicks = [];

            app.AngleSlider.Limits = [-180 180];
            app.AngleSlider.MajorTicks = -180:45:180;
            app.AngleSlider.MinorTicks = -180:15:180;


            app.SaturationSlider.Limits = [-0.5 0.5];
            app.SaturationSlider.MajorTicks = -0.5:1/10:0.5;
            app.SaturationSlider.MajorTickLabels = "";
            app.SaturationSlider.MinorTicks = [];

            app.BrightnessSlider.Limits = [0.5 1.5];
            app.BrightnessSlider.Value = 1;
            app.BrightnessSlider.MajorTicks = 0.5:1/10:1.5;
            app.BrightnessSlider.MajorTickLabels = "";
            app.BrightnessSlider.MinorTicks = [];

            app.ContrastSlider.Limits = [0.5 1.5];
            app.ContrastSlider.Value = 1;
            app.ContrastSlider.MajorTicks = 0.5:1/10:1.5;
            app.ContrastSlider.MajorTickLabels = "";
            app.ContrastSlider.MinorTicks = [];

            app.UIAxes.XLim = [0 255];
                        
            app.SelectedPointDropDown.Items = {'Point 1',...
                'Point 2','Point 3','Point 4','Point 5','Point 6',...
                'Point 7','Point 8','Point 9'};
            app.SelectedPointDropDown.ItemsData = 1:length(app.points(:,1));

            app.xSpinner.Step = 10;
            app.ySpinner.Step = 10;

            app.save.Visible = "on";
            app.save.Enable = "on";
            app.do.Visible = "off";
            app.do.Enable = "off";

            app.InitialButton.Value = true
        end

        % Button pushed function: save
        function saveButtonPushed(app, event)
            app.TabGroup.Visible = "off";
            
            app.SavePanel.Visible = 'on';
            app.SavePanel.Enable = 'on';
            app.save.Visible = 'off';
            app.save.Enable = 'off';
            app.cancel.Visible = 'on';
            app.cancel.Enable = 'on';

            app.FiliNameEditField.Value = app.imname;
            app.filename = append("images/",app.FiliNameEditField.Value);
            app.extDropDown.Value = app.ext;
            app.pngDropDownLabel.Text = app.ext;


        end

        % Value changed function: FiliNameEditField
        function FiliNameEditFieldValueChanged(app, event)
            value = app.FiliNameEditField.Value;
            app.filename = append("images/",value);
        end

        % Value changed function: extDropDown
        function extDropDownValueChanged(app, event)
            value = app.extDropDown.Value;
            app.pngDropDownLabel.Text = value;
        end

        % Button pushed function: SAVEButton
        function SAVEButtonPushed(app, event)
            app.Label.Visible = "on";
            app.Label.Enable = 'on';

            if app.filename == "images/"
                error0 = "ファイル名は必ず入力してください。"
                app.Label.Text = error0;
                app.Label.BackgroundColor = 'yellow';
                app.Label.FontColor = 'red';
                
            else
                try filename = append(app.filename,app.pngDropDownLabel.Text)
                    try imwrite(app.I,filename)
                        app.Label.Text = "The image was successfully saved!";
                        app.SAVEButton.Enable = "off";
                        app.SAVEButton.Visible = "off";
                    catch ME
                        error2 = ME.message
                        app.Label.Text = error2;
                        app.Label.BackgroundColor = 'yellow';
                        app.Label.FontColor = 'red';
                   
                    end
                catch ME
                    error1 = ME.message
                    app.Label.Text = error1;
                    app.Label.BackgroundColor = 'yellow';
                    app.Label.FontColor = 'red';
                    
                end
            end
               

        end

        % Value changed function: xSlider
        function xSliderValueChanged(app, event)
            app.trimming()
            app.changebutton()
        end

        % Value changed function: ySlider
        function ySliderValueChanged(app, event)
            app.trimming()
            app.changebutton()
        end

        % Value changed function: AngleSlider
        function AngleSliderValueChanged(app, event)
            t = app.AngleSlider.Value;
            app.I2 = imrotate(app.I,t,"crop");

            app.Image.ImageSource = uint8(app.I2);
            app.changebutton()
        end

        % Value changed function: SaturationSlider
        function SaturationSliderValueChanged(app, event)
            t = app.SaturationSlider.Value;
            app.I2 = app.I;

            Imax = app.I*(1+t);
            Imin = app.I*(1-t);

            [~, imax] = max(app.I,[],3);
            [~, imin] = min(app.I,[],3);
            for d = 1:app.d0
                i = find(imax == d);
                app.I2(app.h0*app.w0*(d-1)+i) = Imax(app.h0*app.w0*(d-1)+i);
                i = find(imin == d);
                app.I2(app.h0*app.w0*(d-1)+i) = Imin(app.h0*app.w0*(d-1)+i);
            end

            app.Image.ImageSource = uint8(app.I2);
            app.changebutton()
        end

        % Value changed function: BrightnessSlider
        function BrightnessSliderValueChanged(app, event)
            t = app.BrightnessSlider.Value;
            app.I2 = double(app.I)*t;

            app.Image.ImageSource = uint8(app.I2);
            app.changebutton()
        end

        % Value changed function: ContrastSlider
        function ContrastSliderValueChanged(app, event)
            t = app.ContrastSlider.Value;

            xx = 0:255;
            y = t*(xx-128)+128;
            y(y<0) = 0;
            y(y>255) = 255;

            f = @(x) y(x+1);
            app.I2 = arrayfun(f, app.I);

            app.Image.ImageSource = uint8(app.I2);
            app.changebutton()
        end

        % Selection change function: TabGroup
        function TabGroupSelectionChanged(app, event)
            selectedTab = app.TabGroup.SelectedTab;
            app.Image.ImageSource = uint8(app.I);
            if selectedTab.Title == "Munual Color Adjustment"
                app.drawpoints()
                app.dim = "all";
            elseif selectedTab.Title == "Filters"
                app.filters()

                app.ImageGray.ImageSource = uint8(app.Ig);
                app.ImageSepia.ImageSource = uint8(app.Is);
                app.ImageNega.ImageSource = uint8(app.Ir);
                app.ImageBin.ImageSource = uint8(app.Ib);
            end

        end

        % Value changed function: SelectedPointDropDown
        function SelectedPointDropDownValueChanged(app, event)
            app.drawpoints()
        end

        % Value changed function: xSpinner
        function xSpinnerValueChanged(app, event)
            value = app.xSpinner.Value;
            n = app.SelectedPointDropDown.Value;
            app.points(n,1) = value;
            app.drawpoints()
        end

        % Value changed function: ySpinner
        function ySpinnerValueChanged(app, event)
            value = app.ySpinner.Value;
            n = app.SelectedPointDropDown.Value;
            app.points(n,2) = value;
            app.points
            app.drawpoints()
        end

        % Button pushed function: PlusButton
        function PlusButtonPushed(app, event)
            if length(app.points(:,1)) <= 8
                n = randi([1 254]);
                app.points(end+1,:) = [n app.line(n)];
                app.SelectedPointDropDown.ItemsData = 1:length(app.points(:,1));
                app.SelectedPointDropDown.Value = length(app.points(:,1));
            end
            app.drawpoints()
        end

        % Button pushed function: DeleteButton
        function DeleteButtonPushed(app, event)
            n = app.SelectedPointDropDown.Value;
            if n == 1 || n == 2
                pass
            else
                app.points(n,:) = [];
                app.SelectedPointDropDown.ItemsData = 1:length(app.points(:,1));
                app.SelectedPointDropDown.Value = 1;
                app.SelectedPointDropDownValueChanged()
            end
        end

        % Button pushed function: PreviewButton
        function PreviewButtonPushed(app, event)
            f = @(x) app.line(x+1);
            if app.dim == "All"
                app.I2 = arrayfun(f, app.I);
            elseif app.dim == "Red"
                app.I2 = app.I;
                app.I2(:,:,1) = arrayfun(f, app.I(:,:,1));
            elseif app.dim == "Green"
                app.I2 = app.I;
                app.I2(:,:,2) = arrayfun(f, app.I(:,:,2));
            else
                app.I2 = app.I;
                app.I2(:,:,3) = arrayfun(f, app.I(:,:,3));
            end

            %hold(app.UIAxes,"on")
            %yyaxis right
            %histogram(app.UIAxes,app.I2,"FaceColor","k","FaceAlpha",0.2, ...
            %    "EdgeColor","none","BinWidth",3);
            %hold(app.UIAxes,"off")

            app.Image.ImageSource = uint8(app.I2);
            app.changebutton()

        end

        % Selection changed function: RGBButtonGroup
        function RGBButtonGroupSelectionChanged(app, event)
            selectedButton = app.RGBButtonGroup.SelectedObject;
            app.dim = selectedButton.Text;
        end

        % Button pushed function: cancel
        function cancelButtonPushed(app, event)
            app.TabGroup.Visible = "on";

            app.SavePanel.Visible = 'off';
            app.SavePanel.Enable = 'off';
            app.save.Visible = 'on';
            app.save.Enable = 'on';
            app.cancel.Visible = 'off';
            app.cancel.Enable = 'off';
        end

        % Button pushed function: do
        function doButtonPushed(app, event)
            app.I = app.I2;
            app.Image.ImageSource = uint8(app.I);
            [app.h0 app.w0 app.d0] = size(app.I);

            app.save.Visible = "on";
            app.save.Enable = "on";
            app.do.Visible = "off";
            app.do.Enable = "off";

            app.xSlider.Limits = [1 app.w0];
            app.xSlider.Value = [1 app.w0];
            app.xSlider.MajorTicks = linspace(1,app.w0,10);
            
            app.ySlider.Limits = [1 app.h0];
            app.ySlider.Value = [1 app.h0];
            app.ySlider.MajorTicks = linspace(1,app.h0,10);

            app.AngleSlider.Value = 0;
            app.SaturationSlider.Value = 0;
            app.BrightnessSlider.Value = 1;
            app.ContrastSlider.Value = 1;
            app.points = [0 0; 255 255];
            app.SelectedPointDropDown.ItemsData = 1:2;
            app.SelectedPointDropDown.Value = 1;
            app.drawpoints()
        end

        % Selection changed function: FilterButtonGroup
        function FilterButtonGroupSelectionChanged(app, event)
            selectedButton = app.FilterButtonGroup.SelectedObject;
            if selectedButton.Text == "Gray Scale"
                app.I2 = app.Ig;
            elseif selectedButton.Text == "Sepia"
                app.I2 = app.Is;
            elseif selectedButton.Text == "Reversal"
                app.I2 = app.Ir;
            elseif selectedButton.Text == "Binarization"
                app.I2 = app.Ib;
            end

            app.Image.ImageSource = uint8(app.I2);
            app.changebutton()

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 50 648 587];
            app.UIFigure.Name = 'MATLAB App';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [52 239 548 300];
            app.Image.ImageSource = fullfile(pathToMLAPP, ...
                'images', 'peppers.png');

            % Create cancel
            app.cancel = uibutton(app.UIFigure, 'push');
            app.cancel.ButtonPushedFcn = createCallbackFcn(app, ...
                @cancelButtonPushed, true);
            app.cancel.WordWrap = 'on';
            app.cancel.Enable = 'off';
            app.cancel.Visible = 'off';
            app.cancel.Position = [18 555 87 24];
            app.cancel.Text = 'CANCEL';

            % Create do
            app.do = uibutton(app.UIFigure, 'push');
            app.do.ButtonPushedFcn = createCallbackFcn(app, ...
                @doButtonPushed, true);
            app.do.Enable = 'off';
            app.do.Visible = 'off';
            app.do.Position = [547 555 90 23];
            app.do.Text = 'DO';

            % Create save
            app.save = uibutton(app.UIFigure, 'push');
            app.save.ButtonPushedFcn = createCallbackFcn(app, ...
                @saveButtonPushed, true);
            app.save.Position = [546 555 90 23];
            app.save.Text = 'SAVE';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, ...
                @TabGroupSelectionChanged, true);
            app.TabGroup.Position = [40 10 580 215];

            % Create CropTab
            app.CropTab = uitab(app.TabGroup);
            app.CropTab.Title = 'Crop';

            % Create xSliderLabel
            app.xSliderLabel = uilabel(app.CropTab);
            app.xSliderLabel.HorizontalAlignment = 'right';
            app.xSliderLabel.Position = [35 146 25 22];
            app.xSliderLabel.Text = 'x';

            % Create xSlider
            app.xSlider = uislider(app.CropTab, 'range');
            app.xSlider.MajorTickLabels = {'0', '20', '40', '60', '80', '100'};
            app.xSlider.ValueChangedFcn = createCallbackFcn(app, ...
                @xSliderValueChanged, true);
            app.xSlider.Position = [82 155 468 3];

            % Create ySliderLabel
            app.ySliderLabel = uilabel(app.CropTab);
            app.ySliderLabel.HorizontalAlignment = 'right';
            app.ySliderLabel.Position = [35 97 25 22];
            app.ySliderLabel.Text = 'y';

            % Create ySlider
            app.ySlider = uislider(app.CropTab, 'range');
            app.ySlider.MajorTickLabels = {'0', '20', '40', '60', '80', '100'};
            app.ySlider.ValueChangedFcn = createCallbackFcn(app, ...
                @ySliderValueChanged, true);
            app.ySlider.Position = [82 106 468 3];

            % Create AngleSliderLabel
            app.AngleSliderLabel = uilabel(app.CropTab);
            app.AngleSliderLabel.HorizontalAlignment = 'right';
            app.AngleSliderLabel.Position = [2 34 54 22];
            app.AngleSliderLabel.Text = 'Angle';

            % Create AngleSlider
            app.AngleSlider = uislider(app.CropTab);
            app.AngleSlider.ValueChangedFcn = createCallbackFcn(app, ...
                @AngleSliderValueChanged, true);
            app.AngleSlider.Position = [78 52 478 3];

            % Create ColorAdjustmentTab
            app.ColorAdjustmentTab = uitab(app.TabGroup);
            app.ColorAdjustmentTab.Title = 'Color Adjustment';

            % Create BrightnessSliderLabel
            app.BrightnessSliderLabel = uilabel(app.ColorAdjustmentTab);
            app.BrightnessSliderLabel.HorizontalAlignment = 'right';
            app.BrightnessSliderLabel.Position = [36 91 62 22];
            app.BrightnessSliderLabel.Text = 'Brightness';

            % Create BrightnessSlider
            app.BrightnessSlider = uislider(app.ColorAdjustmentTab);
            app.BrightnessSlider.ValueChangedFcn = createCallbackFcn(app, ...
                @BrightnessSliderValueChanged, true);
            app.BrightnessSlider.Position = [119 100 431 3];

            % Create SaturationSliderLabel
            app.SaturationSliderLabel = uilabel(app.ColorAdjustmentTab);
            app.SaturationSliderLabel.HorizontalAlignment = 'right';
            app.SaturationSliderLabel.Position = [38 146 60 22];
            app.SaturationSliderLabel.Text = 'Saturation';

            % Create SaturationSlider
            app.SaturationSlider = uislider(app.ColorAdjustmentTab);
            app.SaturationSlider.ValueChangedFcn = createCallbackFcn(app, ...
                @SaturationSliderValueChanged, true);
            app.SaturationSlider.Position = [119 155 431 3];

            % Create ContrastSliderLabel
            app.ContrastSliderLabel = uilabel(app.ColorAdjustmentTab);
            app.ContrastSliderLabel.HorizontalAlignment = 'right';
            app.ContrastSliderLabel.Position = [38 39 50 22];
            app.ContrastSliderLabel.Text = 'Contrast';

            % Create ContrastSlider
            app.ContrastSlider = uislider(app.ColorAdjustmentTab);
            app.ContrastSlider.ValueChangedFcn = createCallbackFcn(app, ...
                @ContrastSliderValueChanged, true);
            app.ContrastSlider.Position = [119 48 425 3];

            % Create FiltersTab
            app.FiltersTab = uitab(app.TabGroup);
            app.FiltersTab.Title = 'Filters';

            % Create FilterButtonGroup
            app.FilterButtonGroup = uibuttongroup(app.FiltersTab);
            app.FilterButtonGroup.SelectionChangedFcn = ...
                createCallbackFcn(app, @FilterButtonGroupSelectionChanged, ...
                true);
            app.FilterButtonGroup.Position = [25 27 531 150];

            % Create GrayScaleButton
            app.GrayScaleButton = uitogglebutton(app.FilterButtonGroup);
            app.GrayScaleButton.Text = 'Gray Scale';
            app.GrayScaleButton.Position = [31 18 100 23];
            app.GrayScaleButton.Value = true;

            % Create SepiaButton
            app.SepiaButton = uitogglebutton(app.FilterButtonGroup);
            app.SepiaButton.Text = 'Sepia';
            app.SepiaButton.Position = [160 18 100 23];

            % Create ReversalButton
            app.ReversalButton = uitogglebutton(app.FilterButtonGroup);
            app.ReversalButton.Text = 'Reversal';
            app.ReversalButton.Position = [282 18 100 23];

            % Create ImageGray
            app.ImageGray = uiimage(app.FilterButtonGroup);
            app.ImageGray.Position = [28 53 104 86];

            % Create ImageSepia
            app.ImageSepia = uiimage(app.FilterButtonGroup);
            app.ImageSepia.Position = [157 53 104 86];

            % Create BinarizationButton
            app.BinarizationButton = uitogglebutton(app.FilterButtonGroup);
            app.BinarizationButton.Text = 'Binarization';
            app.BinarizationButton.Position = [406 18 100 23];

            % Create ImageNega
            app.ImageNega = uiimage(app.FilterButtonGroup);
            app.ImageNega.Position = [279 53 104 86];

            % Create ImageBin
            app.ImageBin = uiimage(app.FilterButtonGroup);
            app.ImageBin.Position = [402 53 104 86];

            % Create InitialButton
            app.InitialButton = uitogglebutton(app.FilterButtonGroup);
            app.InitialButton.Visible = 'off';
            app.InitialButton.Text = 'Initial';
            app.InitialButton.Position = [231 0 80 20];

            % Create MunualColorAdjustmentTab
            app.MunualColorAdjustmentTab = uitab(app.TabGroup);
            app.MunualColorAdjustmentTab.Title = 'Munual Color Adjustment';

            % Create UIAxes
            app.UIAxes = uiaxes(app.MunualColorAdjustmentTab);
            title(app.UIAxes, 'Tone Curve')
            app.UIAxes.Position = [8 55 398 121];

            % Create RGBButtonGroup
            app.RGBButtonGroup = ...
                uibuttongroup(app.MunualColorAdjustmentTab);
            app.RGBButtonGroup.SelectionChangedFcn = ...
                createCallbackFcn(app, @RGBButtonGroupSelectionChanged, ...
                true);
            app.RGBButtonGroup.Position = [8 10 398 37];

            % Create ButtonA
            app.ButtonA = uitogglebutton(app.RGBButtonGroup);
            app.ButtonA.Text = 'All';
            app.ButtonA.Position = [18 7 96 23];
            app.ButtonA.Value = true;

            % Create ButtonR
            app.ButtonR = uitogglebutton(app.RGBButtonGroup);
            app.ButtonR.Text = 'Red';
            app.ButtonR.Position = [113 7 93 23];

            % Create ButtonG
            app.ButtonG = uitogglebutton(app.RGBButtonGroup);
            app.ButtonG.Text = 'Green';
            app.ButtonG.Position = [206 7 90 23];

            % Create ButtonB
            app.ButtonB = uitogglebutton(app.RGBButtonGroup);
            app.ButtonB.Text = 'Blue';
            app.ButtonB.Position = [295 7 90 23];

            % Create DeleteButton
            app.DeleteButton = uibutton(app.MunualColorAdjustmentTab, ...
                'push');
            app.DeleteButton.ButtonPushedFcn = createCallbackFcn(app, ...
                @DeleteButtonPushed, true);
            app.DeleteButton.Icon = fullfile(pathToMLAPP, 'icons', ...
                'delete.png');
            app.DeleteButton.Position = [528 118 37 25];
            app.DeleteButton.Text = '';

            % Create PlusButton
            app.PlusButton = uibutton(app.MunualColorAdjustmentTab, ...
                'push');
            app.PlusButton.ButtonPushedFcn = createCallbackFcn(app, ...
                @PlusButtonPushed, true);
            app.PlusButton.Icon = fullfile(pathToMLAPP, 'icons', ...
                'plus.png');
            app.PlusButton.IconAlignment = 'center';
            app.PlusButton.Position = [528 145 37 25];
            app.PlusButton.Text = '';

            % Create SelectedPointDropDownLabel
            app.SelectedPointDropDownLabel = ...
                uilabel(app.MunualColorAdjustmentTab);
            app.SelectedPointDropDownLabel.HorizontalAlignment = 'center';
            app.SelectedPointDropDownLabel.Position = [428 155 94 22];
            app.SelectedPointDropDownLabel.Text = 'Selected Point';

            % Create SelectedPointDropDown
            app.SelectedPointDropDown = ...
                uidropdown(app.MunualColorAdjustmentTab);
            app.SelectedPointDropDown.ValueChangedFcn = ...
                createCallbackFcn(app, @SelectedPointDropDownValueChanged, ...
                true);
            app.SelectedPointDropDown.Position = [428 125 94 29];

            % Create xSpinnerLabel
            app.xSpinnerLabel = uilabel(app.MunualColorAdjustmentTab);
            app.xSpinnerLabel.HorizontalAlignment = 'right';
            app.xSpinnerLabel.Position = [429 66 25 22];
            app.xSpinnerLabel.Text = 'x';

            % Create xSpinner
            app.xSpinner = uispinner(app.MunualColorAdjustmentTab);
            app.xSpinner.ValueChangedFcn = createCallbackFcn(app, ...
                @xSpinnerValueChanged, true);
            app.xSpinner.Position = [466 48 24 58];

            % Create ySpinnerLabel
            app.ySpinnerLabel = uilabel(app.MunualColorAdjustmentTab);
            app.ySpinnerLabel.HorizontalAlignment = 'right';
            app.ySpinnerLabel.Position = [493 66 25 22];
            app.ySpinnerLabel.Text = 'y';

            % Create ySpinner
            app.ySpinner = uispinner(app.MunualColorAdjustmentTab);
            app.ySpinner.ValueChangedFcn = createCallbackFcn(app, ...
                @ySpinnerValueChanged, true);
            app.ySpinner.Position = [530 48 24 58];

            % Create PreviewButton
            app.PreviewButton = uibutton(app.MunualColorAdjustmentTab, ...
                'push');
            app.PreviewButton.ButtonPushedFcn = createCallbackFcn(app, ...
                @PreviewButtonPushed, true);
            app.PreviewButton.Icon = fullfile(pathToMLAPP, 'icons', ...
                'check.png');
            app.PreviewButton.Position = [457 10 87 31];
            app.PreviewButton.Text = '';

            % Create SavePanel
            app.SavePanel = uipanel(app.UIFigure);
            app.SavePanel.Enable = 'off';
            app.SavePanel.Visible = 'off';
            app.SavePanel.Position = [47 109 564 73];

            % Create FiliNameEditFieldLabel
            app.FiliNameEditFieldLabel = uilabel(app.SavePanel);
            app.FiliNameEditFieldLabel.HorizontalAlignment = 'right';
            app.FiliNameEditFieldLabel.Position = [27 14 56 22];
            app.FiliNameEditFieldLabel.Text = 'Fili Name';

            % Create FiliNameEditField
            app.FiliNameEditField = uieditfield(app.SavePanel, 'text');
            app.FiliNameEditField.ValueChangedFcn = createCallbackFcn(app, ...
                @FiliNameEditFieldValueChanged, true);
            app.FiliNameEditField.Position = [89 9 283 30];

            % Create SAVEButton
            app.SAVEButton = uibutton(app.SavePanel, 'push');
            app.SAVEButton.ButtonPushedFcn = createCallbackFcn(app, ...
                @SAVEButtonPushed, true);
            app.SAVEButton.Position = [485 8 66 32];
            app.SAVEButton.Text = 'SAVE';

            % Create pngDropDownLabel
            app.pngDropDownLabel = uilabel(app.SavePanel);
            app.pngDropDownLabel.HorizontalAlignment = 'right';
            app.pngDropDownLabel.Position = [425 13 25 22];
            app.pngDropDownLabel.Text = 'png';

            % Create extDropDown
            app.extDropDown = uidropdown(app.SavePanel);
            app.extDropDown.Items = {'.png', '.jpeg', '.tif', '.gif', ...
                '.jpg'};
            app.extDropDown.ValueChangedFcn = createCallbackFcn(app, ...
                @extDropDownValueChanged, true);
            app.extDropDown.Position = [455 8 24 32];
            app.extDropDown.Value = '.png';

            % Create Label
            app.Label = uilabel(app.SavePanel);
            app.Label.HorizontalAlignment = 'center';
            app.Label.FontColor = [0 0 1];
            app.Label.Enable = 'off';
            app.Label.Visible = 'off';
            app.Label.Position = [37 47 441 20];
            app.Label.Text = 'The image was successfully saved!';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F22K1011

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