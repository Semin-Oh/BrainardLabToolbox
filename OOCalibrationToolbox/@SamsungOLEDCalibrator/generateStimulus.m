function demoFrame = generateStimulus(obj, stabilizerGray, bkgndGray, biasGray, biasSize, leftTargetGray, rightTargetGray, stabilizerText, sceneText)

    % Targets
    targetSize      = 100;
    leftTarget.x0   = 1920/2 - 200;
    leftTarget.y0   = 1080/2;
    rightTarget.x0  = 1920/2 + 600;
    rightTarget.y0  = 1080/2+250;
    
    
    bkgndMaxDev     = 0.3;

    
    % 1. Stabilizer
    stabilizer.width        = 1920;
    stabilizer.height       = 1080;
    stabilizer.borderWidth  = 180;
    stabilizer.x0           = 1920/2;
    stabilizer.y0           = 1080/2;
    stabilizerRect          = CenterRectOnPointd([0 0 stabilizer.width stabilizer.height], stabilizer.x0, stabilizer.y0);
    stabilizer.data         = repmat(ones(stabilizer.height,stabilizer.width)*stabilizerGray, [1 1 3]);
      
    if (~obj.runMode)
        % update demo frame
        demoFrame = stabilizer.data;
    end
    
    % 2. Scene
    scene.width        = stabilizer.width  - 2*stabilizer.borderWidth;
    scene.height       = stabilizer.height - 2*stabilizer.borderWidth;
    scene.x0           = 1920/2;
    scene.y0           = 1080/2;
    sceneRect          = CenterRectOnPointd([0 0 scene.width scene.height], scene.x0, scene.y0);
    sceneRows          = 20;
    sceneCols          = 40;
    zoom               = round(0.5*(scene.height/sceneRows + scene.width/sceneCols)+0.5);
    lowResMatrix       = randn(sceneRows,sceneCols)/3.3;
    lowResMatrix       = bkgndGray+bkgndMaxDev*lowResMatrix;
    hiResMatrix        = kron(lowResMatrix, ones(zoom));
    actualHeight       = size(hiResMatrix,1);
    actualWidth        = size(hiResMatrix,2);
    hiResMatrix        = hiResMatrix(1:min([scene.height actualHeight]), 1:min([scene.width actualWidth]));
    scene.height       = size(hiResMatrix,1);
    scene.width        = size(hiResMatrix,2);
    scene.data         = repmat(hiResMatrix, [1 1 3]);
    
    if (~obj.runMode)
        % update demo frame
        demoFrame = UpdateDemoFrame(demoFrame, scene);
    end
    
    % 3. Bias pattern (centered on left target)
    bias.width  = biasSize(1);
    bias.height = biasSize(2);
    
    bias.x0                 = leftTarget.x0;
    bias.y0                 = leftTarget.y0;
    biasRect                = CenterRectOnPointd([0 0 bias.width bias.height], bias.x0, bias.y0);
    bias.data               = repmat(ones(bias.height,bias.width)*biasGray, [1 1 3]);
    
    if (~obj.runMode)
        % update demo frame
        demoFrame = UpdateDemoFrame(demoFrame, bias);
    end
    
    
    % 4. Left target
    leftTarget.width        = targetSize;
    leftTarget.height       = targetSize;
    leftTargetRect          = CenterRectOnPointd([0 0 leftTarget.width leftTarget.height], leftTarget.x0, leftTarget.y0);
    leftTarget.data         = DiskMatrix(leftTarget.height, leftTarget.width, leftTargetGray, biasGray);
    
    if (~obj.runMode)
        % update demo frame
        demoFrame = UpdateDemoFrame(demoFrame, leftTarget);
    end
    
    % 5. Right target
    rightTarget.width       = targetSize;
    rightTarget.height      = targetSize;
    rightTargetRect         = CenterRectOnPointd([0 0 rightTarget.width rightTarget.height], rightTarget.x0, rightTarget.y0);
    rightTarget.data        = DiskMatrix(rightTarget.height, rightTarget.width, rightTargetGray, bkgndGray);
    
    if (~obj.runMode)
        % update demo frame
        demoFrame = UpdateDemoFrame(demoFrame, rightTarget);
    end
    
    
    % Generate dithering matrices
    % temporalDitheringMode = '10BitPlusNoise';
    temporalDitheringMode = '10BitNoNoise';
    % temporalDitheringMode = '8Bit';
    
    if (obj.runMode)
        obj.stimDataMatrices     = {};
        obj.stimDestinationRects = {};
        obj.ditheringMatrices    = {};

        obj.stimDataMatrices{1} = stabilizer.data;
        obj.stimDataMatrices{2} = scene.data;
        obj.stimDataMatrices{3} = bias.data;
        obj.stimDataMatrices{4} = leftTarget.data;
        obj.stimDataMatrices{5} = rightTarget.data;

        obj.stimDestinationRects{1} = stabilizerRect;
        obj.stimDestinationRects{2} = sceneRect;
        obj.stimDestinationRects{3} = biasRect;
        obj.stimDestinationRects{4} = leftTargetRect;
        obj.stimDestinationRects{5} = rightTargetRect;


        obj.ditheringMatrices{1} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, stabilizer.height, stabilizer.width);
        obj.ditheringMatrices{2} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, scene.height, scene.width);
        obj.ditheringMatrices{3} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, bias.height, bias.width);
        obj.ditheringMatrices{4} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, leftTarget.height, leftTarget.width);
        obj.ditheringMatrices{5} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, rightTarget.height, rightTarget.width);

        % Render stimulus
        obj.displayMultiRectPattern();
        
        % no demoFrame
        demoFrame = []; 

    end
    
end


function m = DiskMatrix(height, width, target, bkgnd)
    z = ones(height, width)*target;
    if (1==2)
    x = ((1:width)-width/2)/(width/2);
    y = ((1:height)-height/2)/(height/2);
    [X,Y]       = meshgrid(x,y);
    R2          = 0.9^2;
    indices     = find(X.^2 + Y.^2 > R2);
    z(indices)  = bkgnd;
    end
    m(:,:,1)    = z;
    m(:,:,2)    = z;
    m(:,:,3)    = z;
end


function demoFrame = UpdateDemoFrame(oldDemoFrame, stim)
    demoFrame = oldDemoFrame;
    ii = stim.y0 - round(stim.height/2) + (1:stim.height);
    jj = stim.x0 - round(stim.width/2) + (1:stim.width);
    demoFrame(ii,jj,:) = stim.data;    
end
