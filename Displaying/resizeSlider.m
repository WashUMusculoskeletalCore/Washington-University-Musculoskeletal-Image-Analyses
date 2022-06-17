% NAME-resizeSlider
% DESC-resizes a slider and sets its value to the minimum
% IN-slider: the slider to be resized
% min: the new minimum value for the slider, default 1
% max: the new maximum value for the slider
% button_step: the step size when clicking the arrow buttons, default 1
% trough_step: the step size when clicking the trough, default 1
% OUT-slider: the resized slider
function slider = resizeSlider(varargin)
    if nargin == 2 % Slider and max only
        slider=varargin{1};
        min=1;
        max=varargin{2};
        button_step=1;
        trough_step=1;       
    elseif nargin == 3 % Slider, min, and max
        slider=varargin{1}; 
        min=varargin{2};
        max=varargin{3};
        button_step=1;c
        trough_step=1;  
    elseif nargin == 5 % Slider, min, max, and step sizes
        slider=varargin{1};
        min=varargin{2};
        max=varargin{3};
        button_step=varargin{4};
        trough_step=varargin{5};
    else
         error('Incorrect number of arguments for resizeSlider')
    end
    set(slider,'Value', min);
    set(slider,'min', min);
    set(slider,'max', max);
    set(slider,'SliderStep',[button_step, trough_step]/(max-min));
end
