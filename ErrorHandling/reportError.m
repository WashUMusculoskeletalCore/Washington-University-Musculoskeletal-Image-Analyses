% NAME-reportError
% DESC-prints caught error message to console for debugging, change this as
% needed
% IN-err: the error to be reported
% OUT-IO:Writes to console
function reportError(err)
    disp(err.message);
    for i = 1:length(err.stack)
        disp(err.stack(i));
    end
end

