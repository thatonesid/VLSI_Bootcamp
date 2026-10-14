close all;
v1 =  load("fircomp_990_eq.txt"); %add file here
%v1 = v1(1:4:end);
v1=v1-0.5; % Remove the DC component from digital signal.

NFFTv = 2000; %last this many samples will be used to plot fft
OSR = 2048;
Fs = 2e3; %sampling frequency
len = length(v1);
v1 = v1(len-NFFTv+1:end); % Take last NFFTv samples of v1
L = length(v1);
FS = 1;
fv = Fs / 2 * linspace(0, 1, NFFTv / 2 + 1); % Frequency vector (Hz)


%no changes required below this line

% Compute PSD & plot
% Use this for no LEAKAGE :)

wind = hann(L, 'periodic');
fft_outv = fft(v1 .* wind, NFFTv);
% Ptot = (abs(fft_outv)).^2; % Power spectrum of the signal

% Normalise the peak of signal

Ptot = (abs(fft_outv)/(FS * sum(wind) * 1/4)).^2; % Power spectrum of the signal
fft_onesided = abs(Ptot(1:NFFTv/2+1));
figure;
semilogx(fv, 10*log10(fft_onesided)); 
xlim([10, 80e3])
xlabel('Frequency [Hz]');
ylabel('Amplitude [dB]');
grid on;

% SNDR calculation
% Select appropriate signal bin for SNDR calculation
fin = 990; 
k = round(fin * NFFTv / Fs) + 1;
sigbin = k-1:k+1;
% For signal power, integrate over input signal BW
sigpow = sum(fft_onesided(sigbin));
% For noise Power, integrate till nyquist frequency and subtract signal
% power.
% npow = sum(fft_onesided(3:end)) - sigpow;
npow = sum(fft_onesided(3:round(end))) - sigpow;

sndr = 10*log10(sigpow./npow);% Compute SNDR