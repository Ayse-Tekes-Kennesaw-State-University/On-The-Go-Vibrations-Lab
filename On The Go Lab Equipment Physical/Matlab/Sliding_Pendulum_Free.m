% Initialize Arduino
a = arduino('Uno', 'Libraries', 'RotaryEncoder');  
 
% Create encoder object for pins D2 (A phase) and D3 (B phase)
encoder = rotaryEncoder(a, 'D2', 'D3', 600);  % 600 pulses per revolution
 
% Reset encoder to zero
resetCount(encoder);
 
% Initialize data storage
angles = [];
timestamps = [];
tic;
 
% Set up live plot
figure;
h = plot(nan, nan, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Angle (degrees)');
title('Live Encoder Displacement');
grid on;
xlim([0 10]);
ylim([-20 20]);
 
disp("Plotting live encoder data... Press Ctrl+C to stop.");
 
while true
    % Get current time and angle
    t = toc;
    count = readCount(encoder);
    angle = (count / 600) * 90;  % Convert count to degrees
    % Store values
    timestamps(end+1) = t;
    angles(end+1) = angle;
    % Update plot
    set(h, 'XData', timestamps, 'YData', angles);
    xlim([max(0, t-10), t+1]);  % Scroll plot window
    drawnow;
    pause(0.015);  % Sample every 50 ms
end