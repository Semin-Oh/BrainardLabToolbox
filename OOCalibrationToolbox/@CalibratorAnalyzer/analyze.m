% Method to analyze a calStruct generated by a @Calibrator object.
function obj = analyze(obj)
 
    DescribeMonCal(obj.calStructOBJ);
    
    % Print some more information
    if (obj.calStructOBJ.inputCalHasNewStyleFormat)
        fprintf('  * Graphics Driver  : %s - based\n', obj.newStyleCal.describe.graphicsEngine);
        fprintf('  * Screen size      : %d x %d pixels\n', obj.newStyleCal.describe.screenSizePixel(1), obj.newStyleCal.describe.screenSizePixel(2));
        fprintf('  * Target size      : %d x %d pixels\n', obj.newStyleCal.describe.boxSize(1), obj.newStyleCal.describe.boxSize(1));
        fprintf('  * Target position  : (%d,%d) pixels (offset from center)\n', obj.newStyleCal.describe.boxOffsetX, obj.newStyleCal.describe.boxOffsetY);
        fprintf('  * Background Color : %2.3f %2.3f %2.3f\n', obj.newStyleCal.describe.bgColor(1), obj.newStyleCal.describe.bgColor(2), obj.newStyleCal.describe.bgColor(3));
        fprintf('  * Foreground Color : %2.3f %2.3f %2.3f\n', obj.newStyleCal.describe.fgColor(1), obj.newStyleCal.describe.fgColor(2), obj.newStyleCal.describe.fgColor(3));
        fprintf('  * Averages         : %d\n', obj.newStyleCal.describe.nAverage);  
        fprintf('  * Radiometer Model : %s\n', obj.newStyleCal.describe.meterModel);
        fprintf('\n');
    end
    
    obj.refitData(); 
    obj.plotAllData();
    
end