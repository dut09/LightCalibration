function [fitresult, gof] = fit_power_function(X, Y)
%CREATEFIT(X,Y)
%  Create a fit.
%
%  Data for 'fit_powe_function' fit:
%      X Input : X
%      Y Output: Y
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 31-May-2014 19:43:15


%% Fit: 'fit_powe_function'.
[xData, yData] = prepareCurveData( X, Y );

% Set up fittype and options.
ft = fittype( 'power1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 -4];
opts.Robust = 'LAR';
opts.StartPoint = [0.0858007613485088 -2];
opts.Upper = [1 0];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.

figure( 'Name', 'fit_powe_function' );
h = plot( fitresult, xData, yData );
legend( h, 'Y vs. X', 'fit_powe_function', 'Location', 'NorthEast' );
% Label axes
xlabel( 'X' );
ylabel( 'Y' );
grid on


