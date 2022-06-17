function [hObject,eventdata,handles] = GenerateHistogram(hObject,eventdata,handles)

try
    setStatus(hObject, handles, 'Busy');
    [a, b, c] = size(handles.img);
    img = reshape(handles.img,[1,a*b*c]);
    figure;
    histogram(img(img > 0),320);
    setStatus(hObject, handles, 'Not Busy');
catch err
    setStatus(hObject, handles, 'Failed');
    reportError(err);
end