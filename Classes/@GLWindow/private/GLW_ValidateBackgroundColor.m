function validatedBGColor = GLW_ValidateBackgroundColor(desiredBGColor, displayTypeID)
% GLW_ValidateBackgroundColor - Validates the background color based on the display type.
%
% Syntax:
% validatedBGColor = GLW_ValidateBackgroundColor(desiredBGColor, displayTypeID)
%
% Description:
% Validates the background color based on the display type.
%
% Input:
% desiredBGColor (1x3|1x4|struct|cell array|[]) - The desired background color in
%     RGB, RGBA, or struct format.  In struct format, each field specifies a
%     particular screen RGB or RGBA color.
% displayTypeID (integer) - The display ID type of the GLWindow.
%     This value should be generated by GLW_ValidateDisplayType.
%
% Output:
% validatedBGColor (Mx4) - The validated background color(s) where each row
%     is a window's RGBA background color.

if nargin ~= 2
	error('Usage: validatedBGColor = GLW_ValidateBackgroundColor(desiredBGColor, displayTypeID)');
end

% The default alpha value for the background if one wasn't specified.
defaultAlpha = 1;

switch displayTypeID
	case {GLWindow.DisplayTypes.Normal, GLWindow.DisplayTypes.BitsPP}
		if isempty(desiredBGColor)
			desiredBGColor = [0 0 0 0];
		elseif ndims(desiredBGColor) == 2
			if ~all(size(desiredBGColor) == [1 3]) && ~all(size(desiredBGColor) == [1 4])
				error('"desiredBGColor" must be a 1x3 or 1x4 array.');
			end
			
			% Add on the alpha value if omitted.
			if length(desiredBGColor) == 3
				desiredBGColor(4) = defaultAlpha;
			end
		else
			error('Invalid format for "desiredBGColor".');
		end
		
	case {GLWindow.DisplayTypes.Stereo, GLWindow.DisplayTypes.StereoBitsPP}
		if isempty(desiredBGColor)
			desiredBGColor = zeros(2,4);
		elseif isstruct(desiredBGColor)
			% Validate the fields in the desiredWindowID struct.
			GLW_ValidateStructFields(desiredBGColor, {'left', 'right'});
			
			% Add on the A component if it doesn't exist.
			if length(desiredBGColor.left) == 3
				desiredBGColor.front(4) = defaultAlpha;
			end
			if length(desiredBGColor.right) == 3
				desiredBGColor.back(4) = defaultAlpha;
			end
			
			desiredBGColor = [desiredBGColor.left ; desiredBGColor.right];
		elseif ndims(desiredBGColor) == 2 && all(size(desiredBGColor) == [2 3])
			% Add on the A component.
			desiredBGColor(:,4) = [defaultAlpha;defaultAlpha];
		elseif ndims(desiredBGColor) == 2 && all(size(desiredBGColor) == [2 4])
			% Do nothing because the color is in the right format.
		elseif iscell(desiredBGColor) && length(desiredBGColor) == 2
			% Add an A component if necessary to the background color.
			if length(desiredBGColor{1}) == 3
				desiredBGColor{1}(4) = defaultAlpha;
			end
			if length(desiredBGColor{2}) == 3
				desiredBGColor{2}(4) = defaultAlpha;
			end
			
			desiredBGColor = [desiredBGColor{1} ; desiredBGColor{2}];
		else
			error('desiredBGColor must be a 2x3, 2x4, cell array, or struct.');
		end
		
	case GLWindow.DisplayTypes.HDR
		if isempty(desiredBGColor)
			desiredBGColor = zeros(2,4);
		elseif isstruct(desiredBGColor)
			% Validate the fields in the desiredWindowID struct.
			GLW_ValidateStructFields(desiredBGColor, {'front', 'back'});
			
			% Add on the A component if it doesn't exist.
			if length(desiredBGColor.front) == 3
				desiredBGColor.front(4) = defaultAlpha;
			end
			if length(desiredBGColor.back) == 3
				desiredBGColor.back(4) = defaultAlpha;
			end
			
			desiredBGColor = [desiredBGColor.front ; desiredBGColor.back];
		elseif ndims(desiredBGColor) == 2 && all(size(desiredBGColor) == [2 3])
			% Add on the A component.
			desiredBGColor(:,4) = [defaultAlpha;defaultAlpha];
		elseif ndims(desiredBGColor) == 2 && all(size(desiredBGColor) == [2 4])
			% Do nothing because the color is in the right format.
		elseif iscell(desiredBGColor) && length(desiredBGColor) == 2
			% Add an A component if necessary to the background color.
			if length(desiredBGColor{1}) == 3
				desiredBGColor{1}(4) = defaultAlpha;
			end
			if length(desiredBGColor{2}) == 3
				desiredBGColor{2}(4) = defaultAlpha;
			end
			
			desiredBGColor = [desiredBGColor{1} ; desiredBGColor{2}];
		else
			error('desiredBGColor must be a 2x3, 2x4, cell array, or struct.');
		end
		
	case GLWindow.DisplayTypes.StereoHDR
		% The number of colors we expect to be passed.
		numColors = length(GLWindow.DisplayFields.StereoHDR);
		
		if isempty(desiredBGColor)
			desiredBGColor = zeros(numColors,4);
		elseif isstruct(desiredBGColor)
			% Validate the fields in the desiredWindowID struct.
			GLW_ValidateStructFields(desiredBGColor, GLWindow.DisplayFields.StereoHDR);
			
			% Add on the alpha component if it doesn't exist.
			for i = 1:numColors
				if length(desiredBGColor.(GLWindow.DisplayFields.StereoHDR{i})) == 3
					desiredBGColor.(GLWindow.DisplayFields.StereoHDR{i}) = defaultAlpha;
				end
			end
			
			% Stick everything into a matrix.
			c = zeros(numColors, 4);
			for i = 1:numColors
				c(i,:) = desiredBGColor.(GLWindow.DisplayFields.StereoHDR{i});
			end
			desiredBGColor = c;
		elseif iscell(desiredBGColor)
			assert(isvector(desiredBGColor) && length(desiredBGColor) == 4, ...
				'GLW_ValidateBackgroundColor:InvalidCellDims', ...
				'Background color cell array must be a 1x4.');
			
			% Add on the alpha component if it doesn't exist.
			for i = 1:numColors
				if length(desiredBGColor{i}) == 3
					desiredBGColor{i}(4) = defaultAlpha;
				end
			end
			
			% Stick everything into a matrix.
			c = zeros(numColors, 4);
			for i = 1:numColors
				c(i,:) = desiredBGColor.(GLWindow.DisplayFields.StereoHDR{i});
			end
			desiredBGColor = c;
		elseif isequal(size(desiredBGColor), [numColors 3])
			% Add on the alpha component.
			desiredBGColor(:,4) = ones(numColors, 1) * defaultAlpha;
		elseif isequal(size(desiredBGColor), [numColors 4])
			% Do nothing because the color is in the right format.
		else
			error('desiredBGColor must be a %dx3, %dx4, cell array, or struct.', ...
				numColors, numColors);
		end
end

% Make sure all values in the background color are in the [0,1] world.
assert(all(desiredBGColor(:) >= 0 & desiredBGColor(:) <= 1), ...
	'GLW_ValidateBackgroundColor:RGBOutOfRange', ...
	'All background color values must be in the [0,1] range.');

validatedBGColor = desiredBGColor;
