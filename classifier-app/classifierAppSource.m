classdef classifierAppSource < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        AppdeClasificadoresUIFigure     matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        CoordenadaXEditFieldLabel       matlab.ui.control.Label
        CoordenadaXEditField            matlab.ui.control.NumericEditField
        CoordenadaYEditFieldLabel       matlab.ui.control.Label
        CoordenadaYEditField            matlab.ui.control.NumericEditField
        DispersinEditFieldLabel         matlab.ui.control.Label
        DispersinEditField              matlab.ui.control.NumericEditField
        NmerodeClasesEditFieldLabel     matlab.ui.control.Label
        NmerodeClasesEditField          matlab.ui.control.NumericEditField
        CrearButton                     matlab.ui.control.Button
        CrearClaseButton                matlab.ui.control.Button
        XPruebaEditFieldLabel           matlab.ui.control.Label
        XPruebaEditField                matlab.ui.control.NumericEditField
        YPruebaEditFieldLabel           matlab.ui.control.Label
        YPruebaEditField                matlab.ui.control.NumericEditField
        MtodoListBoxLabel               matlab.ui.control.Label
        MtodoListBox                    matlab.ui.control.ListBox
        MiembrosporClaseEditFieldLabel  matlab.ui.control.Label
        MiembrosporClaseEditField       matlab.ui.control.NumericEditField
        ProbarButton                    matlab.ui.control.Button
        Label                           matlab.ui.control.Label
        UITable                         matlab.ui.control.Table
    end

    
    properties (Access = private)
        
        randR = 1       % The rightmost end of the random range.
        randL = -1      % The leftmost end of the random range.
        members         % The number of members in each class.
        classIndex      % The currently created class index. 
        dimension = 2   % The dimension of the vectors.
        testCount       % The current test count.
        classes         % The number of classes.
        means           % The class means.
        classifiers     % The classes.
        
    end
    
    methods (Access = private)
    
        function CreateClass(app, k, x, y, r)
            classMembers = rand(app.dimension, app.members) .* (app.randR - app.randL);
            classMembers = (classMembers + app.randL) .* r;
            classMembers(1, :) = classMembers(1, :) + x;
            classMembers(2, :) = classMembers(2, :) + y;
            app.classifiers(:, :, k) = classMembers;
            app.means(:, k) = mean(app.classifiers(:, :, k), 2);
            scatter(app.UIAxes, app.classifiers(1, :, k), app.classifiers(2, :, k), 'filled', 'DisplayName', strcat('C', num2str(k)));
        end
    
        function TestVector(app, x, y)
            option = str2double(app.MtodoListBox.Value);
            testVector = [ x ; y ];
            if option == 1
                [ class, distances ] = app.Euclidean(testVector);
                app.PrintOutput(testVector, class, 'Distancia Euclideana', distances);  
            elseif option == 2
                [ class, distances ] = app.Mahalanobis(testVector);
                app.PrintOutput(testVector, class, 'Mahalanobis', distances);  
            elseif option == 3
                [ class, probabilities ] = app.MaxProbability(testVector);
                app.PrintOutput(testVector, class, 'Máxima Probabilidad.', probabilities);  
            elseif option == 4
                k = inputdlg({ 'Ingresa el valor de K' }, 'K-Nearest Neighbors');
                [ class, bucket ] = app.KNearestNeighbors(testVector, str2double(k{:}));
                app.PrintOutput(testVector, class, 'K-NN', bucket);  
            end
            scatter(app.UIAxes, x, y, 'LineWidth', 1.5, 'DisplayName', strcat('X', num2str(app.testCount))); 
            app.testCount = app.testCount + 1;
        end
    
        function PrintOutput(app, vector, class, method, outputVector)
            output = [ 'El vector ' mat2str(vector) ];
            output = [ output ' pertenece a la clase ' num2str(class) ];
            output = [ output ' por medio de ' method ];
            app.UpdateTable(outputVector);
            app.Label.Text = output;
        end
    
        function [ minClass, distances ] = Mahalanobis(app, testVector)
            % Minimum Mahalanobis classification algorithm.
            
            % Collect sizes.
            [ dc, elements, app.classes ] = size(app.classifiers);
            [ dt, ~ ] = size(testVector);
            [ dm, ~ ] = size(app.means); 
            
            distances = zeros(app.classes, 1);
            minClass = 0;
            
            if dc ~= dm
                return
            end
            
            if dc ~= dt
                return
            end
            
            sigma = zeros(dc, dc, app.classes);
            
            for k = 1 : app.classes
                m = app.classifiers(:, :, k) - app.means(:, k);
                sigma(:, :, k) = (m * m') ./ elements;
            end
            
            % Minimal distance starts at infinity.
            minDist = Inf;
            % Pick any class as the closest class.
            minClass = 1;
            
            for k = 1 : app.classes
                % Compute Mahalanobis distance.
                m = testVector - app.means(:, k);
                dist = (m' / sigma(:, :, k)) * m;
                distances(k, :) = dist;
                if minDist > dist
                    % Minimize distance.
                    minDist = dist;
                    % Store the new closest class.
                    minClass = k;
                end
            end
            
        end
    
        function [ class, probabilities ] = MaxProbability(app, testVector)
            % Maximum Probability classification algorithm.
            
            % Collect sizes.
            [ dc, elements, app.classes ] = size(app.classifiers);
            [ dt, ~ ] = size(testVector);
            [ dm, ~ ] = size(app.means); 
            
            probabilities = zeros(app.classes, 1);
            class = 0;
            
            if dc ~= dm
                return
            end
            
            if dc ~= dt
                return
            end
            
            sigma = zeros(dc, dc, app.classes);
            
            for k = 1 : app.classes
                m = app.classifiers(:, :, k) - app.means(:, k);
                sigma(:, :, k) = (m * m') ./ elements;
            end
            
            % Probability vector.
            den = (2 * pi()) ^ app.dimension;
            p = zeros(app.classes);
            accumulated = 0;
            
            for k = 1 : app.classes
                % Compute Probability.
                m = testVector - app.means(:, k);
                prob = exp(- ((m' / sigma(:, :, k)) * m) / 2);
                prob = prob / sqrt(det(sigma(:, :, k)) * den);
                accumulated = accumulated + prob;
                p(k) = prob;
            end
            
            % Maximum probability starts at -infinity.
            maxProbability = -Inf;
            % Pick any class as the closest class.
            class = 1;
            
            for k = 1 : app.classes
                p(k) = p(k) / accumulated;
                probabilities(k, :) = p(k);
                if maxProbability < p(k)
                    % Maximize probability.
                    maxProbability = p(k);
                    % Store the new closest class.
                    class = k;
                end
            end
            
        end
    
        function [ minClass, distances ] = Euclidean(app, testVector)
            % Minimum Distance classification algorithm.
            
            % Collect sizes.
            [ dc, ~, app.classes ] = size(app.classifiers);
            [ dt, ~ ] = size(testVector);
            [ dm, ~ ] = size(app.means); 
            
            distances = zeros(app.classes, 1);
            minClass = 0;
            
            if dc ~= dm
                return
            end
            
            if dc ~= dt
                return
            end
            
            % Minimal distance starts at infinity.
            minDist = Inf;
            % Pick any class as the closest class.
            minClass = 1;
            for k = 1 : app.classes
                % Compute distance to class mean.
                dist = norm(app.means(:, k) - testVector);
                distances(k, :) = dist;
                if minDist > dist
                    % Minimize distance.
                    minDist = dist;
                    % Store the new closest class.
                    minClass = k;
                end
            end
            
        end
    
        function [ class, bucket ] = KNearestNeighbors(app, testVector, knn)
            % Minimum Distance classification algorithm.
            
            % Collect sizes.
            [ dc, ~, app.classes ] = size(app.classifiers);
            [ dt, ~ ] = size(testVector);
            [ dm, ~ ] = size(app.means); 
            
            bucket = zeros(app.classes, 1);
            class = 0;
            
            if dc ~= dm
                return
            end
            
            if dc ~= dt
                return
            end
            
            distances = zeros(1, app.classes * app.members);
            id = zeros(1, app.classes * app.members);
            
            for k = 1 : app.classes
                for l = 1 : app.members
                    index = (k - 1) * app.members + l;
                    distances(:, index) = norm(app.classifiers(:, l, k) - testVector);
                    id(:, index) = k;
                end
            end
            
            [ sorted, indices ] = sort(distances);
            last = zeros(1, app.classes);
            id = id(indices);
            disp([sorted ; id]);
            
            for k = 1 : knn
                bucket(id(:, k), :) = bucket(id(:, k), :) + 1;
                last(:, id(:, k)) = k;
            end
            
            maxBucket = -Inf;
            minLast = Inf;
            
            for k = 1 : app.classes
                if bucket(k, :) > maxBucket
                    maxBucket = bucket(k, :);
                    minLast = last(:, k);
                    class = k;
                elseif bucket(k, :) == maxBucket
                    if last(:, k) < minLast
                       minLast = last(:, k);
                       class = k;
                    end
                end
            end
            
        end
        
        function UpdateTable(app, distances)
            classLabels = 1 : 1 : app.classes;
            app.UITable.Data = table(classLabels', distances);
        end
        
        function DisableClassesGroup(app)
            app.MiembrosporClaseEditField.Enable = 'off';
            app.NmerodeClasesEditField.Enable = 'off';
            app.CrearButton.Enable = 'off';
        end
        
        function EnableClassesGroup(app)
            app.MiembrosporClaseEditField.Enable = 'on';
            app.NmerodeClasesEditField.Enable = 'on';
            app.CrearButton.Enable = 'on';
        end
        
        function DisableClassGroup(app)
            app.CoordenadaXEditField.Enable = 'off';
            app.CoordenadaYEditField.Enable = 'off';
            app.DispersinEditField.Enable = 'off';
            app.CrearClaseButton.Enable = 'off';
        end
        
        function EnableClassGroup(app)
            app.CoordenadaXEditField.Enable = 'on';
            app.CoordenadaYEditField.Enable = 'on';
            app.DispersinEditField.Enable = 'on';
            app.CrearClaseButton.Enable = 'on';
        end
        
        function DisableTestGroup(app)
            app.XPruebaEditField.Enable = 'off';
            app.YPruebaEditField.Enable = 'off';
            app.ProbarButton.Enable = 'off';
        end
        
        function EnableTestGroup(app)
            app.XPruebaEditField.Enable = 'on';
            app.YPruebaEditField.Enable = 'on';
            app.ProbarButton.Enable = 'on';
        end
    
    end
    

    methods (Access = private)

        % Button pushed function: CrearButton
        function CrearButtonPushed(app, event)
            app.members = app.MiembrosporClaseEditField.Value;
            app.classes = app.NmerodeClasesEditField.Value;
            app.classifiers = zeros(app.dimension, app.members, app.classes);
            app.means = zeros(app.dimension, app.classes);
            app.DisableClassesGroup();
            app.DisableTestGroup();
            app.EnableClassGroup();
            app.Label.Text = '';
            app.classIndex = 1;
            app.testCount = 1;
            cla(app.UIAxes);
        end

        % Button pushed function: CrearClaseButton
        function CrearClaseButtonPushed(app, event)
            x = app.CoordenadaXEditField.Value;
            y = app.CoordenadaYEditField.Value;
            r = app.DispersinEditField.Value;
            app.CreateClass(app.classIndex, x, y, r);
            app.classIndex = app.classIndex + 1;
            if app.classIndex > app.classes
                scatter(app.UIAxes, app.means(1, :), app.means(2, :), 'filled', 'DisplayName', 'Medias');
                legend(app.UIAxes, 'show');
                app.EnableClassesGroup();
                app.DisableClassGroup();
                app.EnableTestGroup();
                return;
            end
        end

        % Button pushed function: ProbarButton
        function ProbarButtonPushed(app, event)
            x = app.XPruebaEditField.Value;
            y = app.YPruebaEditField.Value;
            app.TestVector(x, y);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create AppdeClasificadoresUIFigure
            app.AppdeClasificadoresUIFigure = uifigure;
            app.AppdeClasificadoresUIFigure.Position = [100 100 1000 611];
            app.AppdeClasificadoresUIFigure.Name = 'App de Clasificadores';
            app.AppdeClasificadoresUIFigure.Resize = 'off';

            % Create UIAxes
            app.UIAxes = uiaxes(app.AppdeClasificadoresUIFigure);
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.NextPlot = 'add';
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.ZGrid = 'on';
            app.UIAxes.Position = [149 166 825 422];

            % Create CoordenadaXEditFieldLabel
            app.CoordenadaXEditFieldLabel = uilabel(app.AppdeClasificadoresUIFigure);
            app.CoordenadaXEditFieldLabel.HorizontalAlignment = 'right';
            app.CoordenadaXEditFieldLabel.Position = [40 376 83 22];
            app.CoordenadaXEditFieldLabel.Text = 'Coordenada X';

            % Create CoordenadaXEditField
            app.CoordenadaXEditField = uieditfield(app.AppdeClasificadoresUIFigure, 'numeric');
            app.CoordenadaXEditField.Enable = 'off';
            app.CoordenadaXEditField.Position = [44 355 76 22];

            % Create CoordenadaYEditFieldLabel
            app.CoordenadaYEditFieldLabel = uilabel(app.AppdeClasificadoresUIFigure);
            app.CoordenadaYEditFieldLabel.HorizontalAlignment = 'right';
            app.CoordenadaYEditFieldLabel.Position = [40 324 83 22];
            app.CoordenadaYEditFieldLabel.Text = 'Coordenada Y';

            % Create CoordenadaYEditField
            app.CoordenadaYEditField = uieditfield(app.AppdeClasificadoresUIFigure, 'numeric');
            app.CoordenadaYEditField.Enable = 'off';
            app.CoordenadaYEditField.Position = [44 303 76 22];

            % Create DispersinEditFieldLabel
            app.DispersinEditFieldLabel = uilabel(app.AppdeClasificadoresUIFigure);
            app.DispersinEditFieldLabel.HorizontalAlignment = 'right';
            app.DispersinEditFieldLabel.Position = [51 272 62 22];
            app.DispersinEditFieldLabel.Text = 'Dispersión';

            % Create DispersinEditField
            app.DispersinEditField = uieditfield(app.AppdeClasificadoresUIFigure, 'numeric');
            app.DispersinEditField.Limits = [1e-09 Inf];
            app.DispersinEditField.Enable = 'off';
            app.DispersinEditField.Position = [44 251 76 22];
            app.DispersinEditField.Value = 1e-09;

            % Create NmerodeClasesEditFieldLabel
            app.NmerodeClasesEditFieldLabel = uilabel(app.AppdeClasificadoresUIFigure);
            app.NmerodeClasesEditFieldLabel.HorizontalAlignment = 'right';
            app.NmerodeClasesEditFieldLabel.Position = [28 527 105 22];
            app.NmerodeClasesEditFieldLabel.Text = 'Número de Clases';

            % Create NmerodeClasesEditField
            app.NmerodeClasesEditField = uieditfield(app.AppdeClasificadoresUIFigure, 'numeric');
            app.NmerodeClasesEditField.Limits = [1 Inf];
            app.NmerodeClasesEditField.RoundFractionalValues = 'on';
            app.NmerodeClasesEditField.Position = [43 506 76 22];
            app.NmerodeClasesEditField.Value = 1;

            % Create CrearButton
            app.CrearButton = uibutton(app.AppdeClasificadoresUIFigure, 'push');
            app.CrearButton.ButtonPushedFcn = createCallbackFcn(app, @CrearButtonPushed, true);
            app.CrearButton.Position = [31 416 100 22];
            app.CrearButton.Text = 'Crear';

            % Create CrearClaseButton
            app.CrearClaseButton = uibutton(app.AppdeClasificadoresUIFigure, 'push');
            app.CrearClaseButton.ButtonPushedFcn = createCallbackFcn(app, @CrearClaseButtonPushed, true);
            app.CrearClaseButton.Enable = 'off';
            app.CrearClaseButton.Position = [31 215 100 22];
            app.CrearClaseButton.Text = 'Crear Clase';

            % Create XPruebaEditFieldLabel
            app.XPruebaEditFieldLabel = uilabel(app.AppdeClasificadoresUIFigure);
            app.XPruebaEditFieldLabel.HorizontalAlignment = 'right';
            app.XPruebaEditFieldLabel.Position = [57 119 55 22];
            app.XPruebaEditFieldLabel.Text = 'X Prueba';

            % Create XPruebaEditField
            app.XPruebaEditField = uieditfield(app.AppdeClasificadoresUIFigure, 'numeric');
            app.XPruebaEditField.Enable = 'off';
            app.XPruebaEditField.Position = [38 93 93 22];

            % Create YPruebaEditFieldLabel
            app.YPruebaEditFieldLabel = uilabel(app.AppdeClasificadoresUIFigure);
            app.YPruebaEditFieldLabel.HorizontalAlignment = 'right';
            app.YPruebaEditFieldLabel.Position = [175 119 55 22];
            app.YPruebaEditFieldLabel.Text = 'Y Prueba';

            % Create YPruebaEditField
            app.YPruebaEditField = uieditfield(app.AppdeClasificadoresUIFigure, 'numeric');
            app.YPruebaEditField.Enable = 'off';
            app.YPruebaEditField.Position = [156 90 93 22];

            % Create MtodoListBoxLabel
            app.MtodoListBoxLabel = uilabel(app.AppdeClasificadoresUIFigure);
            app.MtodoListBoxLabel.HorizontalAlignment = 'right';
            app.MtodoListBoxLabel.Position = [310 124 47 22];
            app.MtodoListBoxLabel.Text = 'Método';

            % Create MtodoListBox
            app.MtodoListBox = uilistbox(app.AppdeClasificadoresUIFigure);
            app.MtodoListBox.Items = {'Distancia Euclideana', 'Mahalanobis', 'Máxima Probabilidad', 'K-Nearest Neighbors'};
            app.MtodoListBox.ItemsData = {'1', '2', '3', '4'};
            app.MtodoListBox.Position = [372 86 209 62];
            app.MtodoListBox.Value = '1';

            % Create MiembrosporClaseEditFieldLabel
            app.MiembrosporClaseEditFieldLabel = uilabel(app.AppdeClasificadoresUIFigure);
            app.MiembrosporClaseEditFieldLabel.HorizontalAlignment = 'right';
            app.MiembrosporClaseEditFieldLabel.Position = [24 477 114 22];
            app.MiembrosporClaseEditFieldLabel.Text = 'Miembros por Clase';

            % Create MiembrosporClaseEditField
            app.MiembrosporClaseEditField = uieditfield(app.AppdeClasificadoresUIFigure, 'numeric');
            app.MiembrosporClaseEditField.Limits = [1 Inf];
            app.MiembrosporClaseEditField.RoundFractionalValues = 'on';
            app.MiembrosporClaseEditField.Position = [43 456 76 22];
            app.MiembrosporClaseEditField.Value = 1;

            % Create ProbarButton
            app.ProbarButton = uibutton(app.AppdeClasificadoresUIFigure, 'push');
            app.ProbarButton.ButtonPushedFcn = createCallbackFcn(app, @ProbarButtonPushed, true);
            app.ProbarButton.Enable = 'off';
            app.ProbarButton.Position = [635 106 100 22];
            app.ProbarButton.Text = 'Probar';

            % Create Label
            app.Label = uilabel(app.AppdeClasificadoresUIFigure);
            app.Label.BackgroundColor = [1 1 1];
            app.Label.HorizontalAlignment = 'center';
            app.Label.Position = [38 23 697 43];
            app.Label.Text = '';

            % Create UITable
            app.UITable = uitable(app.AppdeClasificadoresUIFigure);
            app.UITable.ColumnName = {'Clase'; 'Magnitud'};
            app.UITable.RowName = {};
            app.UITable.ColumnEditable = true;
            app.UITable.Position = [782 23 192 125];
        end
    end

    methods (Access = public)

        % Construct app
        function app = classifierAppSource

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.AppdeClasificadoresUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.AppdeClasificadoresUIFigure)
        end
    end
end