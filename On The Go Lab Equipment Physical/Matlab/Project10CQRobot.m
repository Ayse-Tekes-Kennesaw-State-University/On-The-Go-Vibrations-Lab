clear a;
a = arduino('/dev/cu.usbmodem101', 'Uno');

% Define motor control pins
ENA = 'D5';   % PWM pin for speed control
IN1 = 'D6';   % Direction pin 1
IN2 = 'D7';   % Direction pin 2

% Set pin modes
configurePin(a, IN1, 'DigitalOutput');
configurePin(a, IN2, 'DigitalOutput');

% Set motor direction (forward)
writeDigitalPin(a, IN1, 1);
writeDigitalPin(a, IN2, 0);

% Initialize data storage for time and voltage
timeData = [];
voltageData = [];

% Start figure for raw voltage plot
figure;
title('Raw Y-Axis Voltage from ADXL335');
xlabel('Time (s)');
ylabel('Voltage (V)');
grid on;
hold on;
lineHandle = animatedline('Color', 'b');
startTime = datetime('now');

% Start motor at 28% speed
writePWMVoltage(a, ENA, 0.28 * 5);

% Plot for 8 seconds and store data
while seconds(datetime('now') - startTime) < 12
    % Read raw voltage from Y-axis
    y = readVoltage(a, 'A1');

    % Store time and voltage data
    t = seconds(datetime('now') - startTime);
    timeData = [timeData; t];
    voltageData = [voltageData; y];

    % Plot raw data
    addpoints(lineHandle, t, y);
    xlim([0, 12.25]);
    ylim([1.34, 1.8]);  % Full voltage range of Arduino analogRead
    drawnow;

    pause(0.05);  % Controls update speed
end

% Stop motor
writePWMVoltage(a, ENA, 0);

% Final voltage reading
fprintf('Final Y-axis Voltage: %.2f V\n', y);

% Export the data to CSV
csvwrite('Unbalanced_Mass_Data.csv', [timeData, voltageData]);

fprintf('Data exported to Unbalanced_Mass_Data.csv\n');
