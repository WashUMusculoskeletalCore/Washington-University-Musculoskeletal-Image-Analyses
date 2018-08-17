function [hObject,eventdata,handles] = CalculateMaskVolume(hObject,eventdata,handles)

len = length(find(handles.bwContour));
vol = len * handles.info.SliceThickness^3;
h = msgbox(['The volume of this mask is ' num2str(vol) 'mm^3']);
%another thing
