%% Radar Target Generation and Detection

clear all;
clc;

%% Radar Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 77GHz
% Max Range = 200m
% Range Resolution = 1 m
% Max Velocity = 100 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

c = 3e8;            % Speed of light

%% User Defined Range and Velocity of target
% define the target's initial position and velocity. Note : Velocity remains constant

R0 = 110;           % Initial range of the target (m)
v0 = -20;           % Target velocity (m/s) (negative = approaching radar)


%% FMCW Waveform Generation

% Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW chirp using the requirements above.

range_res = 1;      % Range Resolution
R_max = 200;        % Maximum Range
fc = 77e9;          % Operating carrier frequency

% Bandwidth
B_sweep = c / (2 * range_res);

% Chirp time (5.5 * round-trip time for max range)
T_chirp = 5.5 * (2 * R_max / c);

% Slope
slope = B_sweep / T_chirp;

disp(['Chirp Slope: ', num2str(slope)]);

%% Simulation parameters

Nd = 128;           % Number of chirps
Nr = 1024;          % Number of range cells

% Timestamp for running the displacement scenario for every sample on each chirp
t = linspace(0, Nd*T_chirp, Nr*Nd); % total time for samples

% Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx = zeros(1,length(t));    % transmitted signal
Rx = zeros(1,length(t));    % received signal
Mix = zeros(1,length(t));   % beat signal

% Similar vectors for range_covered and time delay.
r_t = zeros(1,length(t));
td = zeros(1,length(t));


%% Signal generation and Moving Target simulation
% Running the radar scenario over time

for i = 1:length(t)
    
    % For each time stamp update the Range of the Target for constant velocity.
    r_t(i) = R0 + v0 * t(i);
    td(i) = (2 * r_t(i)) / c;
    
    % For each time sample update the transmitted and received signal.
    Tx(i) = cos(2*pi*(fc*t(i) + (slope*t(i)^2)/2));
    Rx(i) = cos(2*pi*(fc*(t(i) - td(i)) + (slope*(t(i) - td(i))^2)/2));
    
    % Mix the Transmit and Receive signals (element-wise multiplication)
    Mix(i) = Tx(i) .* Rx(i);
end


%% RANGE MEASUREMENT

% reshape the vector into Nr*Nd array
Mix = reshape(Mix, [Nr, Nd]);

% run the FFT on the beat signal along the range bins dimension (Nr)
signal_fft = fft(Mix, Nr);

% normalize
signal_fft = abs(signal_fft / Nr);

% keep only one side of the spectrum
signal_fft = signal_fft(1:Nr/2+1, :);

% plot FFT output
figure ('Name','Range from First FFT');
plot(signal_fft(:,1));
title('Range from First FFT');
xlabel('Range (m)');
ylabel('Amplitude');
axis ([0 200 0 1]);


%% RANGE DOPPLER RESPONSE

% 2D FFT on the mixed signal (beat signal) to generate a Range Doppler Map
sig_fft2 = fft2(Mix, Nr, Nd);

% Taking just one side of signal from Range dimension
sig_fft2 = sig_fft2(1:Nr/2, 1:Nd);
sig_fft2 = fftshift(sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM);

% Plot the Range Doppler Map
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure('Name','Range Doppler Map');
surf(doppler_axis,range_axis,RDM);
xlabel('Velocity (m/s)');
ylabel('Range (m)');
zlabel('Amplitude (dB)');
title('Range Doppler Map');


%% CFAR implementation

% Select the number of Training Cells in both dimensions
Tr = 10;    % Training cells in Range dimension
Td = 8;     % Training cells in Doppler dimension

% Select the number of Guard Cells in both dimensions around the CUT
Gr = 4;     % Guard cells in Range dimension
Gd = 4;     % Guard cells in Doppler dimension

% Offset the threshold by SNR value in dB
offset = 6;

% Create a vector to store noise_level for each iteration on training cells
[m, n] = size(RDM);
signal_cfar = zeros(m,n);

% Slide CUT across the complete Range Doppler Map
for i = (Tr+Gr+1):(m-(Gr+Tr))
    for j = (Td+Gd+1):(n-(Gd+Td))
        
        % Measure noise across training cells
        noise_level = zeros(1,1);
        
        for p = i-(Tr+Gr):i+Tr+Gr
            for q = j-(Td+Gd):j+Td+Gd
                % Exclude the Guard cells and CUT
                if (abs(i-p) > Gr || abs(j-q) > Gd)
                    noise_level = noise_level + db2pow(RDM(p,q));
                end
            end
        end
        
        % Calculate threshold (average then convert back to dB)
        num_training_cells = ((2*(Tr+Gr)+1)*(2*(Td+Gd)+1)) - ((2*Gr+1)*(2*Gd+1));
        threshold = pow2db(noise_level / num_training_cells);
        threshold = threshold + offset;
        
        % Compare CUT against threshold
        CUT = RDM(i,j);
        if CUT > threshold
            signal_cfar(i,j) = 1;
        else
            signal_cfar(i,j) = 0;
        end
        
    end
end

% Display the CFAR output
figure('Name','2D CFAR Output');
surf(doppler_axis,range_axis,signal_cfar);
xlabel('Velocity (m/s)');
ylabel('Range (m)');
zlabel('Detection');
title('2D CFAR Detection');
colorbar;

