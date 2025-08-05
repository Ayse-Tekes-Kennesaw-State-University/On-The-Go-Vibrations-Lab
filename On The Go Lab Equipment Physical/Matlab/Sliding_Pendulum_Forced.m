clear all;

% Connect to Arduino and load the Servo library
a = arduino('/dev/cu.usbmodem1101', 'Uno', 'Libraries', 'Servo');

% Attach servo to pin D9
s = servo(a, 'D9');

% ADXL335 Setup
disp('Calibrating ADXL335 - keep sensor still for 2 seconds...');
calibrationSamples = 200;
offset = 0;
for i = 1:calibrationSamples
    offset = offset + readVoltage(a, 'A0'); % Y-axis on A0
    pause(0.00001);
end
offset = offset/calibrationSamples;
disp(['Y-axis offset voltage: ' num2str(offset) 'V']);

% Initialize data logging
data = []; % Will store [timestamp, servoPos, accelVoltage]

% Prompt user to manually position the servo to desired center
input('Press Enter to start oscillation.', 's');

% Set current position as center (as in your original code)
centerPosNorm = 0.502;  % normalized value [0, 1]
oscillationAngle = 28;  % degrees (+/-20°)

% Create figure for real-time plotting
figure;
h = animatedline;
xlabel('Time (s)');
ylabel('Acceleration (V)');
grid on;

startTime = tic;
while true
    % Sweep from center - angle to center + angle (your original loop)
    for angle = -oscillationAngle:4:oscillationAngle
        % Servo control (unchanged from your code)
        pos = centerPosNorm + angle/180;
        pos = max(0, min(1, pos));
        writePosition(s, pos);
        
        % Read accelerometer (improved part)
        accelVoltage = readVoltage(a, 'A0') - offset; % Offset correction
        timestamp = toc(startTime);
        
        % Store data
        data = [data; timestamp, pos, accelVoltage];
        
        % Update plot
        addpoints(h, timestamp, accelVoltage);
        drawnow limitrate;
        
        pause(0.00001); % Slightly longer pause for better readings
    end

    % Sweep back (your original reverse loop)
    for angle = oscillationAngle:-4:-oscillationAngle
        pos = centerPosNorm + angle/180;
        pos = max(0, min(1, pos));
        writePosition(s, pos);
        
        accelVoltage = readVoltage(a, 'A0') - offset;
        timestamp = toc(startTime);
        
        data = [data; timestamp, pos, accelVoltage];
        addpoints(h, timestamp, accelVoltage);
        drawnow limitrate;
        
        pause(0.01);
    end
    
    % Add escape condition (press Ctrl+C to stop)
    if toc(startTime) > 30 % Auto-stop after 30 seconds
        break;
    end
end

% Cleanup (servo returns to center)
writePosition(s, centerPosNorm);

% Plot final results
figure;
subplot(2,1,1);
plot(data(:,1), data(:,2));
ylabel('Servo Position (norm)');
title('Servo Motion vs Acceleration');

subplot(2,1,2);
plot(data(:,1), data(:,3));
ylabel('Acceleration (V)');
xlabel('Time (s)');